import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../widgets/font_slider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: fontProvider.scale(18),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Typography / Font Customization
            _sectionHeader('DISPLAY & TYPOGRAPHY', fontProvider),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: const FontSlider(),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Data Management
            _sectionHeader('DATA MANAGEMENT', fontProvider),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  // Export CSV
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                    ),
                    title: Text(
                      'Export Data as CSV',
                      style: TextStyle(
                        fontSize: fontProvider.scale(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Save all parsed transactions into an Excel/CSV spreadsheet',
                      style: TextStyle(
                        fontSize: fontProvider.scale(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      try {
                        final filePath = await txProvider.exportToCsv();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('CSV successfully exported to:\n$filePath'),
                              duration: const Duration(seconds: 4),
                              backgroundColor: AppColors.received,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Export failed: $e'),
                              backgroundColor: AppColors.sent,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),

                  // Clear All Data
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.sentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.sent),
                    ),
                    title: Text(
                      'Delete All Stored Data',
                      style: TextStyle(
                        fontSize: fontProvider.scale(15),
                        fontWeight: FontWeight.w600,
                        color: AppColors.sent,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently remove all parsed transactions from local SQLite storage',
                      style: TextStyle(
                        fontSize: fontProvider.scale(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _confirmClearData(context, fontProvider, txProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: App & Privacy
            _sectionHeader('INFORMATION & PRIVACY', fontProvider),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.secondary),
                    ),
                    title: Text(
                      'Offline Privacy & Security',
                      style: TextStyle(
                        fontSize: fontProvider.scale(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '100% offline. No internet connection or remote tracking.',
                      style: TextStyle(
                        fontSize: fontProvider.scale(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                    ),
                    title: Text(
                      'About App',
                      style: TextStyle(
                        fontSize: fontProvider.scale(15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Version ${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: fontProvider.scale(12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, FontSizeProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontProvider.scale(12),
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  void _confirmClearData(
    BuildContext context,
    FontSizeProvider fontProvider,
    TransactionProvider txProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.sent),
            const SizedBox(width: 8),
            Text(
              'Clear Database?',
              style: TextStyle(
                fontSize: fontProvider.scale(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete all stored transactions? You can resync at any time from your device SMS.',
          style: TextStyle(fontSize: fontProvider.scale(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sent),
            onPressed: () async {
              await txProvider.clearAllData();
              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All transaction records have been deleted.'),
                    backgroundColor: AppColors.sent,
                  ),
                );
              }
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
