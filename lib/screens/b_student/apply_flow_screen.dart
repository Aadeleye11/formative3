import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'student_shell.dart';

class ApplyFlowScreen extends StatefulWidget {
  final Opportunity opportunity;
  const ApplyFlowScreen({super.key, required this.opportunity});

  @override
  State<ApplyFlowScreen> createState() => _ApplyFlowScreenState();
}

class _ApplyFlowScreenState extends State<ApplyFlowScreen> {
  int step = 0;
  final motivationController = TextEditingController();
  bool githubSelected = true;
  bool behanceSelected = false;
  bool driveSelected = false;
  bool sharePassport = true;
  int hoursChoice = 1;
  late final ConfettiController _confetti;
  late final Map<String, TextEditingController> _shortAnswerControllers;
  late final Map<String, int?> _singleChoiceSelections;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
      duration: const Duration(milliseconds: 1400),
    );
    _shortAnswerControllers = {
      for (final q in widget.opportunity.screeningQuestions)
        if (q.type == ScreeningQuestionType.shortAnswer)
          q.id: TextEditingController(),
    };
    _singleChoiceSelections = {
      for (final q in widget.opportunity.screeningQuestions)
        if (q.type == ScreeningQuestionType.singleChoice) q.id: null,
    };
  }

  @override
  void dispose() {
    _confetti.dispose();
    motivationController.dispose();
    for (final c in _shortAnswerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  static const _hoursLabels = ['Up to 5 hrs', '8–10 hrs', '10+ hrs'];
  bool _submitting = false;

  bool get _screeningComplete {
    for (final q in widget.opportunity.screeningQuestions) {
      if (q.type == ScreeningQuestionType.shortAnswer) {
        if ((_shortAnswerControllers[q.id]?.text.trim() ?? '').isEmpty) {
          return false;
        }
      } else if (_singleChoiceSelections[q.id] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final screeningAnswers = <String, String>{
        for (final q in widget.opportunity.screeningQuestions)
          q.question: q.type == ScreeningQuestionType.shortAnswer
              ? (_shortAnswerControllers[q.id]?.text.trim() ?? '')
              : q.options[_singleChoiceSelections[q.id]!],
      };
      await MarketplaceRepository.instance.apply(
        opportunity: widget.opportunity,
        motivation: motivationController.text,
        screeningAnswers: screeningAnswers,
        hoursChoice: _hoursLabels[hoursChoice],
      );
      if (!mounted) return;
      setState(() => step = 2);
      _confetti.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppToast(
        context,
        "Couldn't submit application. Please try again.",
        icon: Symbols.error_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (step == 2) return _successView(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => step == 0
                        ? Navigator.of(context).pop()
                        : setState(() => step--),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Apply · ${widget.opportunity.title}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.opportunity.startup.name,
                          style: AppText.caption.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Step ${step + 1} of 2',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE4D8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: step == 0 ? 0.5 : 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: step == 0 ? _stepOne() : _stepTwo(),
                  ),
                ),
              ),
              step == 0
                  ? PrimaryButton(
                      label: 'Continue',
                      trailingIcon: Symbols.arrow_forward_rounded,
                      onPressed: motivationController.text.trim().isNotEmpty
                          ? () => setState(() => step = 1)
                          : null,
                    )
                  : Column(
                      children: [
                        BrandButton(
                          label: _submitting
                              ? 'Submitting…'
                              : 'Submit application',
                          onPressed: _submitting || !_screeningComplete
                              ? null
                              : _submit,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You can withdraw anytime from Applications.',
                          style: AppText.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const InitialsAvatar(initials: 'AH', size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amina Hassan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "${Fixtures.amina.program} · ${Fixtures.amina.cohort}",
                          style: AppText.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.edit_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: Fixtures.amina.skills
                    .take(3)
                    .map((s) => TagChip(label: s))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(
                    Symbols.verified_rounded,
                    size: 13,
                    color: AppColors.primary,
                    fill: 1,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Auto-filled from your profile — tap to edit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Motivation note',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            Text(
              '${motivationController.text.length}/300',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: motivationController,
          hint: 'Why do you want this role, and what can you bring to it?',
          maxLines: 5,
          maxLength: 300,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text(
          'Portfolio links',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SelectableChip.tint(
              label: 'GitHub',
              selected: githubSelected,
              onTap: () => setState(() => githubSelected = !githubSelected),
            ),
            const SizedBox(width: 8),
            SelectableChip.tint(
              label: 'Behance',
              selected: behanceSelected,
              onTap: () => setState(() => behanceSelected = !behanceSelected),
            ),
            const SizedBox(width: 8),
            SelectableChip.tint(
              label: 'Drive',
              selected: driveSelected,
              onTap: () => setState(() => driveSelected = !driveSelected),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShape.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Symbols.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Experience Passport',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      Fixtures.passportSummary,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: sharePassport,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => setState(() => sharePassport = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepTwo() {
    final questions = widget.opportunity.screeningQuestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (questions.isNotEmpty) ...[
          Text(
            '${widget.opportunity.startup.name} asks every applicant:',
            style: AppText.caption.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < questions.length; i++) ...[
            _questionAnswerCard(questions[i], i + 1),
            const SizedBox(height: 12),
          ],
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${questions.length + 1} · How many hours can you commit weekly?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              for (final e in _hoursLabels.asMap().entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _optionRow(
                    label: e.value,
                    selected: hoursChoice == e.key,
                    onTap: () => setState(() => hoursChoice = e.key),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionAnswerCard(ScreeningQuestion q, int number) {
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
          Text(
            '$number · ${q.question}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          if (q.type == ScreeningQuestionType.shortAnswer)
            AppTextField(
              controller: _shortAnswerControllers[q.id],
              maxLines: 3,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
            )
          else
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _optionRow(
                  label: q.options[i],
                  selected: _singleChoiceSelections[q.id] == i,
                  onTap: () => setState(() => _singleChoiceSelections[q.id] = i),
                ),
              ),
        ],
      ),
    );
  }

  Widget _optionRow({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFEBE4D8),
            width: 1.5,
          ),
          color: selected ? const Color(0xFFF0F2F9) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.ink : const Color(0xFF4A4F64),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFD6D8E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _successView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              maxBlastForce: 18,
              minBlastForce: 6,
              gravity: 0.25,
              colors: const [
                AppColors.primary,
                AppColors.brand,
                AppColors.success,
                Color(0xFFE09F3E),
                AppColors.accent,
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: .08),
                          blurRadius: 0,
                          spreadRadius: 18,
                        ),
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: .32),
                          offset: const Offset(0, 24),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Symbols.check_rounded,
                      color: Colors.white,
                      size: 60,
                      weight: 700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Application sent\nto ${widget.opportunity.startup.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "They usually respond within 3 days. We'll ping you the moment your status changes.",
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      color: AppColors.inkSecondary,
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 34),
                  BrandButton(
                    label: 'Track application',
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const StudentShell(initialIndex: 2),
                      ),
                      (route) => false,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextLinkButton(
                    label: 'Explore more opportunities',
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
