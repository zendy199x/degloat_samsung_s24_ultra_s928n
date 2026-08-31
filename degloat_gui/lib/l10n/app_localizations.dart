import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'GalaxyCare Debloater'**
  String get app_title;

  /// No description provided for @app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Samsung Debloat & Optimize'**
  String get app_subtitle;

  /// No description provided for @status_title_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get status_title_checking;

  /// No description provided for @status_subtitle_checking_root.
  ///
  /// In en, this message translates to:
  /// **'Verifying root permission'**
  String get status_subtitle_checking_root;

  /// No description provided for @status_subtitle_checking_usb.
  ///
  /// In en, this message translates to:
  /// **'Finding phone via USB'**
  String get status_subtitle_checking_usb;

  /// No description provided for @status_title_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Phone Not Connected'**
  String get status_title_disconnected;

  /// No description provided for @status_subtitle_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Connect USB cable and enable USB Debugging'**
  String get status_subtitle_disconnected;

  /// No description provided for @status_title_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Device Unauthorized'**
  String get status_title_unauthorized;

  /// No description provided for @status_subtitle_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Allow\' on your phone\'s screen'**
  String get status_subtitle_unauthorized;

  /// No description provided for @status_title_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected {model}'**
  String status_title_connected(String model);

  /// No description provided for @status_subtitle_connected.
  ///
  /// In en, this message translates to:
  /// **'ADB USB connection active'**
  String get status_subtitle_connected;

  /// No description provided for @status_title_wrong_model.
  ///
  /// In en, this message translates to:
  /// **'Connected different model'**
  String get status_title_wrong_model;

  /// No description provided for @status_title_wrong_model_detail.
  ///
  /// In en, this message translates to:
  /// **'Model: {model} (Requires Note, S, Z Fold, Z Flip)'**
  String status_title_wrong_model_detail(String model);

  /// No description provided for @status_title_rooted.
  ///
  /// In en, this message translates to:
  /// **'Phone Rooted'**
  String get status_title_rooted;

  /// No description provided for @status_subtitle_rooted.
  ///
  /// In en, this message translates to:
  /// **'Running locally | ROOT permission granted'**
  String get status_subtitle_rooted;

  /// No description provided for @status_title_no_root.
  ///
  /// In en, this message translates to:
  /// **'Device not ROOTED'**
  String get status_title_no_root;

  /// No description provided for @status_subtitle_no_root.
  ///
  /// In en, this message translates to:
  /// **'Use a computer and USB cable to debloat'**
  String get status_subtitle_no_root;

  /// No description provided for @status_title_no_adb.
  ///
  /// In en, this message translates to:
  /// **'ADB Not Found'**
  String get status_title_no_adb;

  /// No description provided for @status_subtitle_no_adb.
  ///
  /// In en, this message translates to:
  /// **'Android SDK needs to be installed on computer'**
  String get status_subtitle_no_adb;

  /// No description provided for @mode_label_root.
  ///
  /// In en, this message translates to:
  /// **'Mode: Running locally with ROOT shell'**
  String get mode_label_root;

  /// No description provided for @mode_label_adb.
  ///
  /// In en, this message translates to:
  /// **'Mode: Computer connected via ADB USB'**
  String get mode_label_adb;

  /// No description provided for @mode_label_unsupported.
  ///
  /// In en, this message translates to:
  /// **'Mode: View Only (Commands not supported)'**
  String get mode_label_unsupported;

  /// No description provided for @actions_header.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actions_header;

  /// No description provided for @btn_debloat.
  ///
  /// In en, this message translates to:
  /// **'DEBLOAT & OPTIMIZE'**
  String get btn_debloat;

  /// No description provided for @btn_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify System Status'**
  String get btn_verify;

  /// No description provided for @btn_dry_run.
  ///
  /// In en, this message translates to:
  /// **'Simulate (Dry Run)'**
  String get btn_dry_run;

  /// No description provided for @btn_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore All Deleted Apps'**
  String get btn_restore;

  /// No description provided for @btn_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get btn_stop;

  /// No description provided for @btn_clear_logs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get btn_clear_logs;

  /// No description provided for @btn_copy_logs.
  ///
  /// In en, this message translates to:
  /// **'Copy Logs'**
  String get btn_copy_logs;

  /// No description provided for @warning_message_mobile.
  ///
  /// In en, this message translates to:
  /// **'Please run this app on a ROOTED phone, or run on a computer connected to the phone via USB.'**
  String get warning_message_mobile;

  /// No description provided for @warning_message_desktop.
  ///
  /// In en, this message translates to:
  /// **'Please connect Samsung Galaxy Note, S, Z Fold, Z Flip via USB with USB Debugging enabled.'**
  String get warning_message_desktop;

  /// No description provided for @tab_config.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tab_config;

  /// No description provided for @tab_logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get tab_logs;

  /// No description provided for @tab_app_list.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get tab_app_list;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_system;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settings_on;

  /// No description provided for @settings_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settings_off;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_english;

  /// No description provided for @settings_vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get settings_vietnamese;

  /// No description provided for @settings_advanced_options.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get settings_advanced_options;

  /// No description provided for @settings_advanced_options_desc.
  ///
  /// In en, this message translates to:
  /// **'Show additional settings'**
  String get settings_advanced_options_desc;

  /// No description provided for @settings_confirm_before_uninstall.
  ///
  /// In en, this message translates to:
  /// **'Confirm Before Uninstall'**
  String get settings_confirm_before_uninstall;

  /// No description provided for @settings_auto_backup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get settings_auto_backup;

  /// No description provided for @settings_show_package_details.
  ///
  /// In en, this message translates to:
  /// **'Show Package Details'**
  String get settings_show_package_details;

  /// No description provided for @manual_filter_user.
  ///
  /// In en, this message translates to:
  /// **'User Apps'**
  String get manual_filter_user;

  /// No description provided for @manual_select_all.
  ///
  /// In en, this message translates to:
  /// **'Select All ({count})'**
  String manual_select_all(String count);

  /// No description provided for @manual_no_device.
  ///
  /// In en, this message translates to:
  /// **'No device connected or apps loaded'**
  String get manual_no_device;

  /// No description provided for @manual_no_search.
  ///
  /// In en, this message translates to:
  /// **'No packages match search'**
  String get manual_no_search;

  /// No description provided for @manual_protected_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Protected security/Knox package'**
  String get manual_protected_tooltip;

  /// No description provided for @manual_app_type_system.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get manual_app_type_system;

  /// No description provided for @manual_app_type_user.
  ///
  /// In en, this message translates to:
  /// **'USER'**
  String get manual_app_type_user;

  /// No description provided for @console_header.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get console_header;

  /// No description provided for @console_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No activity logs yet.'**
  String get console_empty_title;

  /// No description provided for @console_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an action on the left to start.'**
  String get console_empty_subtitle;

  /// No description provided for @console_empty_subtitle_unsupported.
  ///
  /// In en, this message translates to:
  /// **'View the list of optimizable apps in the \'Presets\' tab'**
  String get console_empty_subtitle_unsupported;

  /// No description provided for @app_list_title.
  ///
  /// In en, this message translates to:
  /// **'Optimizable Apps List'**
  String get app_list_title;

  /// No description provided for @app_list_total.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} apps'**
  String app_list_total(String count);

  /// No description provided for @app_list_group_suffix.
  ///
  /// In en, this message translates to:
  /// **'bloatware apps'**
  String get app_list_group_suffix;

  /// No description provided for @copied_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard!'**
  String get copied_snackbar;

  /// No description provided for @system_check_start.
  ///
  /// In en, this message translates to:
  /// **'Starting system diagnostics...'**
  String get system_check_start;

  /// No description provided for @platform_web_warning.
  ///
  /// In en, this message translates to:
  /// **'Platform: Web. Hardware access limited by browser sandboxing.'**
  String get platform_web_warning;

  /// No description provided for @platform_web_hint.
  ///
  /// In en, this message translates to:
  /// **'Tip: Build as a desktop app or run directly on a rooted Android device.'**
  String get platform_web_hint;

  /// No description provided for @platform_android_local.
  ///
  /// In en, this message translates to:
  /// **'Platform: Android (running locally on device).'**
  String get platform_android_local;

  /// No description provided for @platform_desktop.
  ///
  /// In en, this message translates to:
  /// **'Platform: Computer ({os}). Connecting via ADB...'**
  String platform_desktop(String os);

  /// No description provided for @platform_ios_unsupported.
  ///
  /// In en, this message translates to:
  /// **'OS does not support running shell commands.'**
  String get platform_ios_unsupported;

  /// No description provided for @knox_guard_active.
  ///
  /// In en, this message translates to:
  /// **'Knox & System Guard Active'**
  String get knox_guard_active;

  /// No description provided for @knox_guard_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Knox keys, OTA updates, and Download Mode modules are strictly protected from deletion.'**
  String get knox_guard_tooltip;

  /// No description provided for @group_korean_carriers.
  ///
  /// In en, this message translates to:
  /// **'Korean Carriers (SKT / KT / LGU+)'**
  String get group_korean_carriers;

  /// No description provided for @group_us_carriers.
  ///
  /// In en, this message translates to:
  /// **'US Carriers (T-Mobile / Verizon / AT&T)'**
  String get group_us_carriers;

  /// No description provided for @group_korean_us_apps.
  ///
  /// In en, this message translates to:
  /// **'Korean & US Apps & Ads'**
  String get group_korean_us_apps;

  /// No description provided for @group_korean_locales.
  ///
  /// In en, this message translates to:
  /// **'Korean Language Packs'**
  String get group_korean_locales;

  /// No description provided for @group_smart_suggestions.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get group_smart_suggestions;

  /// No description provided for @group_samsung_wallet.
  ///
  /// In en, this message translates to:
  /// **'Samsung Wallet & Digital Key (Korean)'**
  String get group_samsung_wallet;

  /// No description provided for @group_samsung_bloat.
  ///
  /// In en, this message translates to:
  /// **'Samsung Bloats & Utilities'**
  String get group_samsung_bloat;

  /// No description provided for @group_meta_ms.
  ///
  /// In en, this message translates to:
  /// **'Meta & Microsoft Preloads'**
  String get group_meta_ms;

  /// No description provided for @group_bixby.
  ///
  /// In en, this message translates to:
  /// **'Bixby Voice & Assistants'**
  String get group_bixby;

  /// No description provided for @group_game_launcher.
  ///
  /// In en, this message translates to:
  /// **'Game Launcher & Services'**
  String get group_game_launcher;

  /// No description provided for @group_samsung_services.
  ///
  /// In en, this message translates to:
  /// **'Samsung Services & Push'**
  String get group_samsung_services;

  /// No description provided for @group_bluetooth_beacons.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Beacons & Marketing'**
  String get group_bluetooth_beacons;

  /// No description provided for @group_telemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry & Diagnostics'**
  String get group_telemetry;

  /// No description provided for @log_scanning_packages.
  ///
  /// In en, this message translates to:
  /// **'Scanning system packages...'**
  String get log_scanning_packages;

  /// No description provided for @log_debloat_audit.
  ///
  /// In en, this message translates to:
  /// **'== SYSTEM DEBLOAT AUDIT =='**
  String get log_debloat_audit;

  /// No description provided for @log_group_clean.
  ///
  /// In en, this message translates to:
  /// **'  (Group is completely clean)'**
  String get log_group_clean;

  /// No description provided for @log_audit_summary.
  ///
  /// In en, this message translates to:
  /// **'== AUDIT SUMMARY =='**
  String get log_audit_summary;

  /// No description provided for @log_packages_removed.
  ///
  /// In en, this message translates to:
  /// **'  Debloated: {removed}/{total} packages removed'**
  String log_packages_removed(String removed, String total);

  /// No description provided for @log_critical_missing.
  ///
  /// In en, this message translates to:
  /// **'  ⚠ WARNING: Critical system packages are MISSING:'**
  String get log_critical_missing;

  /// No description provided for @log_restore_recommended.
  ///
  /// In en, this message translates to:
  /// **'      - {pkg} (Restore recommended immediately)'**
  String log_restore_recommended(String pkg);

  /// No description provided for @log_system_safety_ok.
  ///
  /// In en, this message translates to:
  /// **'  Core System Safety: OK (All critical packages present)'**
  String get log_system_safety_ok;

  /// No description provided for @log_optimizing_settings.
  ///
  /// In en, this message translates to:
  /// **'== Optimizing settings =='**
  String get log_optimizing_settings;

  /// No description provided for @log_optimizing_keyboard.
  ///
  /// In en, this message translates to:
  /// **'== Optimizing Samsung Keyboard (Honeyboard) =='**
  String get log_optimizing_keyboard;

  /// No description provided for @log_restore_system_packages.
  ///
  /// In en, this message translates to:
  /// **'== Reinstalling original system packages =='**
  String get log_restore_system_packages;

  /// No description provided for @log_reinstalled_success.
  ///
  /// In en, this message translates to:
  /// **'  [OK] Reinstalled {pkg}'**
  String log_reinstalled_success(String pkg);

  /// No description provided for @log_reinstalled_fail.
  ///
  /// In en, this message translates to:
  /// **'  [FAIL] Failed to restore {pkg}'**
  String log_reinstalled_fail(String pkg);

  /// No description provided for @log_operation_halted.
  ///
  /// In en, this message translates to:
  /// **'OPERATION HALTED BY USER'**
  String get log_operation_halted;

  /// No description provided for @log_all_completed.
  ///
  /// In en, this message translates to:
  /// **'== ALL TASKS COMPLETED =='**
  String get log_all_completed;

  /// No description provided for @log_failures_count.
  ///
  /// In en, this message translates to:
  /// **'Number of packages with uninstall errors: {count}'**
  String log_failures_count(String count);

  /// No description provided for @log_installed_status.
  ///
  /// In en, this message translates to:
  /// **'  [INSTALLED] {pkg}'**
  String log_installed_status(String pkg);

  /// No description provided for @log_will_remove.
  ///
  /// In en, this message translates to:
  /// **'  [WILL REMOVE] {pkg}'**
  String log_will_remove(String pkg);

  /// No description provided for @log_removed_status.
  ///
  /// In en, this message translates to:
  /// **'  [REMOVED] {pkg}'**
  String log_removed_status(String pkg);

  /// No description provided for @log_disabled_status.
  ///
  /// In en, this message translates to:
  /// **'  [DISABLED] {pkg}'**
  String log_disabled_status(String pkg);

  /// No description provided for @log_fail_status.
  ///
  /// In en, this message translates to:
  /// **'  [FAIL] {pkg}: {error}'**
  String log_fail_status(String pkg, String error);

  /// No description provided for @log_will_set_locales.
  ///
  /// In en, this message translates to:
  /// **'  [WILL SET] system_locales = {locales}'**
  String log_will_set_locales(String locales);

  /// No description provided for @log_will_reset_keyboard.
  ///
  /// In en, this message translates to:
  /// **'  [WILL RESET] Reset Samsung Keyboard input layouts'**
  String get log_will_reset_keyboard;

  /// No description provided for @log_reset_keyboard_success.
  ///
  /// In en, this message translates to:
  /// **'  [RESET] Samsung Keyboard reset done'**
  String get log_reset_keyboard_success;

  /// No description provided for @log_reset_keyboard_fail.
  ///
  /// In en, this message translates to:
  /// **'  [FAIL] Failed to reset Keyboard layout'**
  String get log_reset_keyboard_fail;

  /// No description provided for @log_skip_protected.
  ///
  /// In en, this message translates to:
  /// **'  [SKIP] {pkg} is in the core system protection list (Knox/SOS/NFC Safeguard)'**
  String log_skip_protected(String pkg);

  /// No description provided for @tab_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get tab_manual;

  /// No description provided for @tab_presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get tab_presets;

  /// No description provided for @search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search package...'**
  String get search_placeholder;

  /// No description provided for @btn_load_apps.
  ///
  /// In en, this message translates to:
  /// **'Load Device Apps'**
  String get btn_load_apps;

  /// No description provided for @btn_uninstall_selected.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Checked ({count})'**
  String btn_uninstall_selected(String count);

  /// No description provided for @btn_disable_selected.
  ///
  /// In en, this message translates to:
  /// **'Disable Checked ({count})'**
  String btn_disable_selected(String count);

  /// No description provided for @btn_enable_selected.
  ///
  /// In en, this message translates to:
  /// **'Enable Checked ({count})'**
  String btn_enable_selected(String count);

  /// No description provided for @filter_system.
  ///
  /// In en, this message translates to:
  /// **'System Apps'**
  String get filter_system;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get filter_all;

  /// No description provided for @protected_badge.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protected_badge;

  /// No description provided for @log_manual_uninstall_start.
  ///
  /// In en, this message translates to:
  /// **'Starting manual uninstall for selected packages...'**
  String get log_manual_uninstall_start;

  /// No description provided for @log_manual_disable_start.
  ///
  /// In en, this message translates to:
  /// **'Starting manual disable for selected packages...'**
  String get log_manual_disable_start;

  /// No description provided for @log_manual_enable_start.
  ///
  /// In en, this message translates to:
  /// **'Starting manual activation for selected packages...'**
  String get log_manual_enable_start;

  /// No description provided for @status_title_shizuku.
  ///
  /// In en, this message translates to:
  /// **'Connected via Shizuku'**
  String get status_title_shizuku;

  /// No description provided for @status_subtitle_shizuku.
  ///
  /// In en, this message translates to:
  /// **'Running locally without ROOT | Shizuku authorized'**
  String get status_subtitle_shizuku;

  /// No description provided for @status_subtitle_shizuku_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Shizuku detected | Click \'Grant Shizuku\' to authorize'**
  String get status_subtitle_shizuku_unauthorized;

  /// No description provided for @btn_grant_shizuku.
  ///
  /// In en, this message translates to:
  /// **'Grant Shizuku Permission'**
  String get btn_grant_shizuku;

  /// No description provided for @warning_message_shizuku.
  ///
  /// In en, this message translates to:
  /// **'Please start the Shizuku app on your phone, or grant permission to this app to execute commands.'**
  String get warning_message_shizuku;

  /// No description provided for @device_info_model_name.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get device_info_model_name;

  /// No description provided for @device_info_model_code.
  ///
  /// In en, this message translates to:
  /// **'Model Code'**
  String get device_info_model_code;

  /// No description provided for @device_info_csc.
  ///
  /// In en, this message translates to:
  /// **'CSC Sales Code'**
  String get device_info_csc;

  /// No description provided for @device_info_carrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier Network'**
  String get device_info_carrier;

  /// No description provided for @device_info_connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get device_info_connection;

  /// No description provided for @btn_system_repair.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & KNOX RECOVERY'**
  String get btn_system_repair;

  /// No description provided for @btn_system_repair_desc.
  ///
  /// In en, this message translates to:
  /// **'Restore and enable Knox, security, and carrier-specific packages (US/Korea)'**
  String get btn_system_repair_desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
