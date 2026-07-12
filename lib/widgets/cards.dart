import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../data/models.dart';
import '../theme.dart';
import 'badges.dart';
import 'chips.dart';
import 'logo_tile.dart';
import 'match_ring.dart';

/// White list-row card for an opportunity, with a bookmark and match pill.
class OpportunityListCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const OpportunityListCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            boxShadow: AppShape.cardShadow,
          ),
          child: Row(
            children: [
              LogoTile(startup: opportunity.startup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            opportunity.startup.name,
                            style: AppText.caption.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Symbols.verified_rounded,
                          size: 13,
                          color: AppColors.primary,
                          fill: 1,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '· ${opportunity.location}',
                            style: AppText.caption.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onBookmarkTap,
                    child: Icon(
                      opportunity.saved
                          ? Symbols.bookmark_rounded
                          : Symbols.bookmark_rounded,
                      size: 20,
                      color: opportunity.saved
                          ? AppColors.primary
                          : AppColors.inkFaint,
                      fill: opportunity.saved ? 1 : 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentTint,
                      borderRadius: BorderRadius.circular(AppShape.pill),
                    ),
                    child: Text(
                      '${opportunity.matchPercent}%',
                      style: AppText.badgeLabel.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient hero card for the "Recommended for you" carousel.
class OpportunityHeroCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final Gradient gradient;
  final Color shadowColor;

  const OpportunityHeroCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.onBookmarkTap,
    this.gradient = AppColors.heroGradient,
    this.shadowColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 296,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppShape.heroRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: .28),
              offset: const Offset(0, 16),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    opportunity.startup.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onBookmarkTap,
                  child: Icon(
                    Symbols.bookmark_rounded,
                    color: Colors.white,
                    size: 22,
                    fill: opportunity.saved ? 1 : 0,
                  ),
                ),
                const SizedBox(width: 10),
                MatchRing.onGradient(
                  percent: opportunity.matchPercent,
                  size: 46,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              opportunity.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  opportunity.startup.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .92),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Symbols.verified_rounded,
                  color: Colors.white,
                  size: 14,
                  fill: 1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final s in opportunity.skills.take(3))
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(AppShape.pill),
                        ),
                        child: Text(
                          s,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Symbols.schedule_rounded,
                  size: 13,
                  color: Colors.white.withValues(alpha: .85),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${opportunity.commitment} · ${opportunity.postedLabel}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact card used in the startup pipeline kanban columns.
class ApplicantMiniCard extends StatelessWidget {
  final Applicant applicant;
  final VoidCallback? onTap;

  const ApplicantMiniCard({super.key, required this.applicant, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(
                    initials: applicant.initials,
                    size: 32,
                    gradient: applicant.avatarGradient,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          applicant.appliedLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Symbols.drag_indicator_rounded,
                    size: 16,
                    color: AppColors.inkFaint,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  ...applicant.skills
                      .take(2)
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: CategoryTint.forCategory(s).bg,
                              borderRadius: BorderRadius.circular(
                                AppShape.pill,
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: CategoryTint.forCategory(s).text,
                              ),
                            ),
                          ),
                        ),
                      ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentTint,
                      borderRadius: BorderRadius.circular(AppShape.pill),
                    ),
                    child: Text(
                      '${applicant.matchPercent}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Application tracking row for the Applications list.
class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;

  const ApplicationCard({super.key, required this.application, this.onTap});

  @override
  Widget build(BuildContext context) {
    final closed = application.status == ApplicationStatus.closed;
    return Opacity(
      opacity: closed ? .55 : 1,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              boxShadow: AppShape.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LogoTile(startup: application.opportunity.startup),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.opportunity.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  application.opportunity.startup.name,
                                  style: AppText.caption.copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Symbols.verified_rounded,
                                size: 13,
                                color: AppColors.primary,
                                fill: 1,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '· ${application.appliedLabel}',
                                  style: AppText.caption.copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: application.status),
                  ],
                ),
                if (application.interviewInfo != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Symbols.event_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            application.interviewInfo!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
