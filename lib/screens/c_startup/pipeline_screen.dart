import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'applicant_detail_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

typedef _StageInfo = ({
  PipelineStage stage,
  String label,
  Color tint,
  Color text,
});

class _PipelineScreenState extends State<PipelineScreen> {
  static const _stages = <_StageInfo>[
    (
      stage: PipelineStage.newApplicant,
      label: 'New',
      tint: AppColors.accentTint,
      text: AppColors.accentDeepText,
    ),
    (
      stage: PipelineStage.reviewing,
      label: 'Reviewing',
      tint: AppColors.statusReviewTint,
      text: AppColors.statusReviewText,
    ),
    (
      stage: PipelineStage.interview,
      label: 'Interview',
      tint: AppColors.statusInterviewTint,
      text: AppColors.statusInterviewText,
    ),
    (
      stage: PipelineStage.offer,
      label: 'Offer',
      tint: AppColors.statusAcceptedTint,
      text: AppColors.statusAcceptedText,
    ),
  ];

  List<Applicant> _liveApplicants = [];
  StreamSubscription<List<Applicant>>? _liveSub;

  List<Applicant> get _allApplicants => [
    ..._liveApplicants,
    ...Fixtures.applicants,
  ];

  @override
  void initState() {
    super.initState();
    _liveSub = MarketplaceRepository.instance
        .watchApplicantsForMyPostings()
        .listen((items) {
          if (mounted) setState(() => _liveApplicants = items);
        });
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    super.dispose();
  }

  bool _sortByMatch = false;

  List<Applicant> _forStage(PipelineStage stage) {
    final list = _allApplicants.where((a) => a.stage == stage).toList();
    if (_sortByMatch) {
      list.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    }
    return list;
  }

  void _toggleSort() {
    setState(() => _sortByMatch = !_sortByMatch);
    showAppToast(
      context,
      _sortByMatch ? 'Sorted by best match' : 'Sorted by most recent',
      icon: Symbols.tune_rounded,
    );
  }

  void _openApplicant(Applicant applicant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicantDetailScreen(applicant: applicant),
      ),
    );
  }

  void _moveApplicant(Applicant applicant, PipelineStage stage) {
    setState(() => applicant.stage = stage);
    if (applicant.isLive) {
      MarketplaceRepository.instance.updateStage(applicant, stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _allApplicants.length;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Applicants',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                CircleIconButton(
                  icon: Symbols.tune_rounded,
                  color: _sortByMatch ? AppColors.primary : AppColors.ink,
                  onTap: _toggleSort,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.hairline, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.work_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Flutter Developer Intern',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total total',
                          style: AppText.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Symbols.expand_more_rounded,
                    size: 20,
                    color: AppColors.inkFaint,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _stages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final info = _stages[i];
                  return _PipelineColumn(
                    info: info,
                    applicants: _forStage(info.stage),
                    onDropped: (applicant) =>
                        _moveApplicant(applicant, info.stage),
                    onTapApplicant: _openApplicant,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineColumn extends StatelessWidget {
  final _StageInfo info;
  final List<Applicant> applicants;
  final ValueChanged<Applicant> onDropped;
  final ValueChanged<Applicant> onTapApplicant;

  const _PipelineColumn({
    required this.info,
    required this.applicants,
    required this.onDropped,
    required this.onTapApplicant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 242,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                info.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: info.tint,
                  borderRadius: BorderRadius.circular(AppShape.pill),
                ),
                child: Text(
                  '${applicants.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: info.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DragTarget<Applicant>(
              onWillAcceptWithDetails: (details) =>
                  details.data.stage != info.stage,
              onAcceptWithDetails: (details) => onDropped(details.data),
              builder: (context, candidateData, rejectedData) {
                final highlighted = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: highlighted
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: applicants.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No applicants',
                              style: AppText.caption.copyWith(fontSize: 11.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: applicants.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final applicant = applicants[i];
                            return LongPressDraggable<Applicant>(
                              data: applicant,
                              feedback: _DragFeedback(applicant: applicant),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: ApplicantMiniCard(applicant: applicant),
                              ),
                              child: ApplicantMiniCard(
                                applicant: applicant,
                                onTap: () => onTapApplicant(applicant),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  final Applicant applicant;
  const _DragFeedback({required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.06,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 218,
          child: Transform.scale(
            scale: 1.05,
            child: ApplicantMiniCard(applicant: applicant),
          ),
        ),
      ),
    );
  }
}
