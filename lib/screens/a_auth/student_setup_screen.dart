import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/skills.dart';
import '../../data/student_options.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../b_student/student_shell.dart';

class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  int step = 0;
  late final nameController = TextEditingController(
    text: AuthService.instance.currentUser?.displayName ?? '',
  );
  late final cohortController = TextEditingController(
    text: Fixtures.amina.cohort,
  );
  String? photoUrl = AuthService.instance.currentUser?.photoURL;
  Uint8List? pickedPhotoBytes;
  bool pickingPhoto = false;
  (String, String) selectedProgram = kPrograms.first;
  final Set<String> selectedSkills = {
    'Flutter',
    'Figma',
    'Copywriting',
    'Firebase',
  };
  double hours = 10;
  int workStyle = 2; // Remote/On-campus/Hybrid
  final Set<String> interests = {'Design', 'Engineering', 'Data'};
  final skillSearchController = TextEditingController();
  String skillQuery = '';

  List<String> get displayedSkills {
    final pool = skillQuery.isEmpty
        ? kPopularSkills
        : kAllSkills.where(
            (s) => s.toLowerCase().contains(skillQuery.toLowerCase()),
          );
    return [
      ...selectedSkills,
      ...pool.where((s) => !selectedSkills.contains(s)),
    ];
  }

  Future<void> _pickPhoto() async {
    setState(() => pickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => pickedPhotoBytes = bytes);
    } finally {
      if (mounted) setState(() => pickingPhoto = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cohortController.dispose();
    skillSearchController.dispose();
    super.dispose();
  }

  void _next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      final enteredName = nameController.text.trim();
      final enteredCohort = cohortController.text.trim();
      Fixtures.amina = Fixtures.amina.copyWith(
        name: enteredName.isEmpty ? null : enteredName,
        initials: enteredName.isEmpty
            ? null
            : initialsFromName(enteredName, fallback: Fixtures.amina.initials),
        program: '${selectedProgram.$2} ${selectedProgram.$1}',
        cohort: enteredCohort.isEmpty ? null : enteredCohort,
        skills: selectedSkills.toList(),
        hoursPerWeek: hours,
        workStyle: const ['Remote', 'On-campus', 'Hybrid'][workStyle],
        interests: interests.toList(),
        photoBytes: pickedPhotoBytes,
        hasCompletedSetup: true,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = step != 1 || selectedSkills.length >= 3;
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
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => step == 0
                        ? Navigator.of(context).pop()
                        : setState(() => step--),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Set up your profile',
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
                'Step ${step + 1} of 3 · ${['The basics', 'Your skills', 'Availability & interests'][step]}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: switch (step) {
                      0 => _basicsStep(),
                      1 => _skillsStep(),
                      _ => _availabilityStep(),
                    },
                  ),
                ),
              ),
              step == 2
                  ? BrandButton(
                      label: 'Build my matches',
                      onPressed: canContinue ? _next : null,
                      trailingIcon: Symbols.auto_awesome_rounded,
                    )
                  : PrimaryButton(
                      label: 'Continue',
                      trailingIcon: Symbols.arrow_forward_rounded,
                      onPressed: canContinue ? _next : null,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _basicsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: pickingPhoto ? null : _pickPhoto,
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFE4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC3C9E0),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (pickedPhotoBytes != null)
                        Image.memory(pickedPhotoBytes!, fit: BoxFit.cover)
                      else if (photoUrl != null)
                        Image.network(photoUrl!, fit: BoxFit.cover)
                      else
                        const Center(
                          child: Icon(
                            Symbols.photo_camera_rounded,
                            size: 34,
                            color: AppColors.primary,
                          ),
                        ),
                      if (pickingPhoto)
                        Container(
                          color: Colors.black.withValues(alpha: .35),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Symbols.add_rounded,
                            size: 16,
                            color: Colors.white,
                            weight: 600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pickedPhotoBytes != null || photoUrl != null
                      ? 'Change photo'
                      : 'Add photo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Full name',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: nameController,
          hint: 'Enter your full name',
          icon: Symbols.person_rounded,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 16),
        const Text(
          'Program',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ProgramDropdown(
          value: selectedProgram,
          options: kPrograms,
          onChanged: (p) => setState(() => selectedProgram = p),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cohort',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: cohortController,
          hint: "Class of '27",
          icon: Symbols.calendar_today_rounded,
        ),
      ],
    );
  }

  Widget _skillsStep() {
    final skills = displayedSkills;
    final hasNoMatches =
        skillQuery.isNotEmpty &&
        skills.every((s) => selectedSkills.contains(s));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: skillSearchController,
          hint: 'Search skills…',
          icon: Symbols.search_rounded,
          trailingIcon: skillQuery.isNotEmpty ? Symbols.close_rounded : null,
          onTrailingTap: () {
            skillSearchController.clear();
            setState(() => skillQuery = '');
          },
          onChanged: (v) => setState(() => skillQuery = v.trim()),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pick at least 3',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSecondary,
              ),
            ),
            Text(
              '${selectedSkills.length} selected',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasNoMatches)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No skills match "$skillQuery". Try a different search.',
              style: AppText.caption.copyWith(fontSize: 12.5),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              final selected = selectedSkills.contains(s);
              return SelectableChip(
                label: s,
                selected: selected,
                onTap: () => setState(
                  () => selected
                      ? selectedSkills.remove(s)
                      : selectedSkills.add(s),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _availabilityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hours per week',
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
                  children: const [
                    Text(
                      '2 hrs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    Text(
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
          'Work style',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        AppSegmentedControl(
          labels: const ['Remote', 'On-campus', 'Hybrid'],
          index: workStyle,
          onChanged: (i) => setState(() => workStyle = i),
        ),
        const SizedBox(height: 20),
        const Text(
          'Interests',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kInterestOptions.map((s) {
            final selected = interests.contains(s);
            return SelectableChip.tint(
              label: s,
              selected: selected,
              onTap: () => setState(
                () => selected ? interests.remove(s) : interests.add(s),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
