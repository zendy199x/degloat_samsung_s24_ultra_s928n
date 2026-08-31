import 'package:flutter/material.dart';

import '../models/bloat_group.dart';
import '../services/adb_service.dart';
import '../services/json_localization_service.dart';
import 'status_card.dart';

class DeviceStatusPanel extends StatelessWidget {
  const DeviceStatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final service = AdbService.instance;

    Color statusColor;
    String statusTitle;
    String statusSubtitle;
    IconData icon;
    bool isPulse = false;

    switch (service.connectionStatus) {
      case DeviceConnectionStatus.checking:
        statusColor = isLight ? Colors.blue.shade400 : Colors.cyan.shade600;
        statusTitle = jsonLocalizationService.get('status_title_checking');
        statusSubtitle = service.targetMode == TargetMode.localRoot
            ? jsonLocalizationService.get('status_subtitle_checking_root')
            : jsonLocalizationService.get('status_subtitle_checking_usb');
        icon = Icons.sync_rounded;
        isPulse = true;
        break;
      case DeviceConnectionStatus.disconnected:
        statusColor = isLight ? Colors.red.shade400 : Colors.red.shade600;
        statusTitle = jsonLocalizationService.get('status_title_disconnected');
        statusSubtitle = jsonLocalizationService.get('status_subtitle_disconnected');
        icon = Icons.usb_off_rounded;
        break;
      case DeviceConnectionStatus.unauthorized:
        statusColor = isLight ? Colors.amber.shade400 : Colors.amber.shade600;
        statusTitle = jsonLocalizationService.get('status_title_unauthorized');
        statusSubtitle = jsonLocalizationService.get('status_subtitle_unauthorized');
        icon = Icons.vpn_key_rounded;
        isPulse = true;
        break;
      case DeviceConnectionStatus.connectedCorrectModel:
        statusColor = isLight ? Colors.green.shade400 : Colors.green.shade600;
        statusTitle = jsonLocalizationService.get('status_title_connected', params: {'model': service.detectedModel});
        statusSubtitle = jsonLocalizationService.get('status_subtitle_connected');
        icon = Icons.phone_android_rounded;
        break;
      case DeviceConnectionStatus.connectedWrongModel:
        statusColor = isLight ? Colors.amber.shade400 : Colors.amber.shade600;
        statusTitle = jsonLocalizationService.get('status_title_wrong_model');
        statusSubtitle = jsonLocalizationService.get('status_title_wrong_model_detail', params: {'model': service.detectedModel});
        icon = Icons.warning_rounded;
        break;
      case DeviceConnectionStatus.localRootAvailable:
        statusColor = isLight ? Colors.green.shade400 : Colors.green.shade600;
        statusTitle = jsonLocalizationService.get('status_title_rooted');
        statusSubtitle = "${jsonLocalizationService.get('status_subtitle_rooted')} (${service.detectedModel})";
        icon = Icons.bolt_rounded;
        break;
      case DeviceConnectionStatus.localShizukuAvailable:
        statusColor = isLight ? Colors.cyan.shade400 : Colors.cyan.shade700;
        statusTitle = jsonLocalizationService.get('status_title_shizuku');
        statusSubtitle = "${jsonLocalizationService.get('status_subtitle_shizuku')} (${service.detectedModel})";
        icon = Icons.offline_bolt_rounded;
        break;
      case DeviceConnectionStatus.localNoRoot:
        if (service.targetMode == TargetMode.localShizuku) {
          statusColor = isLight ? Colors.amber.shade400 : Colors.amber.shade600;
          statusTitle = jsonLocalizationService.get('status_title_no_root');
          statusSubtitle = jsonLocalizationService.get('status_subtitle_shizuku_unauthorized');
          icon = Icons.security_rounded;
          isPulse = true;
        } else {
          statusColor = isLight ? Colors.amber.shade400 : Colors.amber.shade600;
          statusTitle = jsonLocalizationService.get('status_title_no_root');
          statusSubtitle = jsonLocalizationService.get('status_subtitle_no_root');
          icon = Icons.info_outline_rounded;
        }
        break;
      case DeviceConnectionStatus.adbNotFound:
        statusColor = const Color(0xFFFF5252);
        statusTitle = jsonLocalizationService.get('status_title_no_adb');
        statusSubtitle = jsonLocalizationService.get('status_subtitle_no_adb');
        icon = Icons.error_outline_rounded;
        break;
    }

    final bool isConnected = service.connectionStatus == DeviceConnectionStatus.connectedCorrectModel ||
        service.connectionStatus == DeviceConnectionStatus.connectedWrongModel ||
        service.connectionStatus == DeviceConnectionStatus.localRootAvailable ||
        service.connectionStatus == DeviceConnectionStatus.localShizukuAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusCard(
          statusColor: statusColor,
          statusTitle: statusTitle,
          statusSubtitle: statusSubtitle,
          icon: icon,
          isPulsing: isPulse,
          isChecking: service.isCheckingConnection,
          onRefresh: service.targetMode == TargetMode.unsupported ? null : () => service.checkConnection(() {}),
        ),
        if (isConnected && service.detectedModelCode.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withValues(alpha: 0.52) : const Color(0xFF141B2A).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isLight ? Colors.black.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isLight ? Colors.black : Colors.black).withValues(alpha: isLight ? 0.04 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    jsonLocalizationService.get('device_info_section_title'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isLight ? Colors.black38 : Colors.white38,
                    ),
                  ),
                ),
                if (service.detectedSerial.isNotEmpty) ...[
                  _buildInfoRow(jsonLocalizationService.get('device_info_serial'), service.detectedSerial, isLight),
                  _buildDivider(isLight),
                ],
                _buildInfoRow(jsonLocalizationService.get('device_info_model_name'), service.detectedModel, isLight),
                _buildDivider(isLight),
                _buildInfoRow(jsonLocalizationService.get('device_info_model_code'), service.detectedModelCode, isLight),
                _buildDivider(isLight),
                _buildInfoRow(jsonLocalizationService.get('device_info_csc'), service.detectedCsc, isLight),
                _buildDivider(isLight),
                _buildInfoRow(jsonLocalizationService.get('device_info_carrier'), service.detectedCarrier, isLight),
                _buildDivider(isLight),
                _buildInfoRow(jsonLocalizationService.get('device_info_android_version'), 'Android ${service.detectedAndroidVersion}', isLight),
                if (service.detectedOneUiVersion.isNotEmpty) ...[
                  _buildDivider(isLight),
                  _buildInfoRow(
                    jsonLocalizationService.get('device_info_one_ui_version'),
                    'One UI ${service.detectedOneUiVersion}',
                    isLight,
                  ),
                ],
                if (service.detectedSecurityPatch.isNotEmpty) ...[
                  _buildDivider(isLight),
                  _buildInfoRow(
                    jsonLocalizationService.get('device_info_security_patch'),
                    service.detectedSecurityPatch,
                    isLight,
                  ),
                ],
                if (service.detectedKnoxVersion.isNotEmpty) ...[
                  _buildDivider(isLight),
                  _buildInfoRow(
                    jsonLocalizationService.get('device_info_knox_status'),
                    'v${service.detectedKnoxVersion}',
                    isLight,
                  ),
                ],
                if (service.detectedBuildNumber.isNotEmpty) ...[
                  _buildDivider(isLight),
                  _buildInfoRow(
                    jsonLocalizationService.get('device_info_build_number'),
                    service.detectedBuildNumber,
                    isLight,
                  ),
                ],
                if (service.detectedBootloader.isNotEmpty) ...[
                  _buildDivider(isLight),
                  _buildInfoRow('Bootloader', service.detectedBootloader, isLight),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 98,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.black54 : Colors.white60,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isLight ? Colors.black87 : Colors.white70,
                letterSpacing: -0.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isLight) {
    return Divider(
      height: 8,
      thickness: 0.6,
      color: isLight ? Colors.black.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.06),
    );
  }
}
