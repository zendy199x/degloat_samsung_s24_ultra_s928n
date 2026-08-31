// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'GalaxyCare Debloater';

  @override
  String get app_subtitle => 'Samsung Debloat & Optimize';

  @override
  String get status_title_checking => 'Checking...';

  @override
  String get status_subtitle_checking_root => 'Verifying root permission';

  @override
  String get status_subtitle_checking_usb => 'Finding phone via USB';

  @override
  String get status_title_disconnected => 'Phone Not Connected';

  @override
  String get status_subtitle_disconnected =>
      'Connect USB cable and enable USB Debugging';

  @override
  String get status_title_unauthorized => 'Device Unauthorized';

  @override
  String get status_subtitle_unauthorized =>
      'Tap \'Allow\' on your phone\'s screen';

  @override
  String status_title_connected(String model) {
    return 'Connected $model';
  }

  @override
  String get status_subtitle_connected => 'ADB USB connection active';

  @override
  String get status_title_wrong_model => 'Connected different model';

  @override
  String status_title_wrong_model_detail(String model) {
    return 'Model: $model (Requires Note, S, Z Fold, Z Flip)';
  }

  @override
  String get status_title_rooted => 'Phone Rooted';

  @override
  String get status_subtitle_rooted =>
      'Running locally | ROOT permission granted';

  @override
  String get status_title_no_root => 'Device not ROOTED';

  @override
  String get status_subtitle_no_root =>
      'Use a computer and USB cable to debloat';

  @override
  String get status_title_no_adb => 'ADB Not Found';

  @override
  String get status_subtitle_no_adb =>
      'Android SDK needs to be installed on computer';

  @override
  String get mode_label_root => 'Mode: Running locally with ROOT shell';

  @override
  String get mode_label_adb => 'Mode: Computer connected via ADB USB';

  @override
  String get mode_label_unsupported =>
      'Mode: View Only (Commands not supported)';

  @override
  String get actions_header => 'ACTIONS';

  @override
  String get btn_debloat => 'DEBLOAT & OPTIMIZE';

  @override
  String get btn_verify => 'Verify System Status';

  @override
  String get btn_dry_run => 'Simulate (Dry Run)';

  @override
  String get btn_restore => 'Restore All Deleted Apps';

  @override
  String get btn_stop => 'Stop';

  @override
  String get btn_clear_logs => 'Clear Logs';

  @override
  String get btn_copy_logs => 'Copy Logs';

  @override
  String get warning_message_mobile =>
      'Please run this app on a ROOTED phone, or run on a computer connected to the phone via USB.';

  @override
  String get warning_message_desktop =>
      'Please connect Samsung Galaxy Note, S, Z Fold, Z Flip via USB with USB Debugging enabled.';

  @override
  String get tab_config => 'Settings';

  @override
  String get tab_logs => 'Logs';

  @override
  String get tab_app_list => 'Presets';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_system => 'System';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get settings_on => 'On';

  @override
  String get settings_off => 'Off';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_english => 'English';

  @override
  String get settings_vietnamese => 'Tiếng Việt';

  @override
  String get settings_advanced_options => 'Advanced Options';

  @override
  String get settings_advanced_options_desc => 'Show additional settings';

  @override
  String get settings_confirm_before_uninstall => 'Confirm Before Uninstall';

  @override
  String get settings_auto_backup => 'Auto Backup';

  @override
  String get settings_show_package_details => 'Show Package Details';

  @override
  String get manual_filter_user => 'User Apps';

  @override
  String manual_select_all(String count) {
    return 'Select All ($count)';
  }

  @override
  String get manual_no_device => 'No device connected or apps loaded';

  @override
  String get manual_no_search => 'No packages match search';

  @override
  String get manual_protected_tooltip => 'Protected security/Knox package';

  @override
  String get manual_app_type_system => 'SYSTEM';

  @override
  String get manual_app_type_user => 'USER';

  @override
  String get console_header => 'Activity Logs';

  @override
  String get console_empty_title => 'No activity logs yet.';

  @override
  String get console_empty_subtitle => 'Select an action on the left to start.';

  @override
  String get console_empty_subtitle_unsupported =>
      'View the list of optimizable apps in the \'Presets\' tab';

  @override
  String get app_list_title => 'Optimizable Apps List';

  @override
  String app_list_total(String count) {
    return 'Total: $count apps';
  }

  @override
  String get app_list_group_suffix => 'bloatware apps';

  @override
  String get copied_snackbar => 'Logs copied to clipboard!';

  @override
  String get system_check_start => 'Starting system diagnostics...';

  @override
  String get platform_web_warning =>
      'Platform: Web. Hardware access limited by browser sandboxing.';

  @override
  String get platform_web_hint =>
      'Tip: Build as a desktop app or run directly on a rooted Android device.';

  @override
  String get platform_android_local =>
      'Platform: Android (running locally on device).';

  @override
  String platform_desktop(String os) {
    return 'Platform: Computer ($os). Connecting via ADB...';
  }

  @override
  String get platform_ios_unsupported =>
      'OS does not support running shell commands.';

  @override
  String get knox_guard_active => 'Knox & System Guard Active';

  @override
  String get knox_guard_tooltip =>
      'Knox keys, OTA updates, and Download Mode modules are strictly protected from deletion.';

  @override
  String get group_korean_carriers => 'Korean Carriers (SKT / KT / LGU+)';

  @override
  String get group_us_carriers => 'US Carriers (T-Mobile / Verizon / AT&T)';

  @override
  String get group_korean_us_apps => 'Korean & US Apps & Ads';

  @override
  String get group_korean_locales => 'Korean Language Packs';

  @override
  String get group_smart_suggestions => 'Smart Suggestions';

  @override
  String get group_samsung_wallet => 'Samsung Wallet & Digital Key (Korean)';

  @override
  String get group_samsung_bloat => 'Samsung Bloats & Utilities';

  @override
  String get group_meta_ms => 'Meta & Microsoft Preloads';

  @override
  String get group_bixby => 'Bixby Voice & Assistants';

  @override
  String get group_game_launcher => 'Game Launcher & Services';

  @override
  String get group_samsung_services => 'Samsung Services & Push';

  @override
  String get group_bluetooth_beacons => 'Bluetooth Beacons & Marketing';

  @override
  String get group_telemetry => 'Telemetry & Diagnostics';

  @override
  String get log_scanning_packages => 'Scanning system packages...';

  @override
  String get log_debloat_audit => '== SYSTEM DEBLOAT AUDIT ==';

  @override
  String get log_group_clean => '  (Group is completely clean)';

  @override
  String get log_audit_summary => '== AUDIT SUMMARY ==';

  @override
  String log_packages_removed(String removed, String total) {
    return '  Debloated: $removed/$total packages removed';
  }

  @override
  String get log_critical_missing =>
      '  ⚠ WARNING: Critical system packages are MISSING:';

  @override
  String log_restore_recommended(String pkg) {
    return '      - $pkg (Restore recommended immediately)';
  }

  @override
  String get log_system_safety_ok =>
      '  Core System Safety: OK (All critical packages present)';

  @override
  String get log_optimizing_settings => '== Optimizing settings ==';

  @override
  String get log_optimizing_keyboard =>
      '== Optimizing Samsung Keyboard (Honeyboard) ==';

  @override
  String get log_restore_system_packages =>
      '== Reinstalling original system packages ==';

  @override
  String log_reinstalled_success(String pkg) {
    return '  [OK] Reinstalled $pkg';
  }

  @override
  String log_reinstalled_fail(String pkg) {
    return '  [FAIL] Failed to restore $pkg';
  }

  @override
  String get log_operation_halted => 'OPERATION HALTED BY USER';

  @override
  String get log_all_completed => '== ALL TASKS COMPLETED ==';

  @override
  String log_failures_count(String count) {
    return 'Number of packages with uninstall errors: $count';
  }

  @override
  String log_installed_status(String pkg) {
    return '  [INSTALLED] $pkg';
  }

  @override
  String log_will_remove(String pkg) {
    return '  [WILL REMOVE] $pkg';
  }

  @override
  String log_removed_status(String pkg) {
    return '  [REMOVED] $pkg';
  }

  @override
  String log_disabled_status(String pkg) {
    return '  [DISABLED] $pkg';
  }

  @override
  String log_fail_status(String pkg, String error) {
    return '  [FAIL] $pkg: $error';
  }

  @override
  String log_will_set_locales(String locales) {
    return '  [WILL SET] system_locales = $locales';
  }

  @override
  String get log_will_reset_keyboard =>
      '  [WILL RESET] Reset Samsung Keyboard input layouts';

  @override
  String get log_reset_keyboard_success =>
      '  [RESET] Samsung Keyboard reset done';

  @override
  String get log_reset_keyboard_fail =>
      '  [FAIL] Failed to reset Keyboard layout';

  @override
  String log_skip_protected(String pkg) {
    return '  [SKIP] $pkg is in the core system protection list (Knox/SOS/NFC Safeguard)';
  }

  @override
  String get tab_manual => 'Manual';

  @override
  String get tab_presets => 'Presets';

  @override
  String get search_placeholder => 'Search package...';

  @override
  String get btn_load_apps => 'Load Device Apps';

  @override
  String btn_uninstall_selected(String count) {
    return 'Uninstall Checked ($count)';
  }

  @override
  String btn_disable_selected(String count) {
    return 'Disable Checked ($count)';
  }

  @override
  String btn_enable_selected(String count) {
    return 'Enable Checked ($count)';
  }

  @override
  String get filter_system => 'System Apps';

  @override
  String get filter_all => 'All Apps';

  @override
  String get protected_badge => 'Protected';

  @override
  String get log_manual_uninstall_start =>
      'Starting manual uninstall for selected packages...';

  @override
  String get log_manual_disable_start =>
      'Starting manual disable for selected packages...';

  @override
  String get log_manual_enable_start =>
      'Starting manual activation for selected packages...';

  @override
  String get status_title_shizuku => 'Connected via Shizuku';

  @override
  String get status_subtitle_shizuku =>
      'Running locally without ROOT | Shizuku authorized';

  @override
  String get status_subtitle_shizuku_unauthorized =>
      'Shizuku detected | Click \'Grant Shizuku\' to authorize';

  @override
  String get btn_grant_shizuku => 'Grant Shizuku Permission';

  @override
  String get warning_message_shizuku =>
      'Please start the Shizuku app on your phone, or grant permission to this app to execute commands.';

  @override
  String get device_info_model_name => 'Model Name';

  @override
  String get device_info_model_code => 'Model Code';

  @override
  String get device_info_csc => 'CSC Sales Code';

  @override
  String get device_info_carrier => 'Carrier Network';

  @override
  String get device_info_connection => 'Connection';

  @override
  String get btn_system_repair => 'SYSTEM & KNOX RECOVERY';

  @override
  String get btn_system_repair_desc =>
      'Restore and enable Knox, security, and carrier-specific packages (US/Korea)';
}
