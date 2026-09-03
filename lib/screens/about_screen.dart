import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About App',
          style: TextStyle(
            fontSize: fontProvider.scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // App Branding Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontProvider.scale(20),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: fontProvider.scale(13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.receivedLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.received, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '100% Offline & Private',
                          style: TextStyle(
                            fontSize: fontProvider.scale(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.received,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Privacy & Architecture Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Guarantee',
                          style: TextStyle(
                            fontSize: fontProvider.scale(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'KAESET MESSAGE SYSTEM is built with offline security at its core:\n\n'
                      '• No Internet Permission: The app cannot send or receive data over the web.\n'
                      '• Local SQLite Storage: All parsed M-Pesa records remain encrypted on your device.\n'
                      '• Read-Only Access: SMS messages are only read locally to extract customer transaction information.\n'
                      '• Zero Third-Party Trackers: No analytics, tracking or external advertising libraries.',
                      style: TextStyle(
                        fontSize: fontProvider.scale(13),
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Developer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Developer Information',
                          style: TextStyle(
                            fontSize: fontProvider.scale(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _infoRow('Organization', AppConstants.developerInfo, fontProvider),
                    _infoRow('Contact Email', AppConstants.developerEmail, fontProvider),
                    _infoRow('Target Platform', 'Android (API 21+)', fontProvider),
                    _infoRow('Database Engine', 'SQLite (Local)', fontProvider),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '© 2026 KAESET Enterprise Solutions. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontProvider.scale(11),
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, FontSizeProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontProvider.scale(13),
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontProvider.scale(13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
