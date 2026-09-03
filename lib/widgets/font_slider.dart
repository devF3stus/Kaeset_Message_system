import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';
import '../utils/constants.dart';

class FontSlider extends StatelessWidget {
  const FontSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slider Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_size_rounded,
                  color: AppColors.primary,
                  size: fontProvider.scale(22),
                ),
                const SizedBox(width: 8),
                Text(
                  'Font Size Scale',
                  style: TextStyle(
                    fontSize: fontProvider.scale(16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${fontProvider.fontScale.toStringAsFixed(1)}x',
                style: TextStyle(
                  fontSize: fontProvider.scale(14),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Slider control
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            valueIndicatorColor: AppColors.primaryDark,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: fontProvider.fontScale,
            min: AppConstants.minFontScale,
            max: AppConstants.maxFontScale,
            divisions: 10,
            label: '${fontProvider.fontScale.toStringAsFixed(1)}x',
            onChanged: (newScale) {
              fontProvider.setFontSize(newScale);
            },
          ),
        ),

        // Labels below slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smaller (1.0x)',
                style: TextStyle(
                  fontSize: fontProvider.scale(12),
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Default',
                style: TextStyle(
                  fontSize: fontProvider.scale(12),
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Larger (2.0x)',
                style: TextStyle(
                  fontSize: fontProvider.scale(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Real-time Live Preview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: fontProvider.scale(16),
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live Preview',
                    style: TextStyle(
                      fontSize: fontProvider.scale(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'John Mwangi',
                style: TextStyle(
                  fontSize: fontProvider.scale(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '+ KES 2,500.00',
                    style: TextStyle(
                      fontSize: fontProvider.scale(16),
                      fontWeight: FontWeight.w800,
                      color: AppColors.received,
                    ),
                  ),
                  Text(
                    'Today, 10:15 AM',
                    style: TextStyle(
                      fontSize: fontProvider.scale(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Code: QL9KJ3X • 📥 RECEIVED',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: fontProvider.scale(12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reset Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset to Default'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            onPressed: () => fontProvider.resetFontSize(),
          ),
        ),
      ],
    );
  }
}
