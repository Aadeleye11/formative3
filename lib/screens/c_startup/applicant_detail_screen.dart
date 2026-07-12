import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'scheduler_screen.dart';
import 'startup_chat_thread_screen.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Applicant applicant;
  const ApplicantDetailScreen({super.key, required this.applicant});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  Future<void> _decline() async {
    final a = widget.applicant;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Decline ${a.name}?'),
        content: const Text(
          "They'll be notified that this application wasn't selected. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Decline',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (a.isLive) {
      await MarketplaceRepository.instance.declineApplicant(a);
    }
    if (!mounted) return;
    showAppToast(context, '${a.name} declined');
    Navigator.of(context).pop();
  }

  Future<void> _extendOffer() async {
    final a = widget.applicant;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Extend an offer to ${a.name}?'),
        content: Text(
          "They'll be notified immediately that they got the role"
          '${a.opportunityTitle.isEmpty ? '' : ' — ${a.opportunityTitle}'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Extend offer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => a.stage = PipelineStage.offer);
    if (a.isLive) {
      await MarketplaceRepository.instance.updateStage(a, PipelineStage.offer);
    }
    if (!mounted) return;
    showAppToast(context, 'Offer sent to ${a.name}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.applicant;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleIconButton(
                          icon: Symbols.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          a.opportunityTitle.isEmpty
                              ? 'Applied ${a.appliedLabel}'
                              : 'Applied ${a.appliedLabel} · ${a.opportunityTitle}',
                          style: AppText.caption.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InitialsAvatar(
                          initials: a.initials,
                          size: 60,
                          gradient: a.avatarGradient,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${a.program} · ${a.cohort} · ${a.city}',
                                style: AppText.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        MatchRing(
                          percent: a.matchPercent,
                          size: 54,
                          strokeWidth: 6,
                          fontSize: 13,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShape.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Symbols.insights_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Match Breakdown',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _FitBar(
                            label: 'Skills',
                            value: a.skillsFit,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 10),
                          _FitBar(
                            label: 'Availability',
                            value: a.availabilityFit,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 10),
                          _FitBar(
                            label: 'Interests',
                            value: a.interestsFit,
                            color: AppColors.statusReview,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShape.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MOTIVATION',
                            style: AppText.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${a.motivation}"',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF4A4F64),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ScreeningSection(screening: a.screening),
                    if (a.passportEntry != null) ...[
                      const SizedBox(height: 16),
                      _PassportSummaryCard(entry: a.passportEntry!),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    _SquareIconButton(
                      icon: Symbols.chat_bubble_rounded,
                      color: AppColors.ink,
                      borderColor: AppColors.hairline,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StartupChatThreadScreen(
                            studentUid: a.studentUid,
                            studentName: a.name,
                            studentInitials: a.initials,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SquareIconButton(
                      icon: Symbols.close_rounded,
                      color: AppColors.danger,
                      borderColor: AppColors.danger.withValues(alpha: .35),
                      onTap: _decline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: AppShape.buttonHeightSecondary,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SchedulerScreen(applicant: a),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.event_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Schedule',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: AppShape.buttonHeightSecondary,
                        child: FilledButton(
                          onPressed: _extendOffer,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.celebration_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Extend offer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FitBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _FitBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = value.clamp(0.0, 1.0);
    final pct = (fraction * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppShape.pill),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppShape.pill),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _ScreeningSection extends StatefulWidget {
  final Map<String, String> screening;
  const _ScreeningSection({required this.screening});

  @override
  State<_ScreeningSection> createState() => _ScreeningSectionState();
}

class _ScreeningSectionState extends State<_ScreeningSection> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final entries = widget.screening.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SCREENING ANSWERS',
          style: AppText.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 8),
            child: _ScreeningRow(
              question: entries[i].key,
              answer: entries[i].value,
              expanded: _expanded == i,
              onTap: () => setState(() => _expanded = _expanded == i ? -1 : i),
            ),
          ),
      ],
    );
  }
}

class _ScreeningRow extends StatelessWidget {
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;

  const _ScreeningRow({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!expanded) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppShape.pill),
                        ),
                        child: Text(
                          answer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption.copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    expanded
                        ? Symbols.expand_less_rounded
                        : Symbols.expand_more_rounded,
                    size: 20,
                    color: AppColors.inkMuted,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4F64),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PassportSummaryCard extends StatelessWidget {
  final PassportEntry entry;
  const _PassportSummaryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Symbols.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Experience Passport',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successTint,
                    borderRadius: BorderRadius.circular(AppShape.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.verified_rounded,
                        size: 11,
                        color: AppColors.successDeep,
                        fill: 1,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '2 verified',
                        style: AppText.chipLabel.copyWith(
                          color: AppColors.successDeep,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LogoTile(startup: entry.startup, size: 36, radius: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.role,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.startup.name} · ${entry.dates}',
                        style: AppText.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.accentTint, width: 2.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.quote,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4A4F64),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '— ${entry.author}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.skills.map((s) => CheckChip(label: s)).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.verified_rounded,
                    size: 14,
                    color: AppColors.inkMuted,
                    fill: 1,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.verifiedOn,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: AppShape.buttonHeightSecondary,
          height: AppShape.buttonHeightSecondary,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
