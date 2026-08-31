import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class JsonLocalizationService {
  static final JsonLocalizationService _instance = JsonLocalizationService._internal();

  factory JsonLocalizationService() {
    return _instance;
  }

  JsonLocalizationService._internal();

  final Map<String, Map<String, dynamic>> _translations = {};
  String _currentLanguage = 'en';

  Future<void> initialize() async {
    if (_translations.isEmpty) {
      await _loadLanguage('en');
      await _loadLanguage('vi');
    }
  }

  Future<void> _loadLanguage(String language) async {
    try {
      final jsonString = await rootBundle.loadString('assets/lang/$language.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _translations[language] = jsonData;
    } catch (e) {
      // Silently fail to load language, fallback to default
    }
  }

  void setLanguage(String language) {
    _currentLanguage = language;
  }

  String get(String key, {String language = '', Map<String, dynamic>? params}) {
    final lang = language.isNotEmpty ? language : _currentLanguage;
    
    if (!_translations.containsKey(lang)) {
      return _getFromLanguage(key, 'en', params);
    }
    
    return _getFromLanguage(key, lang, params);
  }

  String _getFromLanguage(String key, String language, Map<String, dynamic>? params) {
    final translations = _translations[language];
    if (translations == null) return key;
    
    var value = translations[key];
    if (value == null) return key;
    
    String stringValue = value.toString();
    
    // Replace parameters like {model} with actual values
    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        stringValue = stringValue.replaceAll('{$paramKey}', paramValue.toString());
      });
    }
    
    return stringValue;
  }

  String getCurrentLanguage() => _currentLanguage;

  bool hasKey(String key) {
    return _translations[_currentLanguage]?.containsKey(key) ?? false;
  }
}

final jsonLocalizationService = JsonLocalizationService();
