import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageService {
  final _box = GetStorage();
  final _key = 'isEnglish';

  bool _loadLanguageFromBox() => _box.read(_key) ?? true;

  bool isEnglish() => _loadLanguageFromBox();

  void _saveLanguageToBox(bool isEnglish) => _box.write(_key, isEnglish);

  void toggleLanguage() {
    bool newValue = !_loadLanguageFromBox();
    _saveLanguageToBox(newValue);
    Get.updateLocale(newValue ? const Locale('en') : const Locale('ar'));
  }
}

