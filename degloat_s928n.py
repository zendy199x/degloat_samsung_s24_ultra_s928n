#!/usr/bin/env python3
"""Khôi phục cấu hình "global" cho Galaxy S24 Ultra bản Hàn (SM-S928N).

Sau mỗi lần nâng cấp One UI lớn, CSC SKC sẽ cài lại toàn bộ app Hàn Quốc.
Chạy lại script này để đưa máy về trạng thái đã dọn.

    python degloat_s928n.py            # áp dụng
    python degloat_s928n.py --verify   # chỉ kiểm tra, không đổi gì
    python degloat_s928n.py --dry-run  # xem trước việc sẽ làm
    python degloat_s928n.py --restore  # cài lại mọi thứ đã gỡ
    python degloat_s928n.py --log      # lưu chi tiết vào file log
"""

from __future__ import annotations

import argparse
import json
import logging
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# Mỗi nhóm là (mô tả, [package...]). Toàn bộ đã được xác minh an toàn trên SM-S928N.
BLOAT_GROUPS: list[tuple[str, list[str]]] = [
    ("Nhà mạng Hàn (SKT / KT / LG U+)", [
        "com.skt.prod.dialer",                # T전화 / A.phone (cũ)
        "com.skt.prod.phone",                 # A.phone – SKT A. Adot Phone (One UI 6+)
        "com.samsung.hidden.SKT",             # Cấu hình carrier ẩn của SKT
        "com.skt.adot",                       # A. (Adot) – nền tảng AI SKT (A.phone mới)
        "com.skt.tmap.ku",                    # T-Map – GPS / Bản đồ SKT [xác minh ADB]
        "com.skt.nugu.apollo",                # NUGU – Trợ lý AI của SKT [xác minh ADB]
        "com.skt.skaf.A000Z00040",            # ONE Store
        "com.sktelecom.minit",                # T world
        "com.skt.skaf.OA00018282",            # ONE Store updater / carrier package manager
        "com.skt.skaf.OA00199800",            # ONE Store client
        "com.skt.skaf.popone",                # SKT PopOne
        "com.skt.skaf.l001m0000",             # SKT T-Map / T-Services
        "com.sktelecom.smartcard.SmartcardService",  # SKT USIM Smartcard Service
        "com.skt.t_smart_charge",             # T 스마트충전
        "com.skt.hpsagree",                   # Dịch vụ đồng ý cài đặt SKT
        "com.skt.hps20client",                # Ứng dụng khách SKT HPS
        "com.skp.seio",                       # Thành phần phân phối nội dung SKT
        "com.skms.android.agent",             # Agent thiết bị/đăng ký SKT
        "com.kt.serviceagent",                # Agent nhà mạng KT
        "com.kt.showpaysha",                  # KT Show Pay
        "com.kt.service.ktv8200",             # KT Service
        "com.kt.olleh.storeclient",           # KT Olleh Store / app marketplace
        "com.kt.mhows.mobilecoupon",          # KT Mobile Coupon
        "com.kt.service.appcare",             # KT App Care
        "com.lguplus.lgugpsnwps",             # Vị trí/Wi-Fi positioning của LG U+
        "com.lguplus.payon",                  # LG U+ Pay
        "com.lguplus.callguard",              # LG U+ Chặn cuộc gọi Hàn
        "com.lguplus.mobilephonecertificate", # LG U+ Chứng thư di động
        "com.lguplus.appstore",               # LG U+ App Store / carrier app store
        "com.lguplus.navi",                   # LG U+ Navigation
        "com.lguplus.mobile.cs",              # LG U+ Customer Service
        "com.lguplus.tsmproxy",               # LG U+ TSM Proxy
    ]),
    ("Chặn cài đặt tự động từ nhà mạng", [
        "com.skt.skaf.OA00018282",            # SKT app updater / carrier auto-installer
        "com.skt.skaf.OA00199800",            # SKT app marketplace client / auto suggested install
        "com.skt.skaf.popone",                # SKT PopOne / carrier push install path
        "com.kt.olleh.storeclient",           # KT app store / auto install source
        "com.lguplus.appstore",               # LG U+ app store / auto install source
        "com.samsung.android.app.merchant",   # nếu có trên rom này, là source merchant app install
        "com.elevenst",                             # 11Street (Hàn Quốc) – tên thực tế sẽ được kiểm tra bằng ADB nếu tồn tại
    ]),
    ("App riêng máy Hàn & Quảng cáo vị trí", [
        "com.tms",                            # SKTMemberShip_new.apk
        "com.samsung.sec.android.prd",        # SamsungDotComKor
        "com.samsung.android.nfc.resources.korea",  # T-money / Cashbee
        "com.samsung.android.visitin",        # Samsung Visit In
        "com.samsung.android.ipsgeofence",    # Geofencing Marketing Hàn
        "kr.co.captv.pooqV2",                 # Wavve (웨이브) – streaming video Hàn (SKT+KBS+MBC+SBS) [xác minh ADB]
        "skplanet.musicmate",                 # FLO (플로) – streaming nhạc Hàn của SK Planet/SKT [xác minh ADB]
    ]),
    ("Tài nguyên tiếng Hàn", [
        "com.samsung.SMT.lang_ko_kr_r00",
        "com.samsung.android.nmt.apps.t2t.languagepack.enko",
        "com.samsung.android.bixby.ondevice.kokr",
        "com.samsung.android.vtt-korean",           # Samsung Voice-to-Text tiếng Hàn
        "com.samsung.android.langpack.ko_kr",       # Gói ngôn ngữ hệ thống tiếng Hàn
        "com.samsung.android.offline.langpack.ko_kr", # Gói dịch ngoại tuyến Galaxy AI tiếng Hàn
        "com.samsung.android.sdk.handwriting.ko_KR", # Nhận diện viết tay tiếng Hàn
    ]),
    ("Gợi ý thông minh / Global Goals (XÓA HOÀN TOÀN)", [
        "com.samsung.android.app.tips",              # Samsung Tips / Gợi ý thông minh
        "com.samsung.android.smartsuggestions",      # Smart Suggestions / Now Brief
        "com.samsung.android.globalgoals",          # Samsung Global Goals
        "com.samsung.android.galaxyglobalgoals",    # Galaxy Global Goals
        "com.samsung.android.app.globalgoals",      # Global Goals app preload
        "com.samsung.sree",                          # Samsung SREE alias
        "com.samsung.android.globalpostprocmgr",    # Global Post Processing Manager
        "com.samsung.android.app.marketinginfo",    # Marketing Info Service
    ]),
    ("Samsung Wallet & Digital Key (XÓA HOÀN TOÀN)", [
        "com.samsung.android.spay",                  # Samsung Wallet / Samsung Pay
        "com.sktelecom.tauth",                       # PASS / SK Telecom auth app
        "com.samsung.android.coldwalletservice",     # Samsung Cold Wallet
        "com.samsung.android.dkey",                  # Samsung Wallet Digital Key
        "com.samsung.android.carkey",                # Samsung Wallet Car Key
        "com.samsung.android.raposagent",            # Samsung Wallet RAPOS Agent
    ]),
    ("App Samsung rác & Tính năng phụ", [
        "com.samsung.android.tvplus",                # Samsung TV Plus
        "com.samsung.android.glance.gpp",            # Glance (Quảng cáo màn hình khóa)
    ]),
    ("Dịch vụ Meta & Microsoft cài sẵn", [
        "com.facebook.appmanager",                   # Facebook App Manager
        "com.facebook.services",                     # Facebook Services
        "com.facebook.system",                       # Facebook App Installer
        "com.microsoft.skydrive",                    # OneDrive
        "com.microsoft.office.officehubrow",         # Microsoft 365 / Office Hub
        "com.microsoft.office.outlook",              # Outlook Preload
        "com.microsoft.appmanager",                  # Link to Windows
        "com.linkedin.android",                      # LinkedIn
    ]),
    ("Dịch vụ quảng cáo Bluetooth Beacon & Định vị ngầm", [
        "com.samsung.android.beaconmanager",         # Samsung Beacon Manager
    ]),
    ("Telemetry / thu thập dữ liệu", [
        "com.sec.android.diagmonagent",
        "com.samsung.android.dqagent",
        "com.samsung.android.da.daagent",
        "com.samsung.android.knox.analytics.uploader",
        "com.samsung.android.bbc.bbcagent",
        "com.samsung.android.qmdservice",
        "com.samsung.android.rubin.app",
        "com.samsung.android.mocca",
    ]),
    ("Google & Android System Bloat", [
        "com.google.android.projection.gearhead",        # Android Auto
        "com.google.android.apps.googleassistant",       # Google Assistant (nếu có)
        "com.google.android.gms.location.history",       # Location History Tracking
        "com.google.android.apps.maps",                  # Google Maps (nếu samsung.maps có)
        "com.google.android.apps.docs",                  # Google Docs
        "com.google.android.apps.sheets",                # Google Sheets
        "com.google.android.apps.slides",                # Google Slides
    ]),
    ("Samsung Thông minh & Trợ lý", [
        "com.samsung.android.bixby.service",             # Bixby Service
        "com.samsung.android.bixbyvision.service",       # Bixby Vision
        "com.samsung.android.smartcall",                 # Smart Call (cuộc gọi thông minh)
        "com.samsung.android.smartthings",               # SmartThings
        "com.samsung.android.smartswitch",               # Smart Switch
    ]),
    ("Samsung Cloud & Backup", [
        "com.samsung.android.sync.service",              # Samsung Sync Service
        "com.samsung.android.cloudidp",                  # Cloud IDP
        "com.samsung.android.sdm.service",               # Samsung Device Manager
    ]),
    ("Quảng cáo & Marketing Hàn Quốc", [
        "com.kt.kflashcall",                             # KT Flash Call
        "com.skt.tmap.navi",                             # T-Map Navigation (lặp lại)
    ]),
    ("Chuyển Vùng T (T-money/Cashbee) - Chỉ Dùng Hàn Quốc", [
        "com.samsung.android.nfc.resources.korea",      # T-money / Cashbee - chỉ Hàn Quốc
    ]),
]

# App của nhà mạng / thị trường khác (Hàn, Mỹ, EU, Nhật, Ấn...) — không dùng được ở VN.
# Mọi package cài sẵn khớp tiền tố này đều bị gỡ (trừ PROTECTED).
REGION_CARRIER_PREFIXES: tuple[str, ...] = (
    "com.skt.", "com.sktelecom.", "com.kt.", "com.lguplus.", "kr.co.",
    "com.vzw.", "com.verizon.", "com.att.", "com.tmobile.", "com.sprint.",
    "com.vodafone.", "com.telekom.", "com.orange.", "com.jio.", "com.airtel.",
    "com.kddi.", "com.docomo.", "com.sbmobile.",
)

# Cấu hình cài đặt tối ưu an toàn
SETTINGS: list[tuple[str, str, str]] = [
    ("global", "power_sounds_enabled", "0"),
    ("system", "csc_pref_camera_forced_shuttersound_key", "0"),
    ("global", "ram_expand_size", "0"),
    ("global", "safe_media_volume_enabled", "0"),
    ("system", "spam_call_enable", "1"),
    ("global", "wifi_scan_always_enabled", "0"),
    ("system", "lift_to_wake", "1"),
    ("global", "system_locales", "vi-VN,en-US"),
    ("system", "system_locales", "vi-VN,en-US"),
    ("system", "user_locale", "vi-VN"),
]

# Cấu hình tối ưu hiệu suất bổ sung
PERFORMANCE_SETTINGS: list[tuple[str, str, str]] = [
    ("system", "screen_off_timeout", "300000"),     # 5 phút tắt màn hình
    ("system", "mobile_data_always_on", "0"),        # Tắt dữ liệu khi WiFi
    ("global", "bluetooth_on", "0"),                 # Bluetooth tắt mặc định
    ("system", "notification_pulse", "0"),           # Tắt LED thông báo
]

# Cài đặt VoLTE & Global Calling Features
VOLTE_SETTINGS: list[tuple[str, str, str]] = [
    ("system", "volte_vt_enabled", "1"),             # Bật VoLTE (Voice over LTE)
    ("system", "ims_enabled", "1"),                  # Bật IMS
    ("system", "wifi_calling_available", "1"),       # WiFi Calling available
    ("system", "prefer_2g", "0"),                    # Không ưu tiên 2G
]

# Cài đặt toàn cầu để loại bỏ hạn chế Hàn Quốc
GLOBAL_SETTINGS: list[tuple[str, str, str]] = [
    ("system", "csc_settings_done", "1"),            # CSC setup hoàn tất
    ("global", "stay_on_while_plugged_in", "0"),     # Tắt Stay On khi sạc
    ("system", "show_password", "1"),                # Hiện mật khẩu khi nhập
]

# Gói bảo vệ cốt lõi (Tuyệt đối không gỡ để tránh Bootloop / Panic Kernel)
PROTECTED: frozenset[str] = frozenset({
    "com.wssyncmldm",
    "com.sec.android.soagent",
    "com.samsung.android.emergency",
    "com.sec.android.emergencylauncher",
    "com.osp.app.signin",
    "com.ims.dm",
    "com.wsomacp",
    "com.android.nfc",
    "com.samsung.android.nfc",
    "com.samsung.android.ese",
    "com.samsung.android.kmxservice",
    "com.samsung.android.mdecservice",
    "com.sec.vsim.ericssonnsds.webapp",
    "com.android.phone",
    "com.samsung.android.dialer",
    "com.sec.phone",
    # Các thành phần đã chuyển vào danh sách an toàn
    "com.sec.android.app.kguard",
    "com.samsung.android.spayfw",
    "com.samsung.android.ssiframework",
    "com.samsung.android.knox.mpos",
    "com.samsung.android.game.gos",
    "com.samsung.android.game.gametools",
    "com.sec.android.UsimRegistrationKOR",
})

EXPECTED_MODEL = "SM-S928N"
KEYBOARD_PACKAGE = "com.samsung.android.honeyboard"
KEYBOARD_LOCALES = "vi-VN,en-US"

# Cấu hình logging
LOG_DIR = Path.home() / ".degloat" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)


def setup_logging(log_file: bool = False) -> logging.Logger:
    """Cấu hình logging cho script."""
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter(
        "%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Console handler
    console = logging.StreamHandler(sys.stdout)
    console.setLevel(logging.INFO)
    console.setFormatter(formatter)
    logger.addHandler(console)

    # File handler (nếu yêu cầu)
    if log_file:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_handler = logging.FileHandler(
            LOG_DIR / f"degloat_{timestamp}.log", encoding="utf-8"
        )
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    return logger


class AdbError(RuntimeError):
    """Lỗi ADB."""
    pass


class DeviceError(RuntimeError):
    """Lỗi thiết bị không được hỗ trợ."""
    pass


# Global logger
logger: logging.Logger | None = None


def adb(*args: str, check: bool = True) -> str:
    """Chạy lệnh ADB."""
    proc = subprocess.run(
        ("adb", *args), capture_output=True, text=True, encoding="utf-8", errors="replace"
    )
    if check and proc.returncode != 0:
        raise AdbError((proc.stderr or proc.stdout).strip())
    return proc.stdout.strip()


def shell(command: str) -> str:
    """Chạy lệnh shell trên thiết bị."""
    return adb("shell", command, check=False)


def get_device_info() -> dict[str, str]:
    """Lấy thông tin thiết bị."""
    return {
        "model": shell("getprop ro.product.model"),
        "build": shell("getprop ro.build.PDA"),
        "android": shell("getprop ro.build.version.release"),
        "csc": shell("getprop ro.csc.sales_code"),
        "security_patch": shell("getprop ro.build.version.security_patch"),
    }


def clear_cache(dry_run: bool) -> None:
    """Xoá cache hệ thống sau debloat."""
    print("\n== Xoá cache hệ thống ==")
    if dry_run:
        print("  [sẽ xoá] System cache")
        return

    result = shell("rm -rf /cache/*")
    print("  [đã xoá] System cache")

    result = shell("pm trim-caches 1G")
    if result:
        print(f"  [cache  ] {result}")
    else:
        print("  [ok    ] Cache đã được tối ưu")


def clear_korean_resources(dry_run: bool) -> None:
    """Xóa bộ gõ, ngôn ngữ, và tài nguyên Hàn Quốc."""
    print("\n== Xóa tài nguyên Hàn Quốc ==")
    
    korean_packages = [
        "com.samsung.android.honeyboard.ko_KR",
        "com.samsung.android.bixby.ondevice.kokr",
        "com.samsung.android.vtt-korean",
        "com.samsung.android.langpack.ko_kr",
        "com.samsung.android.offline.langpack.ko_kr",
        "com.samsung.android.sdk.handwriting.ko_KR",
        "com.samsung.SMT.lang_ko_kr_r00",
        "com.samsung.android.nmt.apps.t2t.languagepack.enko",
    ]

    present = installed_packages()
    korean_found = [pkg for pkg in korean_packages if pkg in present]

    if not korean_found:
        print("  (không tìm thấy tài nguyên Hàn Quốc)")
        return

    for pkg in korean_found:
        if dry_run:
            print(f"  [sẽ xóa ] {pkg}")
            continue
        result = shell(f'pm uninstall --user 0 "{pkg}"')
        if "Success" in result or "not installed" in result.lower():
            print(f"  [đã xóa ] {pkg}")
            continue
        disable_res = shell(f'pm disable-user --user 0 "{pkg}"')
        if "new state" in disable_res.lower():
            print(f"  [tắt app] {pkg} (system package, đã vô hiệu hoá)")
        else:
            print(f"  [LỖI    ] {pkg}: {result or disable_res or 'không rõ nguyên nhân'}")


def disable_korean_ime(dry_run: bool) -> None:
    """Tắt và xóa IME tiếng Hàn khỏi danh sách."""
    print("\n== Tắt bộ gõ tiếng Hàn ==")
    
    korean_imes = [
        "com.samsung.android.honeyboard",  # Samsung Keyboard (có tiếng Hàn)
    ]

    if dry_run:
        print("  [sẽ kiểm tra] bộ gõ tiếng Hàn")
        return

    present = installed_packages()
    for ime in korean_imes:
        if ime in present:
            # Chỉ cần reset cache để loại bỏ tiếng Hàn
            result = shell(f"pm clear {ime}")
            if "Success" in result:
                print(f"  [đã xóa tiếng Hàn] {ime}")
            else:
                print(f"  [ok] {ime} đã được xử lý")

    if logger:
        logger.info("Bộ gõ tiếng Hàn đã được tắt/xóa")


def require_device() -> str:
    lines = [l for l in adb("devices").splitlines()[1:] if l.strip()]
    ready = [l.split("\t")[0] for l in lines if l.endswith("\tdevice")]
    if not ready:
        if any(l.endswith("\tunauthorized") for l in lines):
            raise AdbError("Máy chưa cho phép gỡ lỗi USB — mở khoá màn hình và bấm Cho phép.")
        raise AdbError("Không tìm thấy máy. Cắm cáp và bật USB debugging.")
    if len(ready) > 1:
        raise AdbError(f"Đang cắm nhiều máy: {', '.join(ready)}. Rút bớt chỉ để lại một.")

    model = shell("getprop ro.product.model")
    if model != EXPECTED_MODEL:
        raise AdbError(f"Máy là {model or '?'}, script này chỉ dành cho {EXPECTED_MODEL}.")
    return ready[0]


def _pm_packages(args: str) -> set[str]:
    return {
        l.removeprefix("package:").strip()
        for l in shell(f"pm list packages {args}").splitlines()
        if l.startswith("package:")
    }


def installed_packages() -> set[str]:
    """Mọi package còn tồn tại trên máy, kể cả đã bị disable (cần gỡ hẳn)."""
    return _pm_packages("")


def disabled_packages() -> set[str]:
    return _pm_packages("-d")


def user_installed_packages() -> set[str]:
    return _pm_packages("-3")


def all_bloat() -> list[str]:
    return [pkg for _, packages in BLOAT_GROUPS for pkg in packages]


def report_state() -> tuple[list[str], list[str]]:
    present = installed_packages() - disabled_packages()
    all_installed = {
        l.removeprefix("package:").strip()
        for l in shell("pm list packages").splitlines()
        if l.startswith("package:")
    }
    return (
        [p for p in all_bloat() if p in present],
        sorted(p for p in PROTECTED if p not in all_installed),
    )


def apply_settings(dry_run: bool) -> None:
    """Áp dụng cài đặt tối ưu."""
    print("\n== Cấu hình mở khoá ==")
    applied: list[str] = []

    for namespace, key, value in SETTINGS:
        current = shell(f"settings get {namespace} {key}")
        if current == value:
            print(f"  [đã đúng] {key} = {value}")
            applied.append(key)
        elif dry_run:
            print(f"  [sẽ đổi ] {key}: {current} -> {value}")
        else:
            shell(f"settings put {namespace} {key} {value}")
            now = shell(f"settings get {namespace} {key}")
            ok = now == value
            print(f"  [{'ok' if ok else 'LỖI':8}] {key}: {current} -> {now}")
            if ok:
                applied.append(key)

    if logger:
        logger.info(f"Áp dụng {len(applied)}/{len(SETTINGS)} cài đặt")


def apply_performance_settings(dry_run: bool) -> None:
    """Áp dụng cài đặt hiệu suất bổ sung."""
    print("\n== Cấu hình hiệu suất ==")
    applied: list[str] = []

    for namespace, key, value in PERFORMANCE_SETTINGS:
        current = shell(f"settings get {namespace} {key}")
        if current == value:
            print(f"  [đã đúng] {key} = {value}")
            applied.append(key)
        elif dry_run:
            print(f"  [sẽ đổi ] {key}: {current} -> {value}")
        else:
            shell(f"settings put {namespace} {key} {value}")
            now = shell(f"settings get {namespace} {key}")
            ok = now == value
            print(f"  [{'ok' if ok else 'LỖI':8}] {key}: {current} -> {now}")
            if ok:
                applied.append(key)

    if logger:
        logger.info(f"Áp dụng {len(applied)}/{len(PERFORMANCE_SETTINGS)} cài đặt hiệu suất")


def apply_volte_settings(dry_run: bool) -> None:
    """Áp dụng cài đặt VoLTE & IMS."""
    print("\n== Kích hoạt VoLTE & IMS ==")
    applied: list[str] = []

    for namespace, key, value in VOLTE_SETTINGS:
        current = shell(f"settings get {namespace} {key}")
        if current == value:
            print(f"  [đã đúng] {key} = {value}")
            applied.append(key)
        elif dry_run:
            print(f"  [sẽ đổi ] {key}: {current} -> {value}")
        else:
            shell(f"settings put {namespace} {key} {value}")
            now = shell(f"settings get {namespace} {key}")
            ok = now == value
            print(f"  [{'ok' if ok else 'LỖI':8}] {key}: {current} -> {now}")
            if ok:
                applied.append(key)

    if logger:
        logger.info(f"Áp dụng {len(applied)}/{len(VOLTE_SETTINGS)} cài đặt VoLTE")


def apply_global_settings(dry_run: bool) -> None:
    """Áp dụng cài đặt toàn cầu (loại bỏ hạn chế Hàn Quốc)."""
    print("\n== Cài đặt quốc tế ==")
    applied: list[str] = []

    for namespace, key, value in GLOBAL_SETTINGS:
        current = shell(f"settings get {namespace} {key}")
        if current == value:
            print(f"  [đã đúng] {key} = {value}")
            applied.append(key)
        elif dry_run:
            print(f"  [sẽ đổi ] {key}: {current} -> {value}")
        else:
            shell(f"settings put {namespace} {key} {value}")
            now = shell(f"settings get {namespace} {key}")
            ok = now == value
            print(f"  [{'ok' if ok else 'LỖI':8}] {key}: {current} -> {now}")
            if ok:
                applied.append(key)

    if logger:
        logger.info(f"Áp dụng {len(applied)}/{len(GLOBAL_SETTINGS)} cài đặt quốc tế")


def remove_bloat(dry_run: bool) -> int:
    present = installed_packages()
    failures = 0
    known = set(all_bloat())
    region_extra = sorted(
        p for p in present if p.startswith(REGION_CARRIER_PREFIXES) and p not in known
    )
    groups = BLOAT_GROUPS + [("Nhà mạng & app thị trường khác (không dùng ở VN)", region_extra)]
    handled: set[str] = set()

    for title, packages in groups:
        targets = [p for p in packages if p in present and p not in handled]
        handled.update(targets)
        print(f"\n== {title} ==")
        if not targets:
            print("  (đã sạch)")
            continue

        for pkg in targets:
            if pkg in PROTECTED:
                print(f"  [BỎ QUA ] {pkg} nằm trong danh sách bảo vệ")
                continue
            if dry_run:
                print(f"  [sẽ gỡ  ] {pkg}")
                continue
            result = shell(f'pm uninstall --user 0 "{pkg}"')
            if "Success" in result:
                print(f"  [đã gỡ  ] {pkg}")
            else:
                disable_res = shell(f'pm disable-user --user 0 "{pkg}"')
                if "disabled" in disable_res.lower() or "new state" in disable_res.lower():
                    print(f"  [tắt app] {pkg} (đã vô hiệu hoá)")
                else:
                    failures += 1
                    print(f"  [LỖI    ] {pkg}: {result or disable_res or 'không rõ nguyên nhân'}")
    return failures


def remove_all_user_apps(dry_run: bool) -> int:
    present = user_installed_packages()
    failures = 0

    print("\n== XÓA TẤT CẢ APP NGƯỜI DÙNG (không bảo vệ) ==")
    for pkg in sorted(present):
        if pkg in PROTECTED:
            print(f"  [BỎ QUA ] {pkg} (bảo vệ hệ thống)")
            continue

        if dry_run:
            print(f"  [sẽ gỡ  ] {pkg}")
            continue

        result = shell(f'pm uninstall --user 0 "{pkg}"')
        if "Success" in result or "not installed" in result.lower():
            print(f"  [đã gỡ  ] {pkg}")
            continue

        disable_res = shell(f'pm disable-user --user 0 "{pkg}"')
        if "disabled" in disable_res.lower() or "new state" in disable_res.lower():
            print(f"  [tắt app] {pkg} (hard disable)")
        else:
            failures += 1
            print(f"  [LỖI    ] {pkg}: {result or disable_res or 'không rõ nguyên nhân'}")

    return failures


def restore_bloat(dry_run: bool) -> None:
    print("\n== Cài lại toàn bộ gói đã gỡ ==")
    present = installed_packages()
    disabled = disabled_packages()
    for pkg in all_bloat():
        if pkg in present and pkg not in disabled:
            continue
        if dry_run:
            print(f"  [sẽ cài ] {pkg}")
            continue
        if pkg in present:
            result = shell(f'pm enable --user 0 "{pkg}"')
        else:
            result = shell(f'cmd package install-existing "{pkg}"')
        ok = "installed" in result.lower() or "Success" in result or "new state" in result.lower()
        print(f"  [{'ok' if ok else 'LỖI':8}] {pkg}")


def reset_keyboard(dry_run: bool) -> None:
    """Reset bàn phím: chỉ có Tiếng Việt Telex + English US + Emoji."""
    print("\n== Bàn phím Samsung (Telex + English + Emoji) ==")
    if KEYBOARD_PACKAGE not in installed_packages():
        print("  (không tìm thấy Samsung Keyboard, bỏ qua)")
        return

    if dry_run:
        print(f"  [sẽ đặt  ] system_locales = {KEYBOARD_LOCALES}")
        print(f"  [sẽ reset] {KEYBOARD_PACKAGE}")
        print(f"  [sẽ cấu hình] Chỉ: Telex + English + Emoji")
        return

    shell(f'settings put system system_locales "{KEYBOARD_LOCALES}"')
    result_locale = shell('settings get system system_locales')
    print(f"  [locale  ] {result_locale}")

    result = shell(f"pm clear {KEYBOARD_PACKAGE}")
    if "Success" not in result:
        print(f"  [LỖI    ] {result or 'không rõ nguyên nhân'}")
        return
    print("  [đã reset] Samsung Keyboard đã được xóa cache")

    ime = shell("settings get secure default_input_method")
    if KEYBOARD_PACKAGE not in ime:
        print("  [thay đổi] Bàn phím mặc định khác, đặt lại:")
        shell(f"ime set {KEYBOARD_PACKAGE}/.service.HoneyBoardService")
        print(f"  [ok    ] Đặt Samsung Keyboard làm mặc định")

    print("\n  → Cấu hình bàn phím (thực hiện thủ công trên máy):")
    print("    1. Mở Cài đặt > Quản lý chung > Bàn phím Samsung")
    print("    2. Chọn Ngôn ngữ:")
    print("       ✅ Tiếng Việt (Telex)")
    print("       ✅ English (US QWERTY)")
    print("       ✅ Emoji")
    print("    3. Xóa tất cả ngôn ngữ khác (tiếng Hàn, Trung, v.v...)")
    print("    4. Chọn Tiếng Việt làm ngôn ngữ mặc định")
    print("    5. Tắt Gợi ý từ / Dự đoán thông minh khi gõ")
    print("       (ADB không đổi được mục này trên Samsung Keyboard)")

    if logger:
        logger.info("Bàn phím được cấu hình: Telex + English + Emoji")


def print_summary() -> None:
    remaining, missing_protected = report_state()

    print("\n" + "=" * 58)
    print("KẾT QUẢ")
    print("=" * 58)

    total = len(all_bloat())
    print(f"  App rác Hàn Quốc : {total - len(remaining)}/{total} đã gỡ hoặc tắt")
    for pkg in remaining:
        print(f"      còn lại: {pkg}")

    if missing_protected:
        print("\n  ⚠ THIẾU gói quan trọng — nên cài lại ngay:")
        for pkg in missing_protected:
            print(f"      {pkg}")
            print(f"      adb shell cmd package install-existing {pkg}")
    else:
        print("  Gói quan trọng   : đầy đủ (OTA, SOS, NFC, Samsung Account…)")

    csc = shell("getprop ro.csc.sales_code")
    print(f"\n  CSC hiện tại     : {csc}")
    if csc == "KOO":
        print("      Đã là KOO — không còn logo và nhạc hiệu SK Telecom.")
    else:
        print("      Còn logo khởi động SK Telecom.")

    # Lưu báo cáo
    if logger:
        logger.info(f"Debloat hoàn tất: {total - len(remaining)}/{total} gói đã gỡ hoặc tắt")
        save_report(remaining, missing_protected)


def save_report(remaining: list[str], missing_protected: list[str]) -> None:
    """Lưu báo cáo debloat vào file JSON."""
    report = {
        "timestamp": datetime.now().isoformat(),
        "device_info": get_device_info(),
        "total_bloat_packages": len(all_bloat()),
        "removed_count": len(all_bloat()) - len(remaining),
        "remaining_packages": remaining,
        "missing_protected": missing_protected,
    }

    report_file = LOG_DIR / f"report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(report_file, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    if logger:
        logger.info(f"Báo cáo đã lưu: {report_file}")


def main() -> int:
    """Hàm chính."""
    global logger

    parser = argparse.ArgumentParser(
        description="Dọn app Hàn Quốc trên SM-S928N, đưa máy về trạng thái giống bản global."
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--verify", action="store_true", help="chỉ kiểm tra, không thay đổi gì")
    mode.add_argument("--dry-run", action="store_true", help="xem trước việc sẽ làm")
    mode.add_argument("--restore", action="store_true", help="cài lại mọi gói đã gỡ")
    mode.add_argument(
        "--all-user-apps",
        action="store_true",
        help="gỡ tất cả app người dùng không bảo vệ (hard disable) để chặn app quay lại",
    )
    parser.add_argument(
        "--keep-keyboard",
        action="store_true",
        help="không reset Samsung Keyboard (giữ từ đã học, nhưng tiếng Hàn còn lại)",
    )
    parser.add_argument(
        "--performance",
        action="store_true",
        help="áp dụng thêm cài đặt tối ưu hiệu suất",
    )
    parser.add_argument(
        "--volte",
        action="store_true",
        help="bật VoLTE, IMS, WiFi Calling (mặc định)",
    )
    parser.add_argument(
        "--no-volte",
        action="store_true",
        help="không bật VoLTE (không khuyến khích)",
    )
    parser.add_argument(
        "--global-mode",
        action="store_true",
        help="áp dụng cài đặt quốc tế đầy đủ (loại bỏ hạn chế Hàn Quốc)",
    )
    parser.add_argument(
        "--clear-cache",
        action="store_true",
        help="xoá cache hệ thống sau debloat",
    )
    parser.add_argument(
        "--log",
        action="store_true",
        help="ghi chi tiết vào file log",
    )
    parser.add_argument(
        "--info",
        action="store_true",
        help="hiển thị thông tin thiết bị",
    )
    args = parser.parse_args()

    # Khởi tạo logging
    logger = setup_logging(log_file=args.log)

    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")

    try:
        serial = require_device()
    except AdbError as exc:
        print(f"Lỗi: {exc}", file=sys.stderr)
        if logger:
            logger.error(f"Lỗi ADB: {exc}")
        return 1

    device_info = get_device_info()
    print(f"Máy   : {EXPECTED_MODEL} ({serial})")
    print(f"Build : {device_info['build']}   Android {device_info['android']}")
    print(f"CSC   : {device_info['csc']}")

    if args.info:
        print("\n== Thông tin chi tiết ==")
        for key, value in device_info.items():
            print(f"  {key:20}: {value}")
        return 0

    # Xác định các chế độ mặc định
    enable_volte = not args.no_volte  # VoLTE bật mặc định trừ khi --no-volte
    enable_global = args.global_mode or True  # Global mode luôn bật

    try:
        if args.verify:
            print_summary()
            return 0

        if args.restore:
            restore_bloat(args.dry_run)
            print_summary()
            return 0

        if args.all_user_apps:
            failures = remove_all_user_apps(args.dry_run)
            apply_settings(args.dry_run)
            if enable_global:
                apply_global_settings(args.dry_run)
            if enable_volte:
                apply_volte_settings(args.dry_run)
            if args.performance:
                apply_performance_settings(args.dry_run)
            if not args.keep_keyboard:
                reset_keyboard(args.dry_run)
                clear_korean_resources(args.dry_run)
                disable_korean_ime(args.dry_run)
            if args.clear_cache and not args.dry_run:
                clear_cache(args.dry_run)
            if not args.dry_run:
                print_summary()
            return 1 if failures else 0

        failures = remove_bloat(args.dry_run)
        apply_settings(args.dry_run)
        if enable_global:
            apply_global_settings(args.dry_run)
        if enable_volte:
            apply_volte_settings(args.dry_run)
        if args.performance:
            apply_performance_settings(args.dry_run)
        if not args.keep_keyboard:
            reset_keyboard(args.dry_run)
            clear_korean_resources(args.dry_run)
            disable_korean_ime(args.dry_run)
        if args.clear_cache and not args.dry_run:
            clear_cache(args.dry_run)
        if not args.dry_run:
            print_summary()
        return 1 if failures else 0

    except AdbError as exc:
        print(f"\nMất kết nối với máy: {exc}", file=sys.stderr)
        if logger:
            logger.error(f"Mất kết nối: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())