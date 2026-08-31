// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get app_title => 'GalaxyCare Debloater';

  @override
  String get app_subtitle => 'Dọn rác & Tối ưu Samsung';

  @override
  String get status_title_checking => 'Đang kiểm tra...';

  @override
  String get status_subtitle_checking_root => 'Đang xác minh quyền root';

  @override
  String get status_subtitle_checking_usb => 'Đang quét điện thoại qua USB';

  @override
  String get status_title_disconnected => 'Chưa kết nối điện thoại';

  @override
  String get status_subtitle_disconnected =>
      'Hãy cắm cáp USB và bật Gỡ lỗi USB (USB debugging)';

  @override
  String get status_title_unauthorized => 'Thiết bị chưa cấp quyền';

  @override
  String get status_subtitle_unauthorized =>
      'Hãy nhấn \'Cho phép\' trên màn hình điện thoại';

  @override
  String status_title_connected(String model) {
    return 'Đã kết nối $model';
  }

  @override
  String get status_subtitle_connected => 'Kết nối ADB USB hoạt động';

  @override
  String get status_title_wrong_model => 'Kết nối sai dòng máy';

  @override
  String status_title_wrong_model_detail(String model) {
    return 'Model: $model (Yêu cầu Note, S, Z Fold, Z Flip)';
  }

  @override
  String get status_title_rooted => 'Điện thoại đã Root';

  @override
  String get status_subtitle_rooted => 'Chạy cục bộ | Đã cấp quyền ROOT';

  @override
  String get status_title_no_root => 'Thiết bị chưa ROOT';

  @override
  String get status_subtitle_no_root => 'Hãy dùng máy tính cắm cáp để dọn rác';

  @override
  String get status_title_no_adb => 'Không tìm thấy ADB';

  @override
  String get status_subtitle_no_adb => 'Cần cài đặt Android SDK trên máy tính';

  @override
  String get mode_label_root => 'Chế độ: Chạy cục bộ bằng quyền ROOT';

  @override
  String get mode_label_adb => 'Chế độ: Máy tính kết nối qua ADB USB';

  @override
  String get mode_label_unsupported =>
      'Chế độ: Chỉ xem (Không hỗ trợ chạy lệnh)';

  @override
  String get actions_header => 'THAO TÁC';

  @override
  String get btn_debloat => 'DỌN RÁC & TỐI ƯU HÓA';

  @override
  String get btn_verify => 'Kiểm tra hiện trạng máy';

  @override
  String get btn_dry_run => 'Chạy thử (Dry Run)';

  @override
  String get btn_restore => 'Khôi phục mọi ứng dụng đã gỡ';

  @override
  String get btn_stop => 'Dừng lại';

  @override
  String get btn_clear_logs => 'Xoá Logs';

  @override
  String get btn_copy_logs => 'Sao chép Logs';

  @override
  String get warning_message_mobile =>
      'Ứng dụng này cần chạy trên điện thoại đã ROOT, hoặc chạy trên máy tính và kết nối điện thoại qua cổng USB để thực thi.';

  @override
  String get warning_message_desktop =>
      'Vui lòng kết nối Samsung Galaxy Note, S, Z Fold, Z Flip thông qua cáp USB và mở USB Debugging.';

  @override
  String get tab_config => 'Cấu hình';

  @override
  String get tab_logs => 'Logs';

  @override
  String get tab_app_list => 'Mẫu sẵn';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_system => 'Hệ thống';

  @override
  String get settings_dark_mode => 'Chế độ tối';

  @override
  String get settings_on => 'Bật';

  @override
  String get settings_off => 'Tắt';

  @override
  String get settings_language => 'Ngôn ngữ';

  @override
  String get settings_english => 'English';

  @override
  String get settings_vietnamese => 'Tiếng Việt';

  @override
  String get settings_advanced_options => 'Tùy chọn nâng cao';

  @override
  String get settings_advanced_options_desc => 'Hiển thị cài đặt bổ sung';

  @override
  String get settings_confirm_before_uninstall => 'Xác nhận trước khi gỡ';

  @override
  String get settings_auto_backup => 'Sao lưu tự động';

  @override
  String get settings_show_package_details => 'Hiển thị chi tiết gói';

  @override
  String get manual_filter_user => 'Ứng dụng của người dùng';

  @override
  String manual_select_all(String count) {
    return 'Chọn tất cả ($count)';
  }

  @override
  String get manual_no_device => 'Chưa kết nối thiết bị hoặc chưa tải ứng dụng';

  @override
  String get manual_no_search => 'Không có gói nào phù hợp với tìm kiếm';

  @override
  String get manual_protected_tooltip => 'Gói bảo mật/Knox được bảo vệ';

  @override
  String get manual_app_type_system => 'HỆ THỐNG';

  @override
  String get manual_app_type_user => 'NGƯỜI DÙNG';

  @override
  String get console_header => 'Hoạt động Logs';

  @override
  String get console_empty_title => 'Chưa có ghi chép lịch sử.';

  @override
  String get console_empty_subtitle =>
      'Nhấn thao tác bên trái để bắt đầu kiểm tra và dọn rác.';

  @override
  String get console_empty_subtitle_unsupported =>
      'Xem danh sách các ứng dụng tối ưu bên tab \'Mẫu sẵn\'';

  @override
  String get app_list_title => 'Danh Sách Ứng Dụng Tối Ưu';

  @override
  String app_list_total(String count) {
    return 'Tổng số: $count ứng dụng';
  }

  @override
  String get app_list_group_suffix => 'ứng dụng rác';

  @override
  String get copied_snackbar => 'Đã sao chép nhật ký vào Clipboard!';

  @override
  String get system_check_start => 'Khởi động chẩn đoán hệ thống...';

  @override
  String get platform_web_warning =>
      'Nền tảng: Web. Quyền truy cập phần cứng bị giới hạn bởi Trình duyệt.';

  @override
  String get platform_web_hint =>
      'Gợi ý: Hãy cài đặt ứng dụng trên máy tính hoặc chạy trực tiếp trên điện thoại Android.';

  @override
  String get platform_android_local =>
      'Phát hiện nền tảng: Android (chạy trực tiếp trên thiết bị).';

  @override
  String platform_desktop(String os) {
    return 'Phát hiện nền tảng: Máy tính ($os). Đang kết nối...';
  }

  @override
  String get platform_ios_unsupported =>
      'Hệ điều hành không hỗ trợ chạy lệnh shell.';

  @override
  String get knox_guard_active => 'Knox & Bảo Vệ Hệ Thống Bật';

  @override
  String get knox_guard_tooltip =>
      'Khóa Knox, OTA và Download Mode được bảo vệ tuyệt đối không bị ảnh hưởng.';

  @override
  String get group_korean_carriers => 'Nhà mạng Hàn (SKT / KT / LG U+)';

  @override
  String get group_us_carriers => 'Nhà mạng Mỹ (T-Mobile / Verizon / AT&T)';

  @override
  String get group_korean_us_apps => 'App riêng máy Hàn & Mỹ & Quảng cáo';

  @override
  String get group_korean_locales => 'Tài nguyên tiếng Hàn';

  @override
  String get group_smart_suggestions => 'Gợi ý thông minh (Smart Suggestions)';

  @override
  String get group_samsung_wallet => 'Samsung Wallet & Digital Key (bản Hàn)';

  @override
  String get group_samsung_bloat => 'App Samsung rác & Tính năng phụ';

  @override
  String get group_meta_ms => 'Dịch vụ Meta & Microsoft cài sẵn';

  @override
  String get group_bixby => 'Bixby Voice & Trợ lý ảo';

  @override
  String get group_game_launcher => 'Game Launcher rác';

  @override
  String get group_samsung_services => 'Dịch vụ Samsung phụ & Liên kết ngầm';

  @override
  String get group_bluetooth_beacons =>
      'Dịch vụ quảng cáo Bluetooth Beacon & Định vị ngầm';

  @override
  String get group_telemetry => 'Telemetry / thu thập dữ liệu';

  @override
  String get log_scanning_packages => 'Đang quét các gói hệ thống...';

  @override
  String get log_debloat_audit => '== KIỂM TRA HỆ THỐNG DỌN RÁC ==';

  @override
  String get log_group_clean => '  (Nhóm ứng dụng đã hoàn toàn sạch)';

  @override
  String get log_audit_summary => '== TỔNG KẾT KIỂM TRA ==';

  @override
  String log_packages_removed(String removed, String total) {
    return '  Đã dọn dẹp: Đã gỡ $removed/$total gói ứng dụng';
  }

  @override
  String get log_critical_missing =>
      '  ⚠ CẢNH BÁO: Các gói hệ thống quan trọng bị THIẾU:';

  @override
  String log_restore_recommended(String pkg) {
    return '      - $pkg (Khuyến nghị khôi phục ngay lập tức)';
  }

  @override
  String get log_system_safety_ok =>
      '  An toàn hệ thống: OK (Đầy đủ các gói quan trọng)';

  @override
  String get log_optimizing_settings =>
      '== Đang tối ưu hóa các thiết lập... ==';

  @override
  String get log_optimizing_keyboard =>
      '== Đang tối ưu hóa Bàn phím Samsung (Honeyboard)... ==';

  @override
  String get log_restore_system_packages =>
      '== Đang khôi phục các gói hệ thống gốc... ==';

  @override
  String log_reinstalled_success(String pkg) {
    return '  [OK] Đã khôi phục $pkg';
  }

  @override
  String log_reinstalled_fail(String pkg) {
    return '  [LỖI] Khôi phục thất bại $pkg';
  }

  @override
  String get log_operation_halted => 'THAO TÁC BỊ DỪNG BỞI NGƯỜI DÙNG';

  @override
  String get log_all_completed => '== ĐÃ HOÀN THÀNH TẤT CẢ THAO TÁC ==';

  @override
  String log_failures_count(String count) {
    return 'Số gói lỗi không thể gỡ: $count';
  }

  @override
  String log_installed_status(String pkg) {
    return '  [ĐÃ CÀI ĐẶT] $pkg';
  }

  @override
  String log_will_remove(String pkg) {
    return '  [SẼ GỠ BỎ] $pkg';
  }

  @override
  String log_removed_status(String pkg) {
    return '  [ĐÃ GỠ BỎ] $pkg';
  }

  @override
  String log_disabled_status(String pkg) {
    return '  [ĐÃ VÔ HIỆU HÓA] $pkg';
  }

  @override
  String log_fail_status(String pkg, String error) {
    return '  [LỖI] $pkg: $error';
  }

  @override
  String log_will_set_locales(String locales) {
    return '  [SẼ THIẾT LẬP] system_locales = $locales';
  }

  @override
  String get log_will_reset_keyboard =>
      '  [SẼ THIẾT LẬP LẠI] Đặt lại bố cục bàn phím Samsung';

  @override
  String get log_reset_keyboard_success =>
      '  [RESET] Đã hoàn thành đặt lại bàn phím Samsung';

  @override
  String get log_reset_keyboard_fail =>
      '  [LỖI] Không thể đặt lại bố cục Bàn phím';

  @override
  String log_skip_protected(String pkg) {
    return '  [BỎ QUA] $pkg nằm trong danh sách bảo vệ hệ thống (Knox/SOS/NFC Safeguard)';
  }

  @override
  String get tab_manual => 'Gỡ thủ công';

  @override
  String get tab_presets => 'Mẫu sẵn';

  @override
  String get search_placeholder => 'Tìm kiếm gói...';

  @override
  String get btn_load_apps => 'Tải danh sách ứng dụng';

  @override
  String btn_uninstall_selected(String count) {
    return 'Gỡ mục đã chọn ($count)';
  }

  @override
  String btn_disable_selected(String count) {
    return 'Tắt mục đã chọn ($count)';
  }

  @override
  String btn_enable_selected(String count) {
    return 'Bật mục đã chọn ($count)';
  }

  @override
  String get filter_system => 'Ứng dụng hệ thống';

  @override
  String get filter_all => 'Tất cả ứng dụng';

  @override
  String get protected_badge => 'Bảo vệ';

  @override
  String get log_manual_uninstall_start =>
      'Bắt đầu gỡ bỏ thủ công các gói đã chọn...';

  @override
  String get log_manual_disable_start =>
      'Bắt đầu vô hiệu hóa thủ công các gói đã chọn...';

  @override
  String get log_manual_enable_start =>
      'Bắt đầu kích hoạt thủ công các gói đã chọn...';

  @override
  String get status_title_shizuku => 'Đã kết nối qua Shizuku';

  @override
  String get status_subtitle_shizuku =>
      'Chạy cục bộ không ROOT | Đã cấp quyền Shizuku';

  @override
  String get status_subtitle_shizuku_unauthorized =>
      'Phát hiện Shizuku | Nhấn \'Cấp quyền Shizuku\' để bắt đầu';

  @override
  String get btn_grant_shizuku => 'Cấp quyền Shizuku';

  @override
  String get warning_message_shizuku =>
      'Vui lòng mở ứng dụng Shizuku trên điện thoại và cấp quyền cho app này để chạy các lệnh.';

  @override
  String get device_info_model_name => 'Tên Thiết Bị';

  @override
  String get device_info_model_code => 'Mã Máy';

  @override
  String get device_info_csc => 'Mã Vùng CSC';

  @override
  String get device_info_carrier => 'Nhà Mạng';

  @override
  String get device_info_connection => 'Kiểu Kết Nối';

  @override
  String get btn_system_repair => 'KHÔI PHỤC & SỬA LỖI KNOX';

  @override
  String get btn_system_repair_desc =>
      'Khôi phục và kích hoạt lại các gói Knox, Bảo mật, và Nhà mạng (Mỹ, Hàn Quốc)';
}
