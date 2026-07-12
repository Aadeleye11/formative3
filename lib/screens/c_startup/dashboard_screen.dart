import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../b_student/notifications_screen.dart';
import 'analytics_screen.dart';
import 'applicant_detail_screen.dart';
import 'no_startup_prompt.dart';
import 'post_role_screen.dart';
import 'postings_screen.dart';
import 'startup_messages_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StartupBrand?>(
      stream: MarketplaceRepository.instance.watchMyStartup(),
      builder: (context, startupSnap) {
        if (startupSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final startup = startupSnap.data;
        if (startup == null) {
          return const NoStartupPrompt();
        }
        return StreamBuilder<List<Opportunity>>(
          stream: MarketplaceRepository.instance.watchMyPostings(),
          builder: (context, postingsSnap) {
            final postings = postingsSnap.data ?? const <Opportunity>[];
            return StreamBuilder<List<Applicant>>(
              stream: MarketplaceRepository.instance
                  .watchApplicantsForMyPostings(),
              builder: (context, applicantsSnap) {
                final applicants = applicantsSnap.data ?? const <Applicant>[];
                return _build(context, startup, applicants, postings);
              },
            );
          },
        );
      },
    );
  }

  Widget _build(
    BuildContext context,
    StartupBrand startup,
    List<Applicant> applicants,
    List<Opportunity> postings,
  ) {
    final newApplicants = applicants
        .where((a) => a.stage == PipelineStage.newApplicant)
        .toList();
    final inPipeline = applicants
        .where(
          (a) =>
              a.stage == PipelineStage.reviewing ||
              a.stage == PipelineStage.interview,
        )
        .length;
    final offers = applicants
        .where((a) => a.stage == PipelineStage.offer)
        .length;
    final recentPostings = postings.take(2).toList();

    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LogoTile(startup: startup),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, ${startup.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const VerifiedBadge(),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${startup.category} · ${startup.stage}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.caption.copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleIconButton(
                    icon: Symbols.notifications_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleIconButton(
                    icon: Symbols.chat_bubble_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StartupMessagesListScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppShape.sectionGap),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _KpiCard(
                    label: 'Active roles',
                    value: '${postings.length}',
                    barColor: AppColors.primary,
                  ),
                  _KpiCard(
                    label: 'New applicants',
                    value: '${newApplicants.length}',
                    barColor: AppColors.success,
                  ),
                  _KpiCard(
                    label: 'In pipeline',
                    value: '$inPipeline',
                    barColor: AppColors.statusReview,
                  ),
                  _KpiCard(
                    label: 'Offers extended',
                    value: '$offers',
                    barColor: AppColors.accent,
                  ),
                ],
              ),
              if (newApplicants.isNotEmpty) ...[
                const SizedBox(height: AppShape.sectionGap),
                Row(
                  children: [
                    const Text(
                      'Needs attention',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppShape.pill),
                      ),
                      child: Text(
                        '${newApplicants.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppShape.cardShadow,
                    ),
                    child: Column(
                      children: [
                        for (
                          var i = 0;
                          i < newApplicants.take(3).length;
                          i++
                        ) ...[
                          if (i != 0)
                            const Divider(height: 1, indent: 14, endIndent: 14),
                          _AttentionRow(
                            leading: InitialsAvatar(
                              initials: newApplicants[i].initials,
                              size: 40,
                              gradient: newApplicants[i].avatarGradient,
                            ),
                            title: 'New applicant · ${newApplicants[i].name}',
                            subtitle: newApplicants[i].opportunityTitle.isEmpty
                                ? '${newApplicants[i].matchPercent}% match · ${newApplicants[i].appliedLabel}'
                                : '${newApplicants[i].opportunityTitle} · ${newApplicants[i].matchPercent}% match',
                            chipLabel: 'Review',
                            chipColor: AppColors.primary,
                            chipFill: AppColors.accentTint,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ApplicantDetailScreen(
                                  applicant: newApplicants[i],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppShape.sectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active postings',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextLinkButton(
                    label: 'See all',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PostingsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recentPostings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShape.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Symbols.description_rounded,
                        size: 32,
                        color: AppColors.inkFaint,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No postings yet',
                        style: AppText.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Post your first role to start meeting ALU talent.',
                        textAlign: TextAlign.center,
                        style: AppText.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 172,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentPostings.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final posting = recentPostings[i];
                      final forThisPosting = applicants
                          .where((a) => a.opportunityId == posting.id)
                          .toList();
                      return _PostingCard(
                        opportunity: posting,
                        applicants: forThisPosting,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 8,
            child: SizedBox(
              width: 188,
              child: BrandButton(
                label: '+ Post a role',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PostRoleScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color barColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppText.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final String chipLabel;
  final Color chipColor;
  final Color chipFill;
  final VoidCallback onTap;

  const _AttentionRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.chipColor,
    required this.chipFill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppText.caption.copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipFill,
                borderRadius: BorderRadius.circular(AppShape.pill),
              ),
              child: Text(
                chipLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: chipColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostingCard extends StatelessWidget {
  final Opportunity opportunity;
  final List<Applicant> applicants;
  final VoidCallback onTap;

  const _PostingCard({
    required this.opportunity,
    required this.applicants,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shown = applicants.take(3).toList();
    final extra = (applicants.length - shown.length).clamp(0, 999);
    final live = !opportunity.closesLabel.contains('Closed');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 208,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: live ? AppColors.success : AppColors.inkMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    live ? 'Live' : 'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: live ? AppColors.successDeep : AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '· ${opportunity.closesLabel}',
                      style: AppText.caption.copyWith(fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                opportunity.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                applicants.isEmpty
                    ? 'No applicants yet'
                    : '${applicants.length} applicant${applicants.length == 1 ? '' : 's'}',
                style: AppText.caption.copyWith(fontSize: 11.5),
              ),
              const Spacer(),
              if (shown.isNotEmpty)
                Row(
                  children: [
                    SizedBox(
                      width: 20.0 * shown.length + 14,
                      height: 24,
                      child: Stack(
                        children: [
                          for (var i = 0; i < shown.length; i++)
                            Positioned(
                              left: i * 14.0,
                              child: Container(
                                padding: const EdgeInsets.all(1.5),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: InitialsAvatar(
                                  initials: shown[i].initials,
                                  size: 21,
                                  gradient: shown[i].avatarGradient,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (extra > 0)
                      Text(
                        '+$extra',
                        style: AppText.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
