import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../data/skills.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

const _compensationOptions = ['Unpaid', 'Stipend', 'Equity', 'Academic credit'];

class PostRoleScreen extends StatefulWidget {
  const PostRoleScreen({super.key});

  @override
  State<PostRoleScreen> createState() => _PostRoleScreenState();
}

class _PostRoleScreenState extends State<PostRoleScreen> {
  int step = 0;

  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final descController = TextEditingController();
  final skills = <String>[];

  double hours = 9;
  int locationIndex = 1;
  int compIndex = 1;
  final amountController = TextEditingController();
  final durationController = TextEditingController();
  final deadlineController = TextEditingController();
  DateTime? _deadline;
  StartupBrand? _myStartup;

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _deadline = picked;
      deadlineController.text = '${_monthAbbr[picked.month - 1]} ${picked.day}';
    });
  }

  int _questionSeq = 0;
  final List<ScreeningQuestion> _questions = [];
  String _newQuestionId() => 'q${_questionSeq++}';

  @override
  void initState() {
    super.initState();
    MarketplaceRepository.instance.getMyStartupOnce().then((startup) {
      if (mounted) setState(() => _myStartup = startup);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    descController.dispose();
    amountController.dispose();
    durationController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  void _back() {
    if (step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => step--);
    }
  }

  Opportunity _buildOpportunity({
    required int matchPercent,
    required int applicantsCount,
  }) {
    final locationLabel = switch (locationIndex) {
      0 => 'Remote',
      2 => 'Hybrid',
      _ => 'On-campus · Kigali',
    };
    final compLabel = _compensationOptions[compIndex];
    final compensation = compLabel == 'Stipend'
        ? 'Stipend · ${amountController.text}'
        : compLabel;
    return Opportunity(
      id: 'role-${DateTime.now().microsecondsSinceEpoch}',
      title: titleController.text,
      startup:
          _myStartup ??
          const StartupBrand(
            name: 'My Startup',
            gradient: AppColors.avatarGradient,
            icon: Symbols.storefront_rounded,
            category: '',
            stage: '',
            city: '',
            teamSize: 1,
            founded: 2026,
            oneLiner: '',
            description: '',
          ),
      category: categoryController.text,
      skills: List<String>.from(skills),
      commitment: 'Part-time · ${hours.round()} hrs/wk',
      location: locationLabel,
      compensation: compensation,
      postedLabel: 'Posted just now',
      closesLabel: 'Closes ${deadlineController.text}',
      applicantsCount: applicantsCount,
      matchPercent: matchPercent,
      description: descController.text,
      screeningQuestions: List<ScreeningQuestion>.from(_questions),
    );
  }

  bool _publishing = false;

  Future<void> _publish() async {
    setState(() => _publishing = true);
    final locationLabel = switch (locationIndex) {
      0 => 'Remote',
      2 => 'Hybrid',
      _ => 'On-campus · Kigali',
    };
    final compLabel = _compensationOptions[compIndex];
    final compensation = compLabel == 'Stipend'
        ? 'Stipend · ${amountController.text}'
        : compLabel;
    try {
      await MarketplaceRepository.instance.postOpportunity(
        title: titleController.text,
        category: categoryController.text,
        skills: List<String>.from(skills),
        commitment: 'Part-time · ${hours.round()} hrs/wk',
        location: locationLabel,
        compensation: compensation,
        description: descController.text,
        closesLabel: 'Closes ${deadlineController.text}',
        screeningQuestions: _questions,
      );
      if (!mounted) return;
      showAppToast(context, 'Your role is live', actionLabel: 'View');
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('postOpportunity failed: $e\n$st');
      if (!mounted) return;
      setState(() => _publishing = false);
      showAppToast(
        context,
        "Couldn't publish. Please try again.",
        icon: Symbols.error_rounded,
      );
    }
  }

  Widget _bottomButton() {
    switch (step) {
      case 0:
        final canContinue =
            titleController.text.trim().isNotEmpty &&
            descController.text.trim().isNotEmpty;
        return PrimaryButton(
          label: 'Continue',
          trailingIcon: Symbols.arrow_forward_rounded,
          onPressed: canContinue ? () => setState(() => step++) : null,
        );
      case 1:
        return PrimaryButton(
          label: 'Continue',
          trailingIcon: Symbols.arrow_forward_rounded,
          onPressed: () => setState(() => step++),
        );
      case 2:
        return PrimaryButton(
          label: 'Preview role',
          trailingIcon: Symbols.visibility_rounded,
          onPressed: () => setState(() => step++),
        );
      default:
        return BrandButton(
          label: _publishing ? 'Publishing…' : 'Publish role',
          onPressed: _publishing ? null : _publish,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: step == 0
                        ? Symbols.close_rounded
                        : Symbols.arrow_back_rounded,
                    onTap: _back,
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            step == 3 ? 'Preview' : 'Post a role',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (step == 3) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Exactly as students see it',
                              style: AppText.caption.copyWith(fontSize: 11.5),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              if (step < 3) ...[
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                        decoration: BoxDecoration(
                          color: i <= step
                              ? AppColors.primary
                              : const Color(0xFFEBE4D8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${step + 1} of 3',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: switch (step) {
                      0 => _detailsStep(),
                      1 => _logisticsStep(),
                      2 => _screeningStep(),
                      _ => _previewStep(),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _bottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role title',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: titleController,
          hint: 'e.g. Flutter Developer Intern',
          icon: Symbols.work_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text(
          'Category',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: categoryController,
          hint: 'e.g. Engineering, Design, Marketing…',
          icon: Symbols.category_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            Text(
              '${descController.text.length}/500',
              style: AppText.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: descController,
          hint: 'What will they actually work on? Be specific.',
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text(
          'Skills required',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [...skills.map(_skillChip), _addSkillGhostChip()],
        ),
      ],
    );
  }

  Widget _skillChip(String skill) {
    final tint = CategoryTint.forCategory(skill);
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: tint.bg,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: AppText.chipLabel.copyWith(color: tint.text, fontSize: 11.5),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => skills.remove(skill)),
            child: Icon(Symbols.close_rounded, size: 14, color: tint.text),
          ),
        ],
      ),
    );
  }

  Widget _addSkillGhostChip() {
    return GestureDetector(
      onTap: _openAddSkillSheet,
      child: _DashedBox(
        radius: AppShape.pill,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.add_rounded, size: 14, color: AppColors.inkSecondary),
            SizedBox(width: 4),
            Text(
              'Add skill',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddSkillSheet() {
    String query = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final pool = query.isEmpty
                ? kPopularSkills
                : kAllSkills.where(
                    (s) => s.toLowerCase().contains(query.toLowerCase()),
                  );
            final options = pool.where((s) => !skills.contains(s)).toList();
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.hairline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Add a skill',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    hint: 'Search skills…',
                    icon: Symbols.search_rounded,
                    onChanged: (v) => setSheetState(() => query = v.trim()),
                  ),
                  const SizedBox(height: 16),
                  if (options.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        query.isEmpty
                            ? 'All popular skills are already added.'
                            : 'No skills match "$query".',
                        style: AppText.caption.copyWith(fontSize: 12.5),
                      ),
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: options
                              .map(
                                (s) => GestureDetector(
                                  onTap: () {
                                    setState(() => skills.add(s));
                                    Navigator.of(sheetContext).pop();
                                  },
                                  child: TagChip(label: s),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _logisticsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly commitment',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: const Color(0xFFEBE4D8),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 13,
                    elevation: 3,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                  valueIndicatorColor: AppColors.ink,
                ),
                child: Slider(
                  value: hours,
                  min: 2,
                  max: 20,
                  divisions: 18,
                  label: '${hours.round()} hrs/wk',
                  onChanged: (v) => setState(() => hours = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '2 hrs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    Text(
                      '${hours.round()} hrs/wk',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      '20 hrs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Location',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        AppSegmentedControl(
          labels: const ['Remote', 'On-campus', 'Hybrid'],
          index: locationIndex,
          onChanged: (i) => setState(() => locationIndex = i),
        ),
        const SizedBox(height: 20),
        const Text(
          'Compensation',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _compensationOptions.length,
            (i) => SelectableChip(
              label: _compensationOptions[i],
              selected: compIndex == i,
              onTap: () => setState(() => compIndex = i),
            ),
          ),
        ),
        if (_compensationOptions[compIndex] == 'Stipend') ...[
          const SizedBox(height: 12),
          AppTextField(
            controller: amountController,
            hint: 'e.g. 30,000 RWF / month',
            icon: Symbols.payments_rounded,
          ),
        ],
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: durationController,
                    hint: 'e.g. 3 months',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deadline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: deadlineController,
                    hint: 'Select a date',
                    icon: Symbols.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDeadline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _screeningStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Screening questions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Ask up to 3 quick questions to prioritize the strongest applicants.',
          style: AppText.caption.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 14),
        if (_questions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'No questions yet — applicants will only answer with their motivation note.',
              style: AppText.caption.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _questions.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final q = _questions.removeAt(oldIndex);
                _questions.insert(newIndex, q);
              });
            },
            itemBuilder: (context, i) => Padding(
              key: ValueKey(_questions[i].id),
              padding: const EdgeInsets.only(bottom: 10),
              child: _questionCard(_questions[i], i),
            ),
          ),
        const SizedBox(height: 4),
        if (_questions.length < 3)
          GestureDetector(
            onTap: () => _openQuestionEditor(),
            child: SizedBox(width: double.infinity, child: _addQuestionRow()),
          )
        else
          Text(
            'Maximum of 3 questions reached.',
            style: AppText.caption.copyWith(fontSize: 11.5),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Symbols.info_rounded,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Great screening questions boost your match quality signal for students.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentDeepText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionCard(ScreeningQuestion q, int index) {
    final typeTag = q.type == ScreeningQuestionType.shortAnswer
        ? 'SHORT ANSWER · 200 CHARS'
        : 'SINGLE CHOICE';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openQuestionEditor(existing: q),
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
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Symbols.drag_indicator_rounded,
                      size: 18,
                      color: AppColors.inkFaint,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      typeTag,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDeepText,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _questions.removeAt(index)),
                    child: const Icon(
                      Symbols.close_rounded,
                      size: 18,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                q.question,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (q.type == ScreeningQuestionType.singleChoice) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: q.options
                      .map(
                        (o) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(
                              AppShape.pill,
                            ),
                          ),
                          child: Text(
                            o,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _addQuestionRow() {
    return _DashedBox(
      radius: 14,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.add_rounded, size: 16, color: AppColors.inkSecondary),
          SizedBox(width: 6),
          Text(
            'Add question',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openQuestionEditor({ScreeningQuestion? existing}) {
    var type = existing?.type ?? ScreeningQuestionType.shortAnswer;
    final questionController = TextEditingController(
      text: existing?.question ?? '',
    );
    final optionControllers = <TextEditingController>[
      for (final o in existing != null && existing.options.isNotEmpty
          ? existing.options
          : const ['', ''])
        TextEditingController(text: o),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final canSave =
                questionController.text.trim().isNotEmpty &&
                (type == ScreeningQuestionType.shortAnswer ||
                    optionControllers
                            .where((c) => c.text.trim().isNotEmpty)
                            .length >=
                        2);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.hairline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      existing == null ? 'Add a question' : 'Edit question',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppSegmentedControl(
                      labels: const ['Short answer', 'Single choice'],
                      index: type == ScreeningQuestionType.shortAnswer
                          ? 0
                          : 1,
                      onChanged: (i) => setSheetState(
                        () => type = i == 0
                            ? ScreeningQuestionType.shortAnswer
                            : ScreeningQuestionType.singleChoice,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Question',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: questionController,
                      hint: 'e.g. Why do you want to join us?',
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    if (type == ScreeningQuestionType.singleChoice) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (var i = 0; i < optionControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: optionControllers[i],
                                  hint: 'Option ${i + 1}',
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                              if (optionControllers.length > 2) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setSheetState(
                                    () => optionControllers.removeAt(i),
                                  ),
                                  child: const Icon(
                                    Symbols.close_rounded,
                                    size: 20,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (optionControllers.length < 5)
                        GestureDetector(
                          onTap: () => setSheetState(
                            () => optionControllers.add(
                              TextEditingController(),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.add_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Add option',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: existing == null
                          ? 'Add question'
                          : 'Save changes',
                      onPressed: canSave
                          ? () {
                              final q = ScreeningQuestion(
                                id: existing?.id ?? _newQuestionId(),
                                type: type,
                                question: questionController.text.trim(),
                                options:
                                    type == ScreeningQuestionType.singleChoice
                                    ? optionControllers
                                          .map((c) => c.text.trim())
                                          .where((s) => s.isNotEmpty)
                                          .toList()
                                    : const [],
                              );
                              setState(() {
                                if (existing == null) {
                                  _questions.add(q);
                                } else {
                                  final idx = _questions.indexWhere(
                                    (e) => e.id == existing.id,
                                  );
                                  _questions[idx] = q;
                                }
                              });
                              Navigator.of(sheetContext).pop();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _previewStep() {
    final preview = _buildOpportunity(matchPercent: 0, applicantsCount: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: _DashedBox(
            radius: 24,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OpportunityListCard(opportunity: preview),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShape.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _previewInfoRow(
                        Symbols.schedule_rounded,
                        preview.commitment,
                      ),
                      const SizedBox(height: 10),
                      _previewInfoRow(
                        Symbols.location_on_rounded,
                        preview.location,
                      ),
                      const SizedBox(height: 10),
                      _previewInfoRow(
                        Symbols.payments_rounded,
                        preview.compensation,
                      ),
                      const SizedBox(height: 10),
                      _previewInfoRow(
                        Symbols.timer_rounded,
                        preview.closesLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Symbols.auto_awesome_rounded,
                      size: 13,
                      color: AppColors.inkSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Match % is computed per student by SkillSync',
                        style: AppText.caption.copyWith(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Symbols.celebration_rounded,
                size: 18,
                color: AppColors.success,
                fill: 1,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your role is live',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const Text(
                'View',
                style: TextStyle(
                  color: Color(0xFFB9C2E6),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF363B50),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dashed rounded-rect outline for ghost affordances like "add question".
class _DashedBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _DashedBox({
    required this.child,
    this.radius = 16,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: radius),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  static const _color = AppColors.inkFaint;
  static const _dashWidth = 5.0;
  static const _gap = 4.0;
  static const _strokeWidth = 1.4;

  const _DashedBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _strokeWidth / 2,
        _strokeWidth / 2,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(radius),
    );
    final metric = (Path()..addRRect(rrect)).computeMetrics().first;
    double distance = 0;
    while (distance < metric.length) {
      final next = distance + _dashWidth;
      canvas.drawPath(
        metric.extractPath(distance, next.clamp(0, metric.length)),
        paint,
      );
      distance = next + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
