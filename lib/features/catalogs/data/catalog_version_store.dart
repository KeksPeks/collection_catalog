import 'package:shared_preferences/shared_preferences.dart';

class CatalogVersionStore {
  CatalogVersionStore._();
  static String _key(String catalogId) => 'catalog.installedVersion.$catalogId';
  static Future<int?> installedVersion(String catalogId) async { final preferences = await SharedPreferences.getInstance(); await preferences.reload(); return preferences.getInt(_key(catalogId)); }
  static Future<void> markInstalled(String catalogId, int version) async { final preferences = await SharedPreferences.getInstance(); await preferences.setInt(_key(catalogId), version); }
  static Future<bool> needsUpdate(String catalogId, int currentVersion) async { final installed = await installedVersion(catalogId); return installed != null && installed < currentVersion; }
}
