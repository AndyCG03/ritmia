import 'package:flutter/widgets.dart';

const languageNames = <String, String>{
  'es': 'Español',
  'en': 'English',
  'pt': 'Português',
  'fr': 'Français',
};
Locale supportedLocale(Locale locale) => Locale(
  languageNames.containsKey(locale.languageCode) ? locale.languageCode : 'en',
);
