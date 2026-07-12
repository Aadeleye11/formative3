import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';
import 'buttons.dart';

/// Shared empty/error state: icon, title, subtitle, and an optional CTA.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Color circleColor;
  final Color iconColor;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.circleColor = AppColors.cream,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(icon, size: 54, color: iconColor),
                Positioned(
                  top: 4,
                  right: 16,
                  child: Icon(
                    Symbols.auto_awesome_rounded,
                    size: 15,
                    color: iconColor,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: .75),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: AppColors.inkSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: ctaLabel!,
                onPressed: onCta,
                height: 46,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
