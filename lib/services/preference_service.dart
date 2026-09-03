import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PreferenceService {
  static PreferenceService? _instance;
  static SharedPreferences? _prefs;

  PreferenceService._();

  static Future<PreferenceService> getInstance() async {
    _instance ??= PreferenceService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Get stored font scale or default (1.0)
  double getFontScale() {
    return _prefs?.getDouble(AppConstants.prefFontScale) ?? AppConstants.defaultFontScale;
  }

  /// Save font scale (between 1.0 and 2.0)
  Future<bool> saveFontScale(double scale) async {
    final clamped = scale.clamp(AppConstants.minFontScale, AppConstants.maxFontScale);
    return await _prefs?.setDouble(AppConstants.prefFontScale, clamped) ?? false;
  }

  /// Reset font scale to default (1.0)
  Future<bool> resetFontScale() async {
    return await _prefs?.setDouble(AppConstants.prefFontScale, AppConstants.defaultFontScale) ?? false;
  }

  /// Get last sync date time
  DateTime? getLastSyncTime() {
    final millis = _prefs?.getInt(AppConstants.prefLastSync);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Save last sync date time
  Future<bool> saveLastSyncTime(DateTime time) async {
    return await _prefs?.setInt(AppConstants.prefLastSync, time.millisecondsSinceEpoch) ?? false;
  }

  /// Clear all stored preferences
  Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
