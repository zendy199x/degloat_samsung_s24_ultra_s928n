import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/json_localization_service.dart';
import 'theme/app_theme.dart';

class DebloatApp extends StatefulWidget {
  const DebloatApp({super.key});

  @override
  State<DebloatApp> createState() => _DebloatAppState();
}

class _DebloatAppState extends State<DebloatApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;
  bool _localizationReady = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await jsonLocalizationService.initialize();
    jsonLocalizationService.setLanguage('en');
    if (mounted) {
      setState(() {
        _localizationReady = true;
      });
    }
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
      jsonLocalizationService.setLanguage(value.languageCode);
    });
  }

  void setThemeMode(ThemeMode value) {
    setState(() {
      _themeMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOutCubic,
      child: MaterialApp(
        title: 'Samsung Galaxy Debloat Utility',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        themeMode: _themeMode,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: _localizationReady
            ? HomeScreen(
                onLocaleChanged: setLocale,
                onThemeModeChanged: setThemeMode,
              )
            : Container(),
      ),
    );
  }
}
