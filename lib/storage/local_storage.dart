import 'dart:ui';

import 'app_theme.dart';
import 'storage.dart';

class LocalStorage {
  AppTheme get appTheme => AppTheme.values.byName(
      StorageHelper.get<String>('app_theme', AppTheme.followSystem.name));

  set appTheme(AppTheme value) => StorageHelper.set('app_theme', value.name);

  Color get accentColor =>
      Color(StorageHelper.get<int>('accent_color', 0xFFD0BCFF));

  set accentColor(Color? value) =>
      StorageHelper.set<int?>('accent_color', value?.toARGB32());

  List<String> get favoritePlates {
    return StorageHelper.get('favorite_plates', []).cast<String>();
  }

  set favoritePlates(List<String> plates) {
    StorageHelper.set<List<String>>('favorite_plates', plates);
  }
}
