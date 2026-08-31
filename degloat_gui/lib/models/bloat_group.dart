enum TargetMode {
  desktopAdb, // Running on Desktop via ADB USB connection
  localRoot,  // Running locally on Rooted Android phone
  localShizuku, // Running locally on Android via Shizuku (No Root)
  unsupported // Platform running this cannot execute commands (e.g. iOS, Web, Non-Rooted Android)
}

enum DeviceConnectionStatus {
  checking,
  disconnected,
  unauthorized,
  connectedCorrectModel,
  connectedWrongModel,
  localRootAvailable,
  localShizukuAvailable,
  localNoRoot,
  adbNotFound,
}

class BloatGroup {
  final String titleKey;
  final List<String> packages;
  const BloatGroup(this.titleKey, this.packages);
}

class SettingConfig {
  final String namespace;
  final String key;
  final String value;
  const SettingConfig(this.namespace, this.key, this.value);
}

class SystemConfig {
  static const List<BloatGroup> bloatGroups = [
    BloatGroup("group_korean_carriers", [
      "com.skt.prod.dialer",
      "com.skt.prod.phone",
      "com.skt.adot",
      "com.skt.tmap.ku",
      "com.skt.nugu.apollo",
      "com.sktelecom.smartcard.SmartcardService",
      "com.skt.skaf.A000Z00040",
      "com.sktelecom.minit",
      "com.skt.skaf.OA00018282",
      "com.skt.skaf.OA00199800",
      "com.skt.skaf.popone",
      "com.skt.skaf.l001m0000",
      "com.skt.t_smart_charge",
      "com.skt.hpsagree",
      "com.skt.hps20client",
      "com.samsung.hidden.SKT",
      "com.kt.serviceagent",
      "com.kt.showpaysha",
      "com.kt.service.ktv8200",
      "com.kt.olleh.storeclient",
      "com.kt.mhows.mobilecoupon",
      "com.kt.service.appcare",
      "com.lguplus.lgugpsnwps",
      "com.lguplus.payon",
      "com.lguplus.callguard",
      "com.lguplus.mobilephonecertificate",
      "com.lguplus.appstore",
      "com.lguplus.navi",
      "com.lguplus.mobile.cs",
      "com.lguplus.tsmproxy",
    ]),
    BloatGroup("group_carrier_auto_install_blockers", [
      "com.skt.skaf.OA00018282",
      "com.skt.skaf.OA00199800",
      "com.skt.skaf.popone",
      "com.kt.olleh.storeclient",
      "com.lguplus.appstore",
      "com.samsung.android.app.merchant",
    ]),
    BloatGroup("group_us_carriers", [
      "com.tmobile.pr.mytmobile",
      "com.tmobile.pr.adapt",
      "com.vzw.ap.dsa",
      "com.vzw.hss.myverizon",
      "com.att.myWireless",
      "com.att.dh",
      "com.samsung.vzw.hsm",
      "com.lookout",
      "com.amazon.mShop.android.shopping",
    ]),
    BloatGroup("group_korean_us_apps", [
      "com.tms",
      "com.samsung.sec.android.prd",
      "com.skms.android.agent",
      "com.samsung.android.nfc.resources.korea",
      "com.samsung.android.visitin",
      "com.samsung.android.ipsgeofence",
      "kr.co.captv.pooqV2",
      "skplanet.musicmate",
    ]),
    BloatGroup("group_korean_locales", [
      "com.samsung.SMT.lang_ko_kr_r00",
      "com.samsung.android.nmt.apps.t2t.languagepack.enko",
      "com.samsung.android.bixby.ondevice.kokr",
      "com.samsung.android.vtt-korean",
      "com.samsung.android.langpack.ko_kr",
      "com.samsung.android.offline.langpack.ko_kr",
      "com.samsung.android.sdk.handwriting.ko_KR",
    ]),
    BloatGroup("group_smart_suggestions", [
      "com.samsung.android.app.tips",
      "com.samsung.android.smartsuggestions",
      "com.samsung.android.globalgoals",
      "com.samsung.android.galaxyglobalgoals",
      "com.samsung.android.app.globalgoals",
      "com.samsung.sree",
      "com.samsung.android.globalpostprocmgr",
    ]),
    BloatGroup("group_samsung_wallet", [
      "com.samsung.android.spay",
      "com.sktelecom.tauth",
      "com.samsung.android.samsungpass",
      "com.samsung.android.samsungpassautofill",
      "com.samsung.android.coldwalletservice",
      "com.samsung.android.dkey",
      "com.samsung.android.carkey",
      "com.samsung.android.raposagent",
    ]),
    BloatGroup("group_samsung_bloat", [
      "com.samsung.android.tvplus",
      "com.samsung.android.app.spage",
      "com.samsung.android.glance.gpp",
      "com.sec.android.app.billing",
      "com.samsung.android.arzone",
      "com.samsung.android.aremoji",
      "com.samsung.android.aremojieditor",
      "com.samsung.android.ar.sticker",
      "com.samsung.android.kidsinstaller",
      "com.sec.android.app.kidshome",
      "com.samsung.android.stubs.wearable",
      "com.samsung.android.app.watchmanagerstub",
      "com.samsung.android.app.watchmanager",
      "com.samsung.android.app.watchmanager3",
      "com.samsung.android.app.shealth",
      "com.sec.android.app.shealth",
      "com.samsung.android.oneconnect",
      "com.samsung.android.smartswitchassistant",
      "com.sec.android.easyMover",
      "com.sec.android.easyMover.TargetApp",
      "com.samsung.android.app.simplesharing",
      "com.samsung.android.freshtracks",
      "com.samsung.android.stubs.tns",
      "com.android.chrome",
      "com.google.android.gm",
      "com.google.android.apps.maps",
      "com.google.android.apps.meetings",
      "com.google.android.apps.tachyon",
      "com.google.android.apps.docs",
      "com.google.android.apps.docs.editors.docs",
      "com.google.android.apps.docs.editors.sheets",
      "com.google.android.apps.docs.editors.slides",
      "com.google.android.apps.photos",
      "com.google.android.youtube",
      "com.google.android.apps.youtube.music",
      "com.google.android.googlequicksearchbox",
      "com.google.android.apps.bard",
      "com.google.android.apps.gemini",
      "com.elevenst"
    ]),
    BloatGroup("group_meta_ms", [
      "com.facebook.appmanager",
      "com.facebook.services",
      "com.facebook.system",
      "com.microsoft.skydrive",
      "com.microsoft.office.officehubrow",
      "com.microsoft.office.outlook",
      "com.microsoft.appmanager",
      "com.linkedin.android",
      "com.google.android.videos",
    ]),
    BloatGroup("group_bixby", [
      "com.samsung.android.bixby.agent",
      "com.samsung.android.bixby.wakeup",
      "com.samsung.android.bixby.service",
      "com.samsung.android.bixbyvision.framework",
      "com.samsung.android.visionintelligence",
      "com.samsung.android.bixby.ondevice.enus",
    ]),
    BloatGroup("group_game_launcher", [
      "com.samsung.android.game.gamehome",
      "com.enhance.gameservice",
    ]),
    BloatGroup("group_samsung_services", [
      "com.samsung.android.app.reminder",
      "com.samsung.android.smartswitchassistant",
      "com.samsung.android.voc",
      "com.samsung.petservice",
      "com.samsung.storyservice",
      "com.sec.spp.push",
      "com.samsung.android.easysetup",
      "com.samsung.android.app.dressroom",
      "com.samsung.gpuwatchapp",
    ]),
    BloatGroup("group_bluetooth_beacons", [
      "com.samsung.android.beaconmanager",
    ]),
    BloatGroup("group_telemetry", [
      "com.sec.android.diagmonagent",
      "com.samsung.android.dqagent",
      "com.samsung.android.da.daagent",
      "com.samsung.android.knox.analytics.uploader",
      "com.samsung.android.bbc.bbcagent",
      "com.samsung.android.qmdservice",
      "com.samsung.android.rubin.app",
      "com.samsung.android.mocca",
    ]),
  ];

  static const List<SettingConfig> settings = [
    SettingConfig("global", "power_sounds_enabled", "0"),
    SettingConfig("system", "csc_pref_camera_forced_shuttersound_key", "0"),
    SettingConfig("global", "ram_expand_size", "0"),
    SettingConfig("global", "safe_media_volume_enabled", "0"),
    SettingConfig("system", "spam_call_enable", "1"),
    SettingConfig("global", "wifi_scan_always_enabled", "0"),
    SettingConfig("system", "lift_to_wake", "1"),
    SettingConfig("global", "system_locales", "vi-VN,en-US"),
    SettingConfig("system", "system_locales", "vi-VN,en-US"),
    SettingConfig("system", "user_locale", "vi-VN"),
  ];

  static const Set<String> protectedPackages = {
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
    "com.sec.android.app.kguard",
    "com.samsung.android.spayfw",
    "com.samsung.android.ssiframework",
    "com.samsung.android.knox.mpos",
    "com.samsung.android.game.gos",
    "com.samsung.android.game.gametools",
    "com.skp.seio",
    "com.sec.android.UsimRegistrationKOR",
    "com.samsung.knox.keychain",
    "com.samsung.android.knox.containeragent",
    "com.sec.enterprise.knox.cloudmdm.smdms",
    "com.samsung.android.knox.attestation",
    "com.samsung.android.securitylogagent",
    "com.sec.android.app.samsungapps",
  };


  // Model regex to match Samsung series: G, S, N, F (S series, Note series, Fold, Flip)
  static final RegExp expectedModelsRegExp = RegExp(r'(G981|G986|G988|G991|G996|G998|S901|S906|S908|S911|S916|S918|S921|S926|S928|S931|S936|S938|S941|S946|S948|S951|S956|S958|N970|N975|N980|N981|N985|N986|F900|F916|F926|F936|F946|F956|F700|F707|F711|F721|F731|F741)', caseSensitive: false);

  static String getFriendlyModelName(String modelCode) {
    final upper = modelCode.toUpperCase().trim();
    if (upper.isEmpty) return 'Samsung Galaxy';
    
    // Note Series
    if (upper.contains('N970')) return 'Galaxy Note 10';
    if (upper.contains('N975')) return 'Galaxy Note 10+';
    if (upper.contains('N980') || upper.contains('N981')) return 'Galaxy Note 20';
    if (upper.contains('N985') || upper.contains('N986')) return 'Galaxy Note 20 Ultra';
    
    // Z Fold Series (SM-F9...)
    if (upper.startsWith('SM-F9') || upper.startsWith('F9')) {
      final cleanCode = upper.startsWith('SM-') ? upper.substring(3) : upper;
      final genChar = cleanCode.length > 2 ? cleanCode[2] : '';
      var gen = '';
      if (genChar == '5') {
        gen = ' 6';
      } else if (genChar == '4') {
        gen = ' 5';
      } else if (genChar == '3') {
        gen = ' 4';
      } else if (genChar == '2') {
        gen = ' 3';
      } else if (genChar == '1') {
        gen = ' 2';
      } else if (genChar == '0') {
        gen = ' Fold';
      } else if (genChar == '6') {
        gen = ' 7';
      } else if (genChar == '7') {
        gen = ' 8';
      } else if (genChar == '8') {
        gen = ' 9';
      } else {
        gen = ' $genChar';
      }

      final isUltra = cleanCode.length > 3 && (cleanCode[3] == '8' || cleanCode[3] == '9' || cleanCode.endsWith('N'));
      final suffix = isUltra ? ' Ultra' : '';
      return 'Galaxy Z Fold$gen$suffix';
    }
    
    // Z Flip Series (SM-F7...)
    if (upper.startsWith('SM-F7') || upper.startsWith('F7')) {
      final cleanCode = upper.startsWith('SM-') ? upper.substring(3) : upper;
      final genChar = cleanCode.length > 2 ? cleanCode[2] : '';
      var gen = '';
      if (genChar == '4') {
        gen = ' 6';
      } else if (genChar == '3') {
        gen = ' 5';
      } else if (genChar == '2') {
        gen = ' 4';
      } else if (genChar == '1') {
        gen = ' 3';
      } else if (genChar == '0') {
        gen = ' 2';
      } else if (genChar == '5') {
        gen = ' 7';
      } else if (genChar == '6') {
        gen = ' 8';
      } else {
        gen = ' $genChar';
      }
      return 'Galaxy Z Flip$gen';
    }

    // S Series (SM-S9... or SM-G9...)
    if (upper.startsWith('SM-S9') || upper.startsWith('S9')) {
      final cleanCode = upper.startsWith('SM-') ? upper.substring(3) : upper;
      final genChar = cleanCode.length > 2 ? cleanCode[2] : '';
      var series = '';
      var modelType = '';
      
      if (genChar == '0') {
        series = 'S22';
      } else if (genChar == '1') {
        series = 'S23';
      } else if (genChar == '2') {
        series = 'S24';
      } else if (genChar == '3') {
        series = 'S25';
      } else if (genChar == '4') {
        series = 'S26';
      } else {
        series = 'S2$genChar';
      }
      
      final typeChar = cleanCode.length > 3 ? cleanCode[3] : '';
      if (typeChar == '8') {
        modelType = ' Ultra';
      } else if (typeChar == '6') {
        modelType = '+';
      }
      
      return 'Galaxy $series$modelType';
    }
    
    // S20 & S21 Legacy prefix SM-G98... & SM-G99...
    if (upper.contains('G981')) return 'Galaxy S20';
    if (upper.contains('G986')) return 'Galaxy S20+';
    if (upper.contains('G988')) return 'Galaxy S20 Ultra';
    if (upper.contains('G991')) return 'Galaxy S21';
    if (upper.contains('G996')) return 'Galaxy S21+';
    if (upper.contains('G998')) return 'Galaxy S21 Ultra';

    // FE & Lite Series
    if (upper.contains('G780') || upper.contains('G781')) return 'Galaxy S20 FE';
    if (upper.contains('G990')) return 'Galaxy S21 FE';
    if (upper.contains('S711')) return 'Galaxy S23 FE';
    if (upper.contains('S721')) return 'Galaxy S24 FE';
    if (upper.contains('G770')) return 'Galaxy S10 Lite';
    if (upper.contains('N770')) return 'Galaxy Note 10 Lite';

    if (upper.startsWith('SM-')) {
      return 'Galaxy ${upper.replaceFirst('SM-', '')}';
    }
    return modelCode;
  }

  static String getFriendlyCscRegion(String csc) {
    final upper = csc.toUpperCase().trim();
    if (upper == 'SKC' || upper == 'KOR') return 'Korea (SKT)';
    if (upper == 'KTC') return 'Korea (KT)';
    if (upper == 'LUC') return 'Korea (LGU+)';
    if (upper == 'KOO') return 'Korea (Unlocked)';
    if (upper == 'TMB' || upper == 'TMK') return 'United States (T-Mobile)';
    if (upper == 'VZW') return 'United States (Verizon)';
    if (upper == 'ATT') return 'United States (AT&T)';
    if (upper == 'XAA' || upper == 'XAS') return 'United States (Unlocked)';
    if (upper.isEmpty) return 'Unknown';
    return 'Other Region ($csc)';
  }

  static String getFriendlyAppName(String packageName) {
    final Map<String, String> names = {
      "com.samsung.android.game.gos": "Game Optimizing Service (GOS)",
      "com.samsung.android.game.gametools": "Game Tools",
      "com.samsung.android.game.gamehome": "Game Launcher",
      "com.samsung.android.spayfw": "Samsung Pay Framework",
      "com.samsung.android.ssiframework": "Samsung Services Framework",
      "com.samsung.knox.keychain": "Knox Key Chain",
      "com.samsung.android.knox.containeragent": "Secure Folder / Knox Container",
      "com.sec.enterprise.knox.cloudmdm.smdms": "Knox Manage Enrollment",
      "com.samsung.android.knox.attestation": "Knox Attestation",
      "com.samsung.android.securitylogagent": "Security Log Agent",
      "com.sec.android.app.samsungapps": "Galaxy Store",
      "com.samsung.android.bixby.agent": "Bixby Voice",
      "com.samsung.android.bixby.wakeup": "Bixby Wakeup",
      "com.samsung.android.bixby.service": "Bixby Service",
      "com.samsung.android.app.settings.bixby": "Bixby Settings",
      "com.samsung.android.bixby.agent.dummy": "Bixby Agent Dummy",
      "com.samsung.android.app.spage": "Bixby Home / Samsung Daily",
      "com.samsung.android.visionarapps": "Bixby Vision AR",
      "com.samsung.android.scloud": "Samsung Cloud",
      "com.samsung.android.kidshome": "Samsung Kids",
      "com.sec.android.app.sbrowser": "Samsung Internet",
      "com.samsung.android.messaging": "Samsung Messages",
      "com.samsung.android.email.provider": "Samsung Email",
      "com.sec.android.app.voicenote": "Samsung Voice Recorder",
      "com.sec.android.app.popupcalculator": "Samsung Calculator",
      "com.samsung.android.oneconnect": "SmartThings",
      "com.samsung.android.calendar": "Samsung Calendar",
      "com.samsung.android.app.notes": "Samsung Notes",
      "com.samsung.android.app.watchmanager3": "Galaxy Wearable",
      "com.samsung.android.aremoji": "AR Emoji",
      "com.samsung.android.aremojieditor": "AR Emoji Editor",
      "com.samsung.android.arzone": "AR Zone",
      "com.samsung.android.app.routines": "Bixby Routines",
      "com.samsung.android.fmm": "Find My Mobile",
      "com.samsung.android.smartswitchassistant": "Smart Switch",
      "com.samsung.android.app.ledcoverdream": "LED Cover Service",
      "com.samsung.android.app.simplesharing": "Link Sharing",
      "com.samsung.android.app.spay": "Samsung Pay",
      "com.samsung.android.samsungpass": "Samsung Pass",
      "com.samsung.android.samsungpassautofill": "Samsung Pass Autofill",
      "com.android.chrome": "Google Chrome",
      "com.google.android.gm": "Gmail",
      "com.google.android.apps.maps": "Google Maps",
      "com.google.android.apps.meetings": "Google Meet",
      "com.google.android.apps.docs": "Google Drive",
      "com.google.android.apps.photos": "Google Photos",
      "com.google.android.youtube": "YouTube",
      "com.google.android.apps.youtube.music": "YouTube Music",
      "com.google.android.googlequicksearchbox": "Google",
      "com.google.android.apps.bard": "Gemini",
      "com.google.android.apps.gemini": "Gemini",
      "com.samsung.android.oneconnect": "SmartThings",
      "com.samsung.android.app.shealth": "Samsung Health",
      "com.sec.android.app.shealth": "Samsung Health",
      "com.samsung.android.app.watchmanager": "Samsung Wearable",
      "com.samsung.android.app.watchmanager3": "Samsung Wearable",
      "com.samsung.android.smartswitchassistant": "Smart Switch",
      "com.samsung.android.lool": "Device Care",
      "com.samsung.android.ipsgeofence": "IPS Geofence",
      "com.samsung.android.rubin.app": "Customization Service",
      "com.samsung.android.app.galaxyfinder": "Finder",
      "com.sec.android.easyMover.SourceApp": "Smart Switch Mobile",
      "com.samsung.android.mdx": "Link to Windows",
      "com.samsung.android.alive.service": "Samsung Alive Service",
      "com.samsung.android.da.daagent": "Dual Messenger",
      "com.samsung.android.service.peopleservice": "People Service",
      "com.samsung.android.app.clipboardshare": "Shared Clipboard",
      "com.sec.android.cover.ledcover": "LED Cover",
      "com.samsung.android.vtcamerasettings": "Video Call Effects",
      "com.samsung.android.smartsuggestions": "Smart Suggestions",
      "com.samsung.android.globalgoals": "Global Goals",
      "com.samsung.android.galaxyglobalgoals": "Global Goals",
      "com.samsung.android.app.globalgoals": "Global Goals",
      "com.samsung.android.knox.mpos": "Knox mPOS",
      "com.skp.seio": "SKT USIM Service",
      "com.sec.android.UsimRegistrationKOR": "Korean USIM Registration",
      "com.sec.vsim.ericssonnsds.webapp": "Ericsson vSIM Service",
      "com.samsung.android.drivelink.stub": "Car Mode Stub",
      "com.vzw.apn": "Verizon APN Service",
      "com.samsung.vvm": "Visual Voicemail",
      "com.att.dh": "AT&T Device Help",
      "com.att.mygiga": "My AT&T",
      "com.tmobile.pr.mytmobile": "T-Mobile App",
      "com.sprint.wfc.engine": "Sprint Wi-Fi Calling",
      "com.sprint.zone": "Sprint Zone",
      "com.sec.epdg": "Wifi Calling Engine",
      "com.facebook.katana": "Facebook",
      "com.facebook.system": "Facebook App Installer",
      "com.facebook.appmanager": "Facebook App Manager",
      "com.facebook.services": "Facebook Services",
      "com.netflix.mediaclient": "Netflix",
      "com.netflix.partner.activation": "Netflix Activation",
      "com.microsoft.skype.teams": "Microsoft Teams",
      "com.microsoft.office.officehubrow": "Microsoft Office",
      "com.microsoft.office.outlook": "Microsoft Outlook",
      "com.microsoft.onedrive": "Microsoft OneDrive",
      "com.spotify.music": "Spotify",
      "com.google.android.youtube": "YouTube",
      "com.google.android.apps.youtube.music": "YouTube Music",
      "com.google.android.apps.tachyon": "Google Duo / Meet",
      "com.google.android.videos": "Google TV / Play Movies",
      "com.google.android.music": "Google Play Music",
      "com.google.android.feedback": "Google Feedback",
      "com.google.android.apps.photos": "Google Photos",
    };
    if (names.containsKey(packageName)) {
      return names[packageName]!;
    }

    var name = packageName;
    final prefixes = [
      'com.samsung.android.app.',
      'com.samsung.android.',
      'com.sec.android.app.',
      'com.sec.android.easyMover.',
      'com.sec.android.',
      'com.sec.',
      'com.samsung.',
      'com.google.android.apps.',
      'com.google.android.',
      'com.google.mainline.',
      'com.google.',
      'com.android.',
    ];
    for (var prefix in prefixes) {
      if (name.startsWith(prefix)) {
        name = name.substring(prefix.length);
        break;
      }
    }

    final parts = name.split(RegExp(r'[\._-]'));
    final List<String> words = [];
    for (var part in parts) {
      if (part.isEmpty) continue;
      final camelParts = part.split(RegExp(r'(?=[A-Z])'));
      for (var cp in camelParts) {
        if (cp.trim().isEmpty) continue;
        final clean = cp.trim();
        words.add(clean[0].toUpperCase() + clean.substring(1));
      }
    }

    if (words.isEmpty) {
      return packageName;
    }

    var resolved = words.join(' ');
    if (packageName.contains('samsung') || packageName.contains('sec.')) {
      resolved = "Samsung $resolved";
    } else if (packageName.contains('google')) {
      resolved = "Google $resolved";
    }
    return resolved;
  }

  static const String keyboardPackage = "com.samsung.android.honeyboard";
  static const String keyboardLocales = "vi-VN,en-US";
}
