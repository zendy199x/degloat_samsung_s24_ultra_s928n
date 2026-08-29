#!/usr/bin/env python3
"""Khôi phục cấu hình "global" cho Galaxy S24 Ultra bản Hàn (SM-S928N).

Sau mỗi lần nâng cấp One UI lớn, CSC SKC sẽ cài lại toàn bộ app Hàn Quốc.
Chạy lại script này để đưa máy về trạng thái đã dọn.

    python degloat_s928n.py            # áp dụng
    python degloat_s928n.py --verify   # chỉ kiểm tra, không đổi gì
    python degloat_s928n.py --dry-run  # xem trước việc sẽ làm
    python degloat_s928n.py --restore  # cài lại mọi thứ đã gỡ
"""

from __future__ import annotations

import argparse
import subprocess
import sys

# Mỗi nhóm là (mô tả, [package...]). Toàn bộ đã được xác minh an toàn trên SM-S928N.
BLOAT_GROUPS: list[tuple[str, list[str]]] = [
    ("Nhà mạng Hàn (SKT / KT / LG U+)", [
        "com.skt.prod.dialer",                # T전화 / A.phone (cũ)
        "com.skt.prod.phone",                 # A.phone – SKT A. Adot Phone (One UI 6+)
        "com.skt.adot",                       # A. (Adot) – nền tảng AI SKT (A.phone mới)
        "com.skt.tmap.ku",                    # T-Map – GPS / Bản đồ SKT [xác minh ADB]
        "com.skt.nugu.apollo",                # NUGU – Trợ lý AI của SKT [xác minh ADB]
        "com.sktelecom.smartcard.SmartcardService",  # SKT USIM Smartcard Service [xác minh ADB: không ảnh hưởng Knox/Download Mode]
        "com.skt.skaf.A000Z00040",            # ONE Store
        "com.sktelecom.minit",                # T world
        "com.skt.skaf.OA00018282",            # ONE Store updater
        "com.skt.skaf.OA00199800",            # ONE Store client
        "com.skt.skaf.popone",                # SKT PopOne
        "com.skt.skaf.l001m0000",             # SKT T-Map / T-Services
        "com.skt.t_smart_charge",             # T 스마트충전
        "com.skt.hpsagree",
        "com.skt.hps20client",
        "com.samsung.hidden.SKT",
        "com.kt.serviceagent",
        "com.kt.showpaysha",                  # KT Show Pay
        "com.kt.service.ktv8200",             # KT Service
        "com.kt.olleh.storeclient",           # KT Olleh Store
        "com.kt.mhows.mobilecoupon",          # KT Mobile Coupon
        "com.kt.service.appcare",             # KT App Care
        "com.lguplus.lgugpsnwps",
        "com.lguplus.payon",                  # LG U+ Pay
        "com.lguplus.callguard",              # LG U+ Chặn cuộc gọi Hàn
        "com.lguplus.mobilephonecertificate", # LG U+ Chứng thư di động
        "com.lguplus.appstore",               # LG U+ App Store
        "com.lguplus.navi",                   # LG U+ Navigation
        "com.lguplus.mobile.cs",              # LG U+ Customer Service
        "com.lguplus.tsmproxy",               # LG U+ TSM Proxy
    ]),
    ("App riêng máy Hàn & Quảng cáo vị trí", [
        "com.tms",                            # SKTMemberShip_new.apk
        "com.samsung.sec.android.prd",        # SamsungDotComKor
        "com.skms.android.agent",             # SKMSAgent
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
    ("Now Brief & Gợi ý thông minh (Smart Suggestions)", [
        "com.samsung.android.smartsuggestions",      # Smart Suggestions / Now Brief
    ]),
    ("Samsung Wallet & Digital Key (bản Hàn)", [
        "com.samsung.android.spay",                  # Samsung Wallet / Samsung Pay
        "com.samsung.android.samsungpass",           # Samsung Pass
        "com.samsung.android.samsungpassautofill",   # Samsung Pass Autofill
        "com.samsung.android.coldwalletservice",     # Samsung Cold Wallet
        "com.samsung.android.dkey",                  # Samsung Wallet Digital Key
        "com.samsung.android.carkey",                # Samsung Wallet Car Key
        "com.samsung.android.raposagent",            # Samsung Wallet RAPOS Agent
    ]),
    ("App Samsung rác & Tính năng phụ", [
        "com.samsung.android.tvplus",                # Samsung TV Plus
        "com.samsung.android.app.spage",             # Samsung Free / Samsung News tab / Briefing
        "com.samsung.android.glance.gpp",            # Glance (Quảng cáo màn hình khóa)
        "com.sec.android.app.billing",               # Samsung In-App Purchase
        "com.samsung.android.arzone",                # AR Zone
        "com.samsung.android.aremoji",               # AR Emoji
        "com.samsung.android.aremojieditor",         # AR Emoji Editor
        "com.samsung.android.ar.sticker",            # AR Emoji Stickers
        "com.samsung.android.kidsinstaller",         # Samsung Kids Installer
        "com.sec.android.app.kidshome",              # Samsung Kids Home
        "com.samsung.android.stubs.wearable",        # Wearable Stub Installer
        "com.samsung.android.app.watchmanagerstub",  # Watch Manager Stub Installer
        "com.samsung.android.freshtracks",           # Samsung Music Discovery
        "com.samsung.android.stubs.tns",             # Samsung News Stub
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
        "com.google.android.videos",                 # Google TV
    ]),
    ("Bixby Voice & Trợ lý ảo", [
        "com.samsung.android.bixby.agent",           # Trợ lý Bixby Voice
        "com.samsung.android.bixby.wakeup",          # Nhận diện giọng nói "Hi Bixby"
        "com.samsung.android.bixby.service",         # Bixby Service
        "com.samsung.android.bixbyvision.framework", # Bixby Vision Framework
        "com.samsung.android.visionintelligence",    # Bixby Vision Intelligence
        "com.samsung.android.bixby.ondevice.enus",   # Bixby On-Device tiếng Anh
    ]),
    ("Game Launcher rác", [
        "com.samsung.android.game.gamehome",         # Game Launcher / Game Hub
        "com.enhance.gameservice",                   # Game Service
    ]),
    ("Dịch vụ Samsung phụ & Liên kết ngầm", [
        "com.samsung.android.app.reminder",          # Samsung Reminder
        "com.samsung.android.smartswitchassistant",  # Smart Switch Assistant Hàn
        "com.samsung.android.voc",                   # Samsung Members Hàn
        "com.samsung.petservice",                    # Pet Service
        "com.samsung.storyservice",                  # Story Service
        "com.sec.spp.push",                          # Samsung Push Service
        "com.samsung.android.easysetup",             # Easy Setup
        "com.samsung.android.app.dressroom",         # Samsung Dressroom
        "com.samsung.gpuwatchapp",                   # GPU Watch
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
]

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
    # Các thành phần đã chuyển vào danh sách an toàn
    "com.sec.android.app.kguard",
    "com.samsung.android.spayfw",
    "com.samsung.android.ssiframework",
    "com.samsung.android.knox.mpos",
    "com.samsung.android.game.gos",
    "com.samsung.android.game.gametools",
    "com.skp.seio",
    "com.sec.android.UsimRegistrationKOR",
})

EXPECTED_MODEL = "SM-S928N"
KEYBOARD_PACKAGE = "com.samsung.android.honeyboard"
KEYBOARD_LOCALES = "vi-VN,en-US"


class AdbError(RuntimeError):
    pass


def adb(*args: str, check: bool = True) -> str:
    proc = subprocess.run(
        ("adb", *args), capture_output=True, text=True, encoding="utf-8", errors="replace"
    )
    if check and proc.returncode != 0:
        raise AdbError((proc.stderr or proc.stdout).strip())
    return proc.stdout.strip()


def shell(command: str) -> str:
    return adb("shell", command, check=False)


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


def installed_packages() -> set[str]:
    all_pkgs = {
        l.removeprefix("package:").strip()
        for l in shell("pm list packages").splitlines()
        if l.startswith("package:")
    }
    disabled_pkgs = {
        l.removeprefix("package:").strip()
        for l in shell("pm list packages -d").splitlines()
        if l.startswith("package:")
    }
    return all_pkgs - disabled_pkgs


def all_bloat() -> list[str]:
    return [pkg for _, packages in BLOAT_GROUPS for pkg in packages]


def report_state() -> tuple[list[str], list[str]]:
    present = installed_packages()
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


def remove_bloat(dry_run: bool) -> int:
    present = installed_packages()
    failures = 0

    for title, packages in BLOAT_GROUPS:
        targets = [p for p in packages if p in present]
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


def restore_bloat(dry_run: bool) -> None:
    print("\n== Cài lại toàn bộ gói đã gỡ ==")
    present = installed_packages()
    for pkg in all_bloat():
        if pkg in present:
            continue
        if dry_run:
            print(f"  [sẽ cài ] {pkg}")
            continue
        result = shell(f'cmd package install-existing "{pkg}"')
        ok = "installed" in result.lower() or "Success" in result
        print(f"  [{'ok' if ok else 'LỖI':8}] {pkg}")


def reset_keyboard(dry_run: bool) -> None:
    print("\n== Bàn phím Samsung ==")
    if KEYBOARD_PACKAGE not in installed_packages():
        print("  (không tìm thấy Samsung Keyboard, bỏ qua)")
        return

    if dry_run:
        print(f"  [sẽ đặt  ] system_locales = {KEYBOARD_LOCALES}")
        print(f"  [sẽ reset] {KEYBOARD_PACKAGE} — loại tiếng Hàn khỏi danh sách nhập")
        return

    shell(f'settings put system system_locales "{KEYBOARD_LOCALES}"')
    print(f"  [locale  ] {shell('settings get system system_locales')}")

    result = shell(f"pm clear {KEYBOARD_PACKAGE}")
    if "Success" not in result:
        print(f"  [LỖI    ] {result or 'không rõ nguyên nhân'}")
        return
    print("  [đã reset] tiếng Hàn đã bị loại khỏi bàn phím")

    ime = shell("settings get secure default_input_method")
    if KEYBOARD_PACKAGE not in ime:
        print("  ⚠ Bàn phím mặc định bị đổi, đặt lại bằng:")
        print(f"      adb shell ime set {KEYBOARD_PACKAGE}/.service.HoneyBoardService")

    print("  → Chọn kiểu gõ Telex: Cài đặt > Quản lý chung > Bàn phím Samsung")
    print("    > Ngôn ngữ và loại > Tiếng Việt")


def print_summary() -> None:
    remaining, missing_protected = report_state()

    print("\n" + "=" * 58)
    print("KẾT QUẢ")
    print("=" * 58)

    total = len(all_bloat())
    print(f"  App rác Hàn Quốc : {total - len(remaining)}/{total} đã gỡ")
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


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Dọn app Hàn Quốc trên SM-S928N, đưa máy về trạng thái giống bản global."
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--verify", action="store_true", help="chỉ kiểm tra, không thay đổi gì")
    mode.add_argument("--dry-run", action="store_true", help="xem trước việc sẽ làm")
    mode.add_argument("--restore", action="store_true", help="cài lại mọi gói đã gỡ")
    parser.add_argument(
        "--keep-keyboard",
        action="store_true",
        help="không reset Samsung Keyboard (giữ từ đã học, nhưng tiếng Hàn còn lại)",
    )
    args = parser.parse_args()

    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")

    try:
        serial = require_device()
    except AdbError as exc:
        print(f"Lỗi: {exc}", file=sys.stderr)
        return 1

    print(f"Máy   : {EXPECTED_MODEL} ({serial})")
    print(f"Build : {shell('getprop ro.build.PDA')}   Android {shell('getprop ro.build.version.release')}")

    try:
        if args.verify:
            print_summary()
            return 0

        if args.restore:
            restore_bloat(args.dry_run)
            print_summary()
            return 0

        failures = remove_bloat(args.dry_run)
        apply_settings(args.dry_run)
        if not args.keep_keyboard:
            reset_keyboard(args.dry_run)
        if not args.dry_run:
            print_summary()
        return 1 if failures else 0

    except AdbError as exc:
        print(f"\nMất kết nối với máy: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())