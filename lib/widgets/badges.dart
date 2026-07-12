import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../data/models.dart';
import '../theme.dart';

class StatusTint {
  final Color bg;
  final Color text;
  const StatusTint(this.bg, this.text);
}

StatusTint statusTint(ApplicationStatus status) => switch (status) {
  ApplicationStatus.applied => const StatusTint(
    AppColors.accentTint,
    AppColors.primary,
  ),
  ApplicationStatus.reviewing => const StatusTint(
    AppColors.statusReviewTint,
    AppColors.statusReviewText,
  ),
  ApplicationStatus.interview => const StatusTint(
    AppColors.statusInterviewTint,
    AppColors.statusInterviewText,
  ),
  ApplicationStatus.shortlisted => const StatusTint(
    AppColors.statusAcceptedTint,
    AppColors.statusAcceptedText,
  ),
  ApplicationStatus.accepted => const StatusTint(
    AppColors.statusAcceptedTint,
    AppColors.statusAcceptedText,
  ),
  ApplicationStatus.closed => const StatusTint(
    AppColors.statusClosedTint,
    AppColors.statusClosedText,
  ),
  ApplicationStatus.declined => const StatusTint(
    AppColors.dangerTint,
    AppColors.dangerText,
  ),
};

/// Tint bg + colored label — never color alone.
class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = statusTint(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Text(
        status.label,
        style: AppText.badgeLabel.copyWith(color: t.text, fontSize: 10.5),
      ),
    );
  }
}

/// The "✓ ALU Verified" pill used across cards, profiles, chat headers.
class VerifiedBadge extends StatelessWidget {
  final bool pillStyle;
  const VerifiedBadge({super.key, this.pillStyle = true});

  @override
  Widget build(BuildContext context) {
    if (!pillStyle) {
      return const Icon(
        Symbols.verified_rounded,
        size: 14,
        color: AppColors.primary,
        fill: 1,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentTint,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.verified_rounded,
            size: 12,
            color: AppColors.primary,
            fill: 1,
          ),
          SizedBox(width: 3),
          Text(
            'ALU Verified',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
