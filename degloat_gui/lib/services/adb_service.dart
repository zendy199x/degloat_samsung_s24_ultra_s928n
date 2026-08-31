import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/bloat_group.dart';

class AdbService {
  static final AdbService instance = AdbService._internal();
  AdbService._internal();

  TargetMode targetMode = TargetMode.unsupported;
  DeviceConnectionStatus connectionStatus = DeviceConnectionStatus.checking;
  String adbPath = 'adb';
  String detectedModel = '';
  String detectedModelCode = '';
  String detectedSerial = '';
  String detectedCsc = '';
  String detectedCarrier = '';
  String detectedAndroidVersion = '';
  String detectedOneUiVersion = '';
  String detectedSecurityPatch = '';
  String detectedKnoxVersion = '';
  String detectedBuildNumber = '';
  String detectedBootloader = '';
  bool isCheckingConnection = false;
  bool _shouldFetchDeviceDetailsOnNextCheck = true;

  bool isRunningAction = false;
  bool cancelAction = false;

  Timer? _monitoringTimer;

  void startStatusMonitoring(VoidCallback onTick) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      onTick();
    });
  }

  void stopStatusMonitoring() {
    _monitoringTimer?.cancel();
  }

  Future<bool> checkAndroidRoot() async {
    try {
      final result = await Process.run('su', ['-c', 'id']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static String parseOneUiVersion(String sepValue) {
    if (sepValue.isEmpty) return '';
    final val = int.tryParse(sepValue.trim());
    if (val == null) return '';
    
    // Samsung encoding changed between One UI versions:
    // Old format (One UI 5-7): 80500 => 8.05 (major=8, minor=5)
    // New format (One UI 8+): 175000 => 8.5 (encode differently)
    
    var major = val ~/ 10000;
    var minor = (val % 1000) ~/ 100;
    
    // If major > 9, it's likely new format - adjust parsing
    if (major > 9) {
      // New format: extract differently
      // 175000: subtract 9 from major digit to get correct version
      major = major - 9;
      // Extract minor from middle digits: for 175000, get 5 from positions "50"
      minor = (val % 10000) ~/ 1000;
    }
    
    // Final validation: One UI versions should be 5.x to 9.x
    if (major < 5 || major > 9 || minor < 0 || minor > 9) return '';
    return '$major.$minor';
  }

  Future<void> _fetchDeviceDetails(String? serial) async {
    try {
      Future<ProcessResult> runShellCmd(String command) async {
        if (serial == null) {
          return await runShell(command);
        } else {
          return await Process.run(adbPath, ['-s', serial, 'shell', command]);
        }
      }

      final modelRes = await runShellCmd("getprop ro.product.model");
      detectedModelCode = modelRes.stdout.toString().trim();
      detectedModel = SystemConfig.getFriendlyModelName(detectedModelCode);

      final cscRes = await runShellCmd("getprop ro.csc.sales_code");
      detectedCsc = cscRes.stdout.toString().trim();

      final carrierRes = await runShellCmd("getprop gsm.sim.operator.alpha");
      var rawCarrier = carrierRes.stdout.toString().trim();
      if (rawCarrier.isEmpty) {
        final carrierRes2 = await runShellCmd("getprop ro.carrier");
        rawCarrier = carrierRes2.stdout.toString().trim();
      }
      // Clean up carrier string: remove trailing commas and extra whitespace
      rawCarrier = rawCarrier.replaceAll(RegExp(r',\s*$'), '').trim();
      detectedCarrier = rawCarrier.isEmpty ? SystemConfig.getFriendlyCscRegion(detectedCsc) : rawCarrier;

      final androidRes = await runShellCmd("getprop ro.build.version.release");
      detectedAndroidVersion = androidRes.stdout.toString().trim();

      // Try to get One UI version directly first
      var oneUiVal = '';
      final oneUiRes = await runShellCmd("getprop ro.build.version.oneui_release");
      oneUiVal = oneUiRes.stdout.toString().trim();
      
      // If direct property returns integer only (e.g., "8"), try to get decimal part
      if (oneUiVal.isNotEmpty && !oneUiVal.contains('.')) {
        // Try alternate property for decimal part
        final oneUiFullRes = await runShellCmd("getprop ro.build.fingerprint");
        final fingerprint = oneUiFullRes.stdout.toString().trim().toLowerCase();
        // Extract from fingerprint like "samsung/s928nksu6dzh2/s928n:16/..."
        if (fingerprint.contains('oneui') || fingerprint.contains('/')) {
          // Try to find pattern like OneUI8.5
          final oneUiMatch = RegExp(r'oneui[\s_-]?(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(fingerprint);
          if (oneUiMatch != null) {
            oneUiVal = oneUiMatch.group(1) ?? oneUiVal;
          }
        }
      }
      
      // Fallback to parsing sep value if direct property doesn't work
      if (oneUiVal.isEmpty) {
        final sepRes = await runShellCmd("getprop ro.build.version.sep");
        oneUiVal = sepRes.stdout.toString().trim();
        if (oneUiVal.isNotEmpty) {
          oneUiVal = parseOneUiVersion(oneUiVal);
        }
      }
      detectedOneUiVersion = oneUiVal;

      final patchRes = await runShellCmd("getprop ro.build.version.security_patch");
      detectedSecurityPatch = patchRes.stdout.toString().trim();

      final knoxRes = await runShellCmd("getprop ro.knox.version");
      var rawKnox = knoxRes.stdout.toString().trim();
      if (rawKnox.isEmpty) {
        final knoxRes2 = await runShellCmd("getprop ro.boot.knox");
        rawKnox = knoxRes2.stdout.toString().trim();
      }
      detectedKnoxVersion = rawKnox;

      final serialRes = await runShellCmd("getprop ro.serialno");
      detectedSerial = serialRes.stdout.toString().trim();

      final buildRes = await runShellCmd("getprop ro.build.display.id");
      detectedBuildNumber = buildRes.stdout.toString().trim();

      final bootloaderRes = await runShellCmd("getprop ro.bootloader");
      detectedBootloader = bootloaderRes.stdout.toString().trim();
    } catch (_) {}
  }

  Future<void> resolveLocalModel() async {
    await _fetchDeviceDetails(null);
  }

  Future<String?> findAdbPath() async {
    if (Platform.isWindows) {
      final possiblePaths = [
        r'C:\platform-tools\adb.exe',
        r'C:\android\sdk\platform-tools\adb.exe',
        Platform.environment['ANDROID_HOME'] != null
            ? '${Platform.environment['ANDROID_HOME']}\\platform-tools\\adb.exe'
            : null,
      ];
      for (var path in possiblePaths) {
        if (path != null && File(path).existsSync()) return path;
      }
    } else {
      final possiblePaths = [
        '/opt/homebrew/bin/adb',
        '/usr/local/bin/adb',
        '/usr/bin/adb',
        Platform.environment['HOME'] != null
            ? '${Platform.environment['HOME']}/Library/Android/sdk/platform-tools/adb'
            : null,
      ];
      for (var path in possiblePaths) {
        if (path != null && File(path).existsSync()) return path;
      }
    }
    return null;
  }

  Future<ProcessResult> runShell(String command, {List<String>? args}) async {
    if (targetMode == TargetMode.localRoot) {
      final suArgs = ['-c', '$command ${(args ?? []).join(" ")}'];
      return await Process.run('su', suArgs);
    } else if (targetMode == TargetMode.localShizuku) {
      final fullCommand = "$command ${(args ?? []).join(" ")}";
      try {
        final Map<dynamic, dynamic>? res = await const MethodChannel("com.degloat.app/shizuku")
            .invokeMethod("execute", {"command": fullCommand});
        final exitCode = res?['exitCode'] ?? -1;
        final stdout = res?['stdout'] ?? '';
        final stderr = res?['stderr'] ?? '';
        return ProcessResult(0, exitCode, stdout, stderr);
      } catch (e) {
        return ProcessResult(0, -1, '', e.toString());
      }
    } else {
      final List<String> adbArgs = [];
      if (detectedSerial.isNotEmpty) {
        adbArgs.addAll(['-s', detectedSerial]);
      }
      adbArgs.add('shell');
      adbArgs.add("$command ${(args ?? []).join(" ")}");
      return await Process.run(adbPath, adbArgs);
    }
  }

  Future<void> determineExecutionMode(
    BuildContext context, 
    Function(String, Color) logCb, 
    VoidCallback stateCb
  ) async {
    final l10n = AppLocalizations.of(context)!;
    logCb(l10n.system_check_start, const Color(0xFF90A4AE));

    // Ensure device details are fetched on initial connection
    _shouldFetchDeviceDetailsOnNextCheck = true;

    if (kIsWeb) {
      targetMode = TargetMode.unsupported;
      connectionStatus = DeviceConnectionStatus.localNoRoot;
      logCb(l10n.platform_web_warning, const Color(0xFFFFB74D));
      logCb(l10n.platform_web_hint, const Color(0xFF00E5FF));
      stateCb();
      return;
    }

    if (Platform.isAndroid) {
      logCb(l10n.platform_android_local, const Color(0xFF90A4AE));
      final hasRoot = await checkAndroidRoot();
      if (hasRoot) {
        targetMode = TargetMode.localRoot;
        connectionStatus = DeviceConnectionStatus.localRootAvailable;
        logCb("${l10n.status_title_rooted}: ${l10n.status_subtitle_rooted}", const Color(0xFF81C784));
        await resolveLocalModel();
      } else {
        logCb("Root not available, checking Shizuku status...", const Color(0xFF90A4AE));
        bool shizukuAvail = false;
        try {
          shizukuAvail = await const MethodChannel("com.degloat.app/shizuku").invokeMethod<bool>("isAvailable") ?? false;
        } catch (_) {}

        if (shizukuAvail) {
          bool hasPermission = false;
          try {
            hasPermission = await const MethodChannel("com.degloat.app/shizuku").invokeMethod<bool>("checkPermission") ?? false;
          } catch (_) {}

          targetMode = TargetMode.localShizuku;
          connectionStatus = hasPermission 
              ? DeviceConnectionStatus.localShizukuAvailable 
              : DeviceConnectionStatus.localNoRoot;

          if (hasPermission) {
            logCb("Shizuku service detected and authorized!", const Color(0xFF81C784));
            await resolveLocalModel();
          } else {
            logCb("Shizuku service detected, but permission not granted. Please authorize in settings.", const Color(0xFFFFB74D));
          }
        } else {
          targetMode = TargetMode.unsupported;
          connectionStatus = DeviceConnectionStatus.localNoRoot;
          logCb(l10n.status_title_no_root, const Color(0xFFFFB74D));
          logCb(l10n.status_subtitle_no_root, const Color(0xFF00E5FF));
        }
      }
      stateCb();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      targetMode = TargetMode.desktopAdb;
      logCb(l10n.platform_desktop(Platform.operatingSystem), const Color(0xFF90A4AE));
      
      final locatedAdb = await findAdbPath();
      if (locatedAdb != null) {
        adbPath = locatedAdb;
        logCb("ADB Path: $adbPath", const Color(0xFF81C784));
      } else {
        logCb("ADB Path: default system command 'adb'", const Color(0xFFFFB74D));
      }
      
      // Check for connected devices
      await checkConnection(stateCb);
    } else {
      targetMode = TargetMode.unsupported;
      connectionStatus = DeviceConnectionStatus.disconnected;
      logCb(l10n.platform_ios_unsupported, const Color(0xFFFF5252));
      stateCb();
    }
  }

  Future<void> checkConnection(VoidCallback stateCb) async {
    if (isCheckingConnection) return;
    isCheckingConnection = true;

    if (targetMode == TargetMode.localRoot || targetMode == TargetMode.localShizuku) {
      if (targetMode == TargetMode.localShizuku) {
        bool hasPermission = false;
        try {
          hasPermission = await const MethodChannel("com.degloat.app/shizuku")
              .invokeMethod<bool>("checkPermission") ?? false;
        } catch (_) {}

        connectionStatus = hasPermission 
            ? DeviceConnectionStatus.localShizukuAvailable 
            : DeviceConnectionStatus.localNoRoot;
      }
      isCheckingConnection = false;
      stateCb();
      return;
    }

    try {
      final result = await Process.run(adbPath, ['devices']);
      if (result.exitCode != 0) {
        connectionStatus = DeviceConnectionStatus.adbNotFound;
        isCheckingConnection = false;
        stateCb();
        return;
      }

      final lines = result.stdout.toString().split('\n');
      final devices = <String>[];
      final unauths = <String>[];

      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('List of devices')) continue;

        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final serial = parts[0].trim();
          final state = parts[1].trim();
          if (state == 'device') {
            devices.add(serial);
          } else if (state == 'unauthorized') {
            unauths.add(serial);
          }
        }
      }

      if (devices.isEmpty) {
        connectionStatus = unauths.isNotEmpty ? DeviceConnectionStatus.unauthorized : DeviceConnectionStatus.disconnected;
        detectedSerial = unauths.isNotEmpty ? unauths.first : '';
        detectedModel = '';
        isCheckingConnection = false;
        stateCb();
        return;
      }

      final serial = devices.first;
      final modelResult = await Process.run(adbPath, ['-s', serial, 'shell', 'getprop ro.product.model']);
      final rawModel = modelResult.stdout.toString().trim();

      final brandResult = await Process.run(adbPath, ['-s', serial, 'shell', 'getprop ro.product.brand']);
      final manufacturerResult = await Process.run(adbPath, ['-s', serial, 'shell', 'getprop ro.product.manufacturer']);
      final brand = brandResult.stdout.toString().toLowerCase().trim();
      final manufacturer = manufacturerResult.stdout.toString().toLowerCase().trim();
      final isSamsung = brand.contains('samsung') || manufacturer.contains('samsung') || SystemConfig.expectedModelsRegExp.hasMatch(rawModel);

      detectedSerial = serial;
      
      // Always fetch device details when connected (or when flag is set)
      if (_shouldFetchDeviceDetailsOnNextCheck) {
        await _fetchDeviceDetails(serial);
      } else if (detectedModel.isEmpty) {
        // Fallback: if no model detected yet, fetch now
        await _fetchDeviceDetails(serial);
      }
      _shouldFetchDeviceDetailsOnNextCheck = false;
      
      connectionStatus = isSamsung 
          ? DeviceConnectionStatus.connectedCorrectModel 
          : DeviceConnectionStatus.connectedWrongModel;
      isCheckingConnection = false;
      stateCb();  // Always rebuild UI with latest status and device details
    } catch (_) {
      connectionStatus = DeviceConnectionStatus.adbNotFound;
      isCheckingConnection = false;
      stateCb();
    }
  }

  /// Force a refresh of device details on the next connection check
  void refreshDeviceDetailsOnNextCheck() {
    _shouldFetchDeviceDetailsOnNextCheck = true;
  }

  Future<List<String>> loadAllPhonePackages() async {
    final res = await runShell("pm list packages");
    return res.stdout.toString().split('\n')
        .map((l) => l.replaceFirst('package:', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<List<String>> loadSystemPhonePackages() async {
    final res = await runShell("pm list packages -s");
    return res.stdout.toString().split('\n')
        .map((l) => l.replaceFirst('package:', '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
}
