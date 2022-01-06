import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale? _locale;
  late List<Locale> _supportedLocales;
  late Locale _fallbackLocale;
  Locale get locale =>
      _locale ??
      (_supportedLocales
              .map((e) => e.languageCode)
              .contains(Platform.localeName.split("_")[0])
          ? Locale(Platform.localeName.split("_")[0])
          : _fallbackLocale);

  LanguageNotifier(String? storedLocale,
      {required List<Locale> supportedLocales,
      required Locale fallbackLocale}) {
    _locale = storedLocale == null ? null : Locale(storedLocale);
    _supportedLocales = supportedLocales;
    _fallbackLocale = fallbackLocale;
  }

  void setLocale(Locale? newLocale) async {
    var prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', newLocale.languageCode);
    }
    _locale = newLocale;
    notifyListeners();
  }
}
