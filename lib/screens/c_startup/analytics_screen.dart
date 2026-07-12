import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

typedef _FunnelStep = ({String label, int value, Color color});

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Applicant>>(
      stream: MarketplaceRepository.instance.watchApplicantsForMyPostings(),
      builder: (context, snapshot) {
        final applicants = [
          ...snapshot.data ?? const <Applicant>[],
          ...Fixtures.applicants,
        ];
        return _build(context, applicants);
      },
    );
  }

  Widget _build(BuildContext context, List<Applicant> applicants) {
    final applied = applicants.length;
    final interviewing = applicants
        .where(
          (a) =>
              a.stage == PipelineStage.interview ||
              a.stage == PipelineStage.offer,
        )
        .length;
    final offers = applicants
        .where((a) => a.stage == PipelineStage.offer)
        .length;
    final funnelSteps = <_FunnelStep>[
      (label: 'Applications', value: applied, color: AppColors.catDesign),
      (label: 'Interviews', value: interviewing, color: AppColors.catData),
      (label: 'Offers', value: offers, color: AppColors.catMarketing),
    ];

    final skillCounts = <String, int>{};
    for (final a in applicants) {
      for (final s in a.skills) {
        skillCounts[s] = (skillCounts[s] ?? 0) + 1;
      }
    }
    final topSkills = skillCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 18),
              _funnelCard(funnelSteps),
              const SizedBox(height: 16),
              _skillsCard(topSkills.take(5).toList()),
              const SizedBox(height: 12),
              Text(
                'View counts and weekly trend need page-view tracking, which '
                "isn't wired up yet — everything above is computed from your "
                'real applicants.',
                style: AppText.caption.copyWith(fontSize: 11.5, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _funnelCard(List<_FunnelStep> steps) {
    final maxValue = steps.isEmpty
        ? 1
        : steps
              .map((s) => s.value)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, 1 << 30);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Funnel',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 14),
              child: _FunnelRow(step: steps[i], maxValue: maxValue),
            ),
        ],
      ),
    );
  }

  Widget _skillsCard(List<MapEntry<String, int>> topSkills) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top skills among applicants',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          if (topSkills.isEmpty)
            Text(
              'No applicants yet.',
              style: AppText.caption.copyWith(fontSize: 12.5),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in topSkills)
                  EndorsementChip(
                    label: s.key,
                    count: s.value,
                    tint: CategoryTint.forCategory(s.key),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  final _FunnelStep step;
  final int maxValue;

  const _FunnelRow({required this.step, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final frac = (step.value / maxValue).clamp(0.05, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                step.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${step.value}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            height: 20,
            width: constraints.maxWidth * frac,
            decoration: BoxDecoration(
              color: step.color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
