import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'KAESET MESSAGE SYSTEM';
  static const String appVersion = '1.0.0';
  static const String developerInfo = 'KAESET Enterprise Solutions';
  static const String developerEmail = 'support@kaeset.com';

  // SharedPreferences keys
  static const String prefFontScale = 'kaeset_font_scale';
  static const String prefLastSync = 'kaeset_last_sync_timestamp';

  // Font size boundaries
  static const double minFontScale = 1.0;
  static const double maxFontScale = 2.0;
  static const double defaultFontScale = 1.0;

  // Database details
  static const String dbName = 'kaeset_transactions.db';
  static const int dbVersion = 1;
  static const String tableName = 'transactions';
}

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF1565C0); // Royal Blue
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF00897B); // Teal
  static const Color accent = Color(0xFFFF6F00); // Orange highlight

  // Transaction Status Colors
  static const Color received = Color(0xFF2E7D32); // Green
  static const Color receivedLight = Color(0xFFE8F5E9);
  static const Color sent = Color(0xFFC62828); // Red
  static const Color sentLight = Color(0xFFFFEBEE);

  // Backgrounds & Surfaces
  static const Color scaffoldBackground = Color(0xFFF5F7FB);
  static const Color cardBackground = Colors.white;
  static const Color surfaceMuted = Color(0xFFF0F2F5);

  // Typography Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);
}
