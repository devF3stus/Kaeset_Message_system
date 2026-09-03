import 'package:flutter/material.dart';
import '../services/preference_service.dart';
import '../utils/constants.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontScale = AppConstants.defaultFontScale;
  bool _isLoaded = false;

  FontSizeProvider() {
    loadFontSize();
  }

  double get fontScale => _fontScale;
  bool get isLoaded => _isLoaded;

  /// Load persisted font scale from SharedPreferences
  Future<void> loadFontSize() async {
    final prefs = await PreferenceService.getInstance();
    _fontScale = prefs.getFontScale();
    _isLoaded = true;
    notifyListeners();
  }

  /// Update font scale (clamped between 1.0x and 2.0x) and persist
  Future<void> setFontSize(double newScale) async {
    final clamped = newScale.clamp(AppConstants.minFontScale, AppConstants.maxFontScale);
    if ((_fontScale - clamped).abs() > 0.001) {
      _fontScale = clamped;
      notifyListeners();
      final prefs = await PreferenceService.getInstance();
      await prefs.saveFontScale(_fontScale);
    }
  }

  /// Reset font scale to default (1.0x)
  Future<void> resetFontSize() async {
    _fontScale = AppConstants.defaultFontScale;
    notifyListeners();
    final prefs = await PreferenceService.getInstance();
    await prefs.resetFontScale();
  }

  /// Helper to calculate scaled font size given a base size
  double scale(double baseSize) {
    return baseSize * _fontScale;
  }
}
