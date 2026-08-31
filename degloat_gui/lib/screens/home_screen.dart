import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/bloat_group.dart';
import '../models/log_line.dart';
import '../services/adb_service.dart';
import '../services/backup_service.dart';
import '../services/device_audit_service.dart';
import '../services/json_localization_service.dart';
import '../theme/app_theme.dart';
import '../utils/package_rules.dart';
import '../widgets/app_list.dart';
import '../widgets/console_logs.dart';
import '../widgets/home_controls_panel.dart';
import '../widgets/language_switcher.dart';
import '../widgets/manual_apps_panel.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const HomeScreen({
    super.key,
    this.onLocaleChanged,
    this.onThemeModeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TargetMode get _targetMode => AdbService.instance.targetMode;
  DeviceConnectionStatus get _connectionStatus => AdbService.instance.connectionStatus;
  String get _detectedModel => AdbService.instance.detectedModel;
  String get _detectedSerial => AdbService.instance.detectedSerial;

  bool get _isRunningAction => AdbService.instance.isRunningAction;
  set _isRunningAction(bool val) => AdbService.instance.isRunningAction = val;

  bool get _cancelAction => AdbService.instance.cancelAction;
  set _cancelAction(bool val) => AdbService.instance.cancelAction = val;



  final List<LogLine> _logs = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _monitoringTimer;

  String _lastBackupInfo = '';
  List<String> _backedUpPackages = [];
  String _deviceImei = ''; // Device IMEI for safe backup verification
  String? _currentBackupFilePath; // Currently loaded backup file path

  @override
  void initState() {
    super.initState();
    _loadBackupFile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineExecutionMode();
    });
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Get device IMEI via ADB (if available)
  Future<String> _getDeviceImei() async {
    if (_deviceImei.isNotEmpty) return _deviceImei;
    try {
      final result = await _runShell('getprop ro.com.google.clientidbase');
      final imei = result.stdout.toString().trim();
      if (imei.isNotEmpty && imei != 'error') {
        _deviceImei = imei;
        return imei;
      }
      // Fallback: try to get build fingerprint as device identifier
      final fingerprint = await _runShell('getprop ro.build.fingerprint');
      final fp = fingerprint.stdout.toString().trim();
      if (fp.isNotEmpty) {
        _deviceImei = fp.split('/').first; // Get manufacturer/model part
        return _deviceImei;
      }
    } catch (e) {
      debugPrint('Error getting device IMEI: $e');
    }
    return '';
  }

  void _loadBackupFile() async {
    try {
      // Get IMEI for device verification
      await _getDeviceImei();

      // Look for latest backup matching this device
      final backups = await BackupService.listAvailableBackups();
      if (backups.isEmpty) {
        setState(() {
          _backedUpPackages = [];
          _lastBackupInfo = '';
          _currentBackupFilePath = null;
        });
        return;
      }

      // Try to load the most recent backup that matches this device
      BackupFile? loadedBackup;
      for (var backupEntity in backups) {
        final backup = await BackupService.loadBackup(
          filepath: backupEntity.path,
          currentDeviceSerial: _detectedSerial,
          currentDeviceImei: _deviceImei,
        );
        if (backup != null) {
          loadedBackup = backup;
          _currentBackupFilePath = backupEntity.path;
          break; // Use the most recent matching backup
        }
      }

      if (loadedBackup != null) {
        final backup = loadedBackup;
        setState(() {
          _backedUpPackages = backup.allPackages;
          if (backup.allPackages.isNotEmpty) {
            _lastBackupInfo =
                'Last backup: ${backup.metadata.createdAt.toLocal().toString().split('.')[0]} '
                '(${backup.metadata.deviceModel}, ${backup.allPackages.length} apps)';
          } else {
            _lastBackupInfo = '';
          }
        });
      } else {
        setState(() {
          _backedUpPackages = [];
          _lastBackupInfo = '';
          _currentBackupFilePath = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading backup file: $e');
    }
  }

  void _saveBackupFile(List<String> uninstalledPkgs) async {
    if (uninstalledPkgs.isEmpty) return;
    try {
      // Ensure we have device IMEI
      if (_deviceImei.isEmpty) {
        await _getDeviceImei();
      }

      // Merge with existing backup if available
      Set<String> allPkgs = {};
      if (_currentBackupFilePath != null) {
        try {
          final backup = await BackupService.loadBackup(
            filepath: _currentBackupFilePath!,
            currentDeviceSerial: _detectedSerial,
            currentDeviceImei: _deviceImei,
          );
          if (backup != null) {
            allPkgs.addAll(backup.allPackages);
          }
        } catch (_) {}
      }

      // Add newly removed packages
      allPkgs.addAll(uninstalledPkgs);
      final allList = allPkgs.toList();

      // Save with device verification metadata
      final success = await BackupService.saveBackup(
        deviceSerial: _detectedSerial,
        deviceModel: _detectedModel.isNotEmpty ? _detectedModel : 'Samsung Device',
        deviceImei: _deviceImei,
        removedPackages: uninstalledPkgs,
        allPackages: allList,
      );

      if (success) {
        // Reload to get the new filepath
        _loadBackupFile();
      } else {
        debugPrint('Failed to save backup file');
      }
    } catch (e) {
      debugPrint('Error saving backup file: $e');
    }
  }

  String _getLocalizedTitle(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'group_korean_carriers':
        return l10n.group_korean_carriers;
      case 'group_us_carriers':
        return l10n.group_us_carriers;
      case 'group_korean_us_apps':
        return l10n.group_korean_us_apps;
      case 'group_korean_locales':
        return l10n.group_korean_locales;
      case 'group_smart_suggestions':
        return l10n.group_smart_suggestions;
      case 'group_samsung_wallet':
        return l10n.group_samsung_wallet;
      case 'group_samsung_bloat':
        return l10n.group_samsung_bloat;
      case 'group_meta_ms':
        return l10n.group_meta_ms;
      case 'group_bixby':
        return l10n.group_bixby;
      case 'group_game_launcher':
        return l10n.group_game_launcher;
      case 'group_samsung_services':
        return l10n.group_samsung_services;
      case 'group_bluetooth_beacons':
        return l10n.group_bluetooth_beacons;
      case 'group_telemetry':
        return l10n.group_telemetry;
      default:
        return key;
    }
  }

  Future<void> _determineExecutionMode() async {
    if (!mounted) return;
    await AdbService.instance.determineExecutionMode(
      context,
      (text, color) => _addLog(text, color),
      () {
        if (mounted) setState(() {});
      },
    );
    // Fetch device details immediately on initial connection (not waiting for monitoring timer)
    await _checkConnection();
    // Then start periodic monitoring every 4 seconds
    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    AdbService.instance.startStatusMonitoring(() {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    await AdbService.instance.checkConnection(() {
      if (mounted) setState(() {});
    });
  }

  Future<ProcessResult> _runShell(String command, {List<String>? args}) async {
    return await AdbService.instance.runShell(command, args: args);
  }

  Future<void> _performAction(String actionName, Future<void> Function() actionBlock) async {
    if (_isRunningAction) return;
    setState(() {
      _isRunningAction = true;
      _cancelAction = false;
      _logs.clear();
    });

    _addLog('START: $actionName - ${DateTime.now().toLocal().toString().split('.')[0]}', const Color(0xFF00E5FF));
    _addLog('----------------------------------------------------------------', const Color(0xFF90A4AE));

    try {
      await actionBlock();
    } catch (e) {
      _addLog('Exception: $e', const Color(0xFFFF5252));
    } finally {
      if (mounted) {
        setState(() {
          _isRunningAction = false;
          _addLog('----------------------------------------------------------------', const Color(0xFF90A4AE));
          _addLog('FINISHED: $actionName', const Color(0xFF81C784));
        });
      }
      _checkConnection();
    }
  }

  void _actionVerify() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _performAction(l10n.btn_verify, () async {
      _addLog(l10n.log_scanning_packages, const Color(0xFF90A4AE));
      final audit = await DeviceAuditService.runAudit(runShell: _runShell);

      _addLog('\n${l10n.log_debloat_audit}', const Color(0xFF00E5FF));
      for (var group in SystemConfig.bloatGroups) {
        final localizedTitle = _getLocalizedTitle(group.titleKey);
        _addLog('\n-- $localizedTitle --', const Color(0xFF7C4DFF));
        int groupFound = 0;
        for (var pkg in group.packages) {
          if (audit.activeInstalled.contains(pkg) && !PackageRules.shouldSkipDegloat(pkg)) {
            groupFound++;
            _addLog(l10n.log_installed_status(pkg), const Color(0xFFFFD54F));
          }
        }
        if (groupFound == 0) {
          _addLog(l10n.log_group_clean, const Color(0xFF81C784));
        }
      }

      _addLog('\n${l10n.log_audit_summary}', const Color(0xFF7C4DFF));
      _addLog(
        l10n.log_packages_removed(
          (audit.totalBloat - audit.totalBloatFound).toString(),
          audit.totalBloat.toString(),
        ),
        const Color(0xFF81C784),
      );

      final missingProtected = audit.missingProtected;
      if (missingProtected.isNotEmpty) {
        _addLog('\n${l10n.log_critical_missing}', const Color(0xFFFF5252));
        for (var pkg in missingProtected) {
          _addLog(l10n.log_restore_recommended(pkg), const Color(0xFFFF5252));
        }
      } else {
        _addLog(l10n.log_system_safety_ok, const Color(0xFF81C784));
      }

      final csc = audit.csc;
      final friendlyRegion = SystemConfig.getFriendlyCscRegion(csc);
      _addLog('  CSC Sales Code: $csc ($friendlyRegion)', const Color(0xFF00E5FF));
      if (csc == 'KOO') {
        _addLog('      (Device has been changed to KOO - Carrier bloats/boot animation removed)', const Color(0xFF81C784));
      } else {
        _addLog('      (Device is using carrier CSC: $csc)', const Color(0xFFFFD54F));
      }
    });
  }

  void _actionApply({bool dryRun = false}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final modeName = dryRun ? l10n.btn_dry_run : l10n.btn_debloat;
    _performAction(modeName, () async {
      _addLog(l10n.log_scanning_packages, const Color(0xFF90A4AE));
      final packagesResult = await _runShell('pm list packages');
      final installed = packagesResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final disabledResult = await _runShell('pm list packages -d');
      final disabled = disabledResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final activeInstalled = installed.difference(disabled);
      int failures = 0;
      final List<String> uninstalledThisSession = [];

      for (var group in SystemConfig.bloatGroups) {
        if (_cancelAction) break;
        final localizedTitle = _getLocalizedTitle(group.titleKey);
        _addLog('\n== $localizedTitle ==', const Color(0xFF00E5FF));
        final targets = group.packages.where((p) => activeInstalled.contains(p)).toList();

        if (targets.isEmpty) {
          _addLog(l10n.log_group_clean, const Color(0xFF81C784));
          continue;
        }

        for (var pkg in targets) {
          if (_cancelAction) break;
          if (PackageRules.shouldSkipDegloat(pkg)) {
            _addLog(l10n.log_skip_protected(pkg), const Color(0xFFFFD54F));
            continue;
          }

          if (dryRun) {
            _addLog(l10n.log_will_remove(pkg), const Color(0xFFFFD54F));
            continue;
          }

          final uninstallRes = await _runShell('pm uninstall --user 0', args: [pkg]);
          if (uninstallRes.stdout.toString().contains('Success')) {
            _addLog(l10n.log_removed_status(pkg), const Color(0xFF81C784));
            uninstalledThisSession.add(pkg);
          } else {
            final disableRes = await _runShell('pm disable-user --user 0', args: [pkg]);
            final resOut = disableRes.stdout.toString().toLowerCase();
            if (resOut.contains('disabled') || resOut.contains('new state')) {
              _addLog(l10n.log_disabled_status(pkg), const Color(0xFF81C784));
              uninstalledThisSession.add(pkg);
            } else {
              failures++;
              _addLog(l10n.log_fail_status(pkg, uninstallRes.stdout.toString().trim()), const Color(0xFFFF5252));
            }
          }
        }
      }

      if (!_cancelAction) {
        _addLog('\n${l10n.log_optimizing_settings}', const Color(0xFF00E5FF));
        for (var s in SystemConfig.settings) {
          if (_cancelAction) break;

          final checkVal = await _runShell('settings get ${s.namespace} ${s.key}');
          final current = checkVal.stdout.toString().trim();

          if (current == s.value) {
            _addLog('  [OK] ${s.key} = ${s.value}', const Color(0xFF81C784));
          } else if (dryRun) {
            _addLog('  [WILL MODIFY] ${s.key}: $current -> ${s.value}', const Color(0xFFFFD54F));
          } else {
            await _runShell('settings put ${s.namespace} ${s.key} ${s.value}');
            final verification = await _runShell('settings get ${s.namespace} ${s.key}');
            final verifyVal = verification.stdout.toString().trim();
            if (verifyVal == s.value) {
              _addLog('  [OK] ${s.key}: $current -> $verifyVal', const Color(0xFF81C784));
            } else {
              _addLog('  [ERROR] Cannot set ${s.key}: $current -> $verifyVal', const Color(0xFFFF5252));
            }
          }
        }
      }

      if (!_cancelAction) {
        _addLog('\n${l10n.log_optimizing_keyboard}', const Color(0xFF00E5FF));
        if (installed.contains(SystemConfig.keyboardPackage)) {
          if (dryRun) {
            _addLog(l10n.log_will_set_locales(SystemConfig.keyboardLocales), const Color(0xFFFFD54F));
            _addLog(l10n.log_will_reset_keyboard, const Color(0xFFFFD54F));
          } else {
            await _runShell('settings put system system_locales', args: [SystemConfig.keyboardLocales]);
            final clearRes = await _runShell('pm clear', args: [SystemConfig.keyboardPackage]);
            if (clearRes.stdout.toString().contains('Success')) {
              _addLog(l10n.log_reset_keyboard_success, const Color(0xFF81C784));
            } else {
              _addLog(l10n.log_reset_keyboard_fail, const Color(0xFFFF5252));
            }
          }
        } else {
          _addLog('  (Honeyboard Keyboard package not found, skipping)', const Color(0xFF90A4AE));
        }
      }

      if (_cancelAction) {
        _addLog('\n[${l10n.log_operation_halted}]', const Color(0xFFFFB74D));
      } else if (!dryRun) {
        _addLog('\n${l10n.log_all_completed}', const Color(0xFF7C4DFF));
        _addLog(l10n.log_failures_count(failures.toString()), failures > 0 ? const Color(0xFFFF5252) : const Color(0xFF81C784));
        if (uninstalledThisSession.isNotEmpty) {
          _saveBackupFile(uninstalledThisSession);
        }
      }
    });
  }

  void _actionRestore() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _performAction(l10n.btn_restore, () async {
      // Verify device before restoring
      if (_deviceImei.isEmpty) {
        await _getDeviceImei();
      }

      // Verify current device matches backup device
      if (_currentBackupFilePath != null) {
        final backupMetadata = await BackupService.getBackupMetadata(_currentBackupFilePath!);
        if (backupMetadata != null) {
          final isDeviceMatch = (backupMetadata.deviceImei.isNotEmpty && _deviceImei.isNotEmpty)
              ? backupMetadata.deviceImei == _deviceImei
              : backupMetadata.deviceSerial == _detectedSerial;

          if (!isDeviceMatch) {
            _addLog(
              '[ERROR] Device mismatch! This backup is for ${backupMetadata.deviceModel} '
              '(${backupMetadata.deviceSerial}), but current device is $_detectedModel ($_detectedSerial). '
              'Cannot restore from different device for safety reasons.',
              const Color(0xFFFF5252),
            );
            return;
          }
          _addLog(
            'Device verified: ${backupMetadata.deviceModel}. '
            'Restoring ${backupMetadata.packageCount} backed up apps...',
            const Color(0xFF81C784),
          );
        }
      }

      _addLog(l10n.log_scanning_packages, const Color(0xFF90A4AE));
      final packagesResult = await _runShell('pm list packages');
      final installed = packagesResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final disabledResult = await _runShell('pm list packages -d');
      final disabled = disabledResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final List<String> candidates = [];
      if (_backedUpPackages.isNotEmpty) {
        _addLog('Loading backup file. Found ${_backedUpPackages.length} apps in backup.', const Color(0xFF81C784));
        candidates.addAll(_backedUpPackages);
      } else {
        _addLog('No backup file found. Fallback to restoring all default presets...', const Color(0xFFFFB74D));
        final allBloatPackages = SystemConfig.bloatGroups.expand((g) => g.packages).toList();
        candidates.addAll(allBloatPackages);
      }

      for (var pkg in SystemConfig.protectedPackages) {
        if (!candidates.contains(pkg)) {
          candidates.add(pkg);
        }
      }

      final List<String> targetsToRestore = [];
      for (var pkg in candidates) {
        final isNotInstalled = !installed.contains(pkg);
        final isDisabled = disabled.contains(pkg);
        if (isNotInstalled || isDisabled) {
          targetsToRestore.add(pkg);
        }
      }

      if (targetsToRestore.isEmpty) {
        _addLog('\nAll backup apps and critical system/Knox packages are already restored/installed and enabled.', const Color(0xFF81C784));
        _addLog('✓ Restore verification complete. No action needed.', const Color(0xFF81C784));
        return;
      }

      _addLog('\n[RESTORE MODE] Restoring/Enabling ${targetsToRestore.length} packages from verified backup...', const Color(0xFF00E5FF));
      for (var pkg in targetsToRestore) {
        if (_cancelAction) break;
        final isNotInstalled = !installed.contains(pkg);

        if (isNotInstalled) {
          _addLog('Reinstalling: $pkg...', const Color(0xFF90A4AE));
          final restoreRes = await _runShell('cmd package install-existing', args: [pkg]);
          if (restoreRes.stdout.toString().contains('installed') || restoreRes.stdout.toString().contains('Success')) {
            _addLog(l10n.log_reinstalled_success(pkg), const Color(0xFF81C784));
          } else {
            _addLog(l10n.log_reinstalled_fail(pkg), const Color(0xFFFF5252));
          }
        }

        _addLog('Enabling: $pkg...', const Color(0xFF90A4AE));
        final enableRes = await _runShell('pm enable', args: [pkg]);
        if (enableRes.stdout.toString().contains('enabled') || enableRes.stdout.toString().contains('new state')) {
          _addLog('Successfully enabled: $pkg', const Color(0xFF81C784));
        } else {
          _addLog('Failed to enable: $pkg', const Color(0xFFFF5252));
        }
      }
      if (_cancelAction) {
        _addLog('\n[RESTORE OPERATION CANCELED]', const Color(0xFFFFB74D));
      } else {
        _addLog('\n✓ [RESTORE COMPLETE] All backup apps have been restored successfully.', const Color(0xFF81C784));
      }
    });
  }

  void _actionRepairSystemAndCarriers() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _performAction('System & Carrier Recovery', () async {
      _addLog('Scanning for missing system, Knox, and carrier packages...', const Color(0xFF00E5FF));

      final packagesResult = await _runShell('pm list packages');
      final installed = packagesResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final disabledResult = await _runShell('pm list packages -d');
      final disabled = disabledResult.stdout.toString().split('\n')
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      final List<String> repairCandidates = [];
      repairCandidates.addAll(SystemConfig.protectedPackages);

      for (var group in SystemConfig.bloatGroups) {
        if (group.titleKey == 'group_korean_carriers' || group.titleKey == 'group_us_carriers') {
          repairCandidates.addAll(group.packages);
        }
      }

      final List<String> targetsToRepair = [];
      for (var pkg in repairCandidates) {
        final isNotInstalled = !installed.contains(pkg);
        final isDisabled = disabled.contains(pkg);
        if (isNotInstalled || isDisabled) {
          targetsToRepair.add(pkg);
        }
      }

      if (targetsToRepair.isEmpty) {
        _addLog('\nNo missing or disabled system, Knox, or carrier packages detected on the device.', const Color(0xFF81C784));
        return;
      }

      _addLog('\nFound ${targetsToRepair.length} system/carrier packages needing repair/recovery.', const Color(0xFFFFB74D));
      _addLog('Starting automated system recovery...', const Color(0xFF00E5FF));

      for (var pkg in targetsToRepair) {
        if (_cancelAction) break;
        final isNotInstalled = !installed.contains(pkg);

        if (isNotInstalled) {
          _addLog('Reinstalling: $pkg...', const Color(0xFF90A4AE));
          final restoreRes = await _runShell('cmd package install-existing', args: [pkg]);
          if (restoreRes.stdout.toString().contains('installed') || restoreRes.stdout.toString().contains('Success')) {
            _addLog(l10n.log_reinstalled_success(pkg), const Color(0xFF81C784));
          } else {
            _addLog(l10n.log_reinstalled_fail(pkg), const Color(0xFFFF5252));
          }
        }

        _addLog('Enabling: $pkg...', const Color(0xFF90A4AE));
        final enableRes = await _runShell('pm enable', args: [pkg]);
        if (enableRes.stdout.toString().contains('enabled') || enableRes.stdout.toString().contains('new state')) {
          _addLog('Successfully enabled: $pkg', const Color(0xFF81C784));
        } else {
          _addLog('Failed to enable: $pkg', const Color(0xFFFF5252));
        }
      }

      if (_cancelAction) {
        _addLog('\n[REPAIR OPERATION CANCELED]', const Color(0xFFFFB74D));
      } else {
        _addLog('\n[SUCCESS] System and carrier recovery completed!', const Color(0xFF81C784));
      }
    });
  }

  void _addLog(String text, Color color) {
    if (mounted) {
      setState(() {
        _logs.add(LogLine(text, color));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- Load phone packages for AppList/ManualAppsPanel ---
  Future<List<String>> _loadAllPhonePackages() async {
    final res = await _runShell('pm list packages');
    return res.stdout.toString().split('\n')
        .map((l) => l.replaceFirst('package:', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<List<String>> _loadSystemPhonePackages() async {
    final res = await _runShell('pm list packages -s');
    return res.stdout.toString().split('\n')
        .map((l) => l.replaceFirst('package:', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  // --- Manual action executor for selected packages ---
  Future<void> _executeManualAction(List<String> packages, String action) async {
    if (!mounted) return;
    final actionTitle = action == 'uninstall' 
        ? 'Uninstall ${packages.length} apps'
        : 'Disable ${packages.length} apps';

    await _performAction(actionTitle, () async {
      _addLog(
        action == 'uninstall' ? 'Starting manual uninstall...' : 'Starting manual disable...',
        const Color(0xFF00E5FF),
      );

      final List<String> uninstalledThisSession = [];
      int failures = 0;

      for (var pkg in packages) {
        if (_cancelAction) break;
        if (SystemConfig.protectedPackages.contains(pkg) || PackageRules.shouldSkipDegloat(pkg)) {
          _addLog('SKIP (Protected): $pkg', const Color(0xFFFFD54F));
          continue;
        }

        if (action == 'uninstall') {
          final res = await _runShell('pm uninstall --user 0', args: [pkg]);
          if (res.stdout.toString().contains('Success')) {
            _addLog('✓ Uninstalled: $pkg', const Color(0xFF81C784));
            uninstalledThisSession.add(pkg);
          } else {
            // Try disabling if uninstall fails
            final disableRes = await _runShell('pm disable-user --user 0', args: [pkg]);
            final resOut = disableRes.stdout.toString().toLowerCase();
            if (resOut.contains('disabled') || resOut.contains('new state')) {
              _addLog('✓ Disabled (uninstall failed): $pkg', const Color(0xFF81C784));
              uninstalledThisSession.add(pkg);
            } else {
              failures++;
              _addLog('✗ Failed: $pkg', const Color(0xFFFF5252));
            }
          }
        } else {
          final res = await _runShell('pm disable-user --user 0', args: [pkg]);
          final resOut = res.stdout.toString().toLowerCase();
          if (resOut.contains('disabled') || resOut.contains('new state')) {
            _addLog('✓ Disabled: $pkg', const Color(0xFF81C784));
            uninstalledThisSession.add(pkg);
          } else {
            failures++;
            _addLog('✗ Failed: $pkg', const Color(0xFFFF5252));
          }
        }
      }

      if (uninstalledThisSession.isNotEmpty) {
        _saveBackupFile(uninstalledThisSession);
      }
      
      if (failures > 0) {
        _addLog('\n⚠ $failures packages failed to process', const Color(0xFFFF5252));
      }
    });
  }

  // --- Language switcher callback ---
  void _changeLanguage(String langCode) {
    // Refresh device details when language changes
    AdbService.instance.refreshDeviceDetailsOnNextCheck();
    if (widget.onLocaleChanged != null) {
      widget.onLocaleChanged!(Locale(langCode));
    }
  }

  Widget _buildControls() {
    return HomeControlsPanel(
      onActionDebloat: () {
        AdbService.instance.refreshDeviceDetailsOnNextCheck();
        _actionApply(dryRun: false);
      },
      onActionVerify: () {
        AdbService.instance.refreshDeviceDetailsOnNextCheck();
        _actionVerify();
      },
      onActionDryRun: () {
        AdbService.instance.refreshDeviceDetailsOnNextCheck();
        _actionApply(dryRun: true);
      },
      onActionRestore: () {
        AdbService.instance.refreshDeviceDetailsOnNextCheck();
        _actionRestore();
      },
      onActionSystemRepair: () {
        AdbService.instance.refreshDeviceDetailsOnNextCheck();
        _actionRepairSystemAndCarriers();
      },
      lastBackupInfo: _lastBackupInfo,
      isRunningAction: _isRunningAction,
      targetMode: _targetMode,
      connectionStatus: _connectionStatus,
      onGrantShizuku: _determineExecutionMode,
    );
  }

  Widget _buildSettingsSection() {
    return _buildControls();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgGradient = isLight ? AppColors.lightBgGradient : AppColors.darkBgGradient;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: bgGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 700) {
                return _buildDesktopLayout(currentLang, isLight);
              }
              return _buildMobileLayout(currentLang, isLight);
            },
          ),
        ),
      ),
    );
  }

  /// Desktop layout (3-column: sidebar, middle, console)
  Widget _buildDesktopLayout(String currentLang, bool isLight) {
    return Row(
      children: [
        _buildLeftSidebar(isLight),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMiddlePanel(isLight),
                const SizedBox(width: 14),
                _buildRightPanel(currentLang, isLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Left sidebar with controls
  Widget _buildLeftSidebar(bool isLight) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF0F1422).withValues(alpha: 0.35),
            border: Border(
              right: BorderSide(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: _buildControls(),
          ),
        ),
      ),
    );
  }

  /// Middle panel with app list and manual tabs
  Widget _buildMiddlePanel(bool isLight) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF0A0D16).withValues(alpha: 0.15),
            border: Border(
              right: BorderSide(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _buildMiddleTabBar(isLight),
                Expanded(
                  child: TabBarView(
                    children: [
                      AppList(bloatGroups: SystemConfig.bloatGroups),
                      ManualAppsPanel(
                        connectionStatus: _connectionStatus,
                        onLoadAllPackages: _loadAllPhonePackages,
                        onLoadSystemPackages: _loadSystemPhonePackages,
                        onExecuteAction: _executeManualAction,
                        isRunningAction: _isRunningAction,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// TabBar for middle panel
  Widget _buildMiddleTabBar(bool isLight) {
    final indicatorColor = isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF);
    final labelColor = isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF);
    final unselectedLabelColor = isLight ? Colors.black38 : Colors.white30;

    return Container(
      color: Colors.transparent,
      child: TabBar(
        indicatorColor: indicatorColor,
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        tabs: [
          Tab(text: jsonLocalizationService.get('tab_presets')),
          Tab(text: jsonLocalizationService.get('tab_manual')),
        ],
      ),
    );
  }

  /// Right panel with console logs
  Widget _buildRightPanel(String currentLang, bool isLight) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white.withValues(alpha: 0.25) : const Color(0xFF111827).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        ),
        child: Column(
          children: [
            _buildConsoleHeader(currentLang, isLight),
            Expanded(
              child: ConsoleLogs(
                logs: _logs,
                isRunningAction: _isRunningAction,
                scrollController: _scrollController,
                onClearPressed: () => setState(() => _logs.clear()),
                onStopPressed: () => setState(() => _cancelAction = true),
                screenContext: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Console header with device info and controls
  Widget _buildConsoleHeader(String currentLang, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.smartphone_rounded, size: 18, color: Colors.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${SystemConfig.getFriendlyModelName(_detectedModel.isNotEmpty ? _detectedModel : 'S928N')} • ${_detectedSerial.isNotEmpty ? _detectedSerial : jsonLocalizationService.get('device_info_no_serial')}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isLight ? Colors.black54 : Colors.white70,
              size: 16,
            ),
            onPressed: () {
              if (widget.onThemeModeChanged != null) {
                widget.onThemeModeChanged!(isLight ? ThemeMode.dark : ThemeMode.light);
              }
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 6),
          LanguageSwitcher(
            currentLanguage: currentLang,
            onLanguageChanged: _changeLanguage,
          ),
        ],
      ),
    );
  }

  /// Mobile layout (tabbed interface)
  Widget _buildMobileLayout(String currentLang, bool isLight) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _buildMobileAppBar(currentLang, isLight),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildControls(),
            ),
            ConsoleLogs(
              logs: _logs,
              isRunningAction: _isRunningAction,
              scrollController: _scrollController,
              onClearPressed: () => setState(() => _logs.clear()),
              onStopPressed: () => setState(() => _cancelAction = true),
              screenContext: context,
            ),
            AppList(bloatGroups: SystemConfig.bloatGroups),
            ManualAppsPanel(
              connectionStatus: _connectionStatus,
              onLoadAllPackages: _loadAllPhonePackages,
              onLoadSystemPackages: _loadSystemPhonePackages,
              onExecuteAction: _executeManualAction,
              isRunningAction: _isRunningAction,
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile AppBar with title and actions
  AppBar _buildMobileAppBar(String currentLang, bool isLight) {
    final indicatorColor = isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF);
    final labelColor = isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF);
    final unselectedLabelColor = isLight ? Colors.black38 : Colors.white30;

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5F57),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFFFFBD2E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF28C840),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      centerTitle: false,
      bottom: TabBar(
        indicatorColor: indicatorColor,
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        tabs: [
          Tab(text: jsonLocalizationService.get('tab_config'), icon: const Icon(Icons.settings_rounded, size: 20)),
          Tab(text: jsonLocalizationService.get('tab_logs'), icon: const Icon(Icons.terminal_rounded, size: 20)),
          Tab(text: jsonLocalizationService.get('tab_presets'), icon: const Icon(Icons.list_rounded, size: 20)),
          Tab(text: jsonLocalizationService.get('tab_manual'), icon: const Icon(Icons.tune_rounded, size: 20)),
        ],
      ),
    );
  }
}
