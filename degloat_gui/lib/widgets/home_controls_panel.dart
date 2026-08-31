import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/bloat_group.dart';
import 'action_button.dart';
import 'device_status_panel.dart';
import 'knox_badge.dart';

class HomeControlsPanel extends StatefulWidget {
  final VoidCallback onActionDebloat;
  final VoidCallback onActionVerify;
  final VoidCallback onActionDryRun;
  final VoidCallback onActionRestore;
  final VoidCallback onActionSystemRepair;
  final String lastBackupInfo;
  final bool isRunningAction;
  final TargetMode targetMode;
  final DeviceConnectionStatus connectionStatus;
  final Function()? onGrantShizuku;

  const HomeControlsPanel({
    required this.onActionDebloat,
    required this.onActionVerify,
    required this.onActionDryRun,
    required this.onActionRestore,
    required this.onActionSystemRepair,
    required this.lastBackupInfo,
    required this.isRunningAction,
    required this.targetMode,
    required this.connectionStatus,
    this.onGrantShizuku,
    super.key,
  });

  @override
  State<HomeControlsPanel> createState() => _HomeControlsPanelState();
}

class _HomeControlsPanelState extends State<HomeControlsPanel> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool canRun = widget.connectionStatus == DeviceConnectionStatus.connectedCorrectModel ||
        widget.connectionStatus == DeviceConnectionStatus.localRootAvailable ||
        widget.connectionStatus == DeviceConnectionStatus.localShizukuAvailable;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeviceStatusPanel(),
        const SizedBox(height: 12),
        const KnoxBadge(),
        const SizedBox(height: 14),
        _buildModeIndicator(l10n, isLight),
        if (widget.targetMode == TargetMode.localShizuku && widget.connectionStatus == DeviceConnectionStatus.localNoRoot) ...[
          const SizedBox(height: 12),
          ActionButton(
            label: l10n.btn_grant_shizuku,
            icon: Icons.vpn_key_rounded,
            color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
            textColor: isLight ? Colors.white : Colors.black,
            onPressed: () async {
              try {
                await const MethodChannel('com.degloat.app/shizuku').invokeMethod('requestPermission');
                widget.onGrantShizuku?.call();
              } catch (_) {}
            },
          ),
        ],
        const SizedBox(height: 18),
        _buildActionsHeader(l10n),
        const SizedBox(height: 10),
        _buildActionButton(
          label: l10n.btn_debloat,
          icon: Icons.flash_on_rounded,
          color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
          isEnabled: canRun && !widget.isRunningAction,
          onPressed: widget.onActionDebloat,
          context: context,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          label: l10n.btn_verify,
          icon: Icons.checklist_rtl_rounded,
          color: isLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.06),
          textColor: isLight ? Colors.black87 : Colors.white,
          isEnabled: canRun && !widget.isRunningAction,
          onPressed: widget.onActionVerify,
          context: context,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          label: l10n.btn_dry_run,
          icon: Icons.bug_report_outlined,
          color: isLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.06),
          textColor: isLight ? Colors.black87 : Colors.white,
          isEnabled: canRun && !widget.isRunningAction,
          onPressed: widget.onActionDryRun,
          context: context,
        ),
        const SizedBox(height: 10),
        if (widget.lastBackupInfo.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFE8F7EF) : const Color(0xFF10281D).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLight ? const Color(0xFFB7E4C7) : const Color(0xFF57C98A).withValues(alpha: 0.24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.backup_table_rounded, color: isLight ? const Color(0xFF1C8C5C) : const Color(0xFF9BE5B4), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.lastBackupInfo,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF1C8C5C) : const Color(0xFF9BE5B4),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        _buildActionButton(
          label: l10n.btn_restore,
          icon: Icons.restore_rounded,
          color: isLight ? const Color(0xFFE9F0FF) : const Color(0xFF1B2439),
          textColor: isLight ? const Color(0xFF2F5BFF) : const Color(0xFF8CB9FF),
          isEnabled: canRun && !widget.isRunningAction,
          onPressed: widget.onActionRestore,
          context: context,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          label: l10n.btn_system_repair,
          icon: Icons.healing_rounded,
          color: isLight ? const Color(0xFFE7F7FF) : const Color(0xFF102A36),
          textColor: isLight ? const Color(0xFF0A84FF) : const Color(0xFF7DD3FC),
          isEnabled: canRun && !widget.isRunningAction,
          onPressed: widget.onActionSystemRepair,
          context: context,
        ),
        const SizedBox(height: 20),
        if (!canRun) _buildWarningBox(l10n, context),
      ],
    );
  }

  Widget _buildModeIndicator(AppLocalizations l10n, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withValues(alpha: 0.48) : const Color(0xFF111827).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLight ? Colors.black.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: (isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF)).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.targetMode == TargetMode.localRoot || widget.targetMode == TargetMode.localShizuku
                  ? Icons.offline_bolt_rounded
                  : widget.targetMode == TargetMode.desktopAdb
                      ? Icons.computer_rounded
                      : Icons.cloud_off_rounded,
              color: isLight ? const Color(0xFF00B0FF) : const Color(0xFF00E5FF),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.targetMode == TargetMode.localRoot
                  ? l10n.mode_label_root
                  : widget.targetMode == TargetMode.localShizuku
                      ? l10n.status_title_shizuku
                      : widget.targetMode == TargetMode.desktopAdb
                          ? l10n.mode_label_adb
                          : l10n.mode_label_unsupported,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsHeader(AppLocalizations l10n) {
    return Text(
      l10n.actions_header,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).brightness == Brightness.light ? Colors.black38 : Colors.white38,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback onPressed,
    required BuildContext context,
    Color? textColor,
  }) {
    return ActionButton(
      label: label,
      icon: icon,
      color: color,
      textColor: textColor ?? Colors.black,
      isLoading: widget.isRunningAction,
      onPressed: isEnabled ? onPressed : null,
    );
  }

  Widget _buildWarningBox(AppLocalizations l10n, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFF8E1) : const Color(0xFF332B16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLight ? const Color(0xFFE0C97D) : const Color(0xFFE0B75E).withValues(alpha: 0.26)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: isLight ? const Color(0xFF9A6A00) : const Color(0xFFF5D58A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.targetMode == TargetMode.localShizuku
                  ? l10n.warning_message_shizuku
                  : widget.targetMode == TargetMode.unsupported
                      ? l10n.warning_message_mobile
                      : l10n.warning_message_desktop,
              style: TextStyle(
                color: isLight ? const Color(0xFF9A6A00) : const Color(0xFFF3D89E),
                fontSize: 10.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
