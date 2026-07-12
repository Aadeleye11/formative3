import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/skills.dart';
import '../../data/student_options.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class SkillsInterestsScreen extends StatefulWidget {
  const SkillsInterestsScreen({super.key});

  @override
  State<SkillsInterestsScreen> createState() => _SkillsInterestsScreenState();
}

class _SkillsInterestsScreenState extends State<SkillsInterestsScreen> {
  late final Set<String> selectedSkills = {...Fixtures.amina.skills};
  late final Set<String> selectedInterests = {...Fixtures.amina.interests};
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

  @override
  void dispose() {
    skillSearchController.dispose();
    super.dispose();
  }

  void _save() {
    Fixtures.amina = Fixtures.amina.copyWith(
      skills: selectedSkills.toList(),
      interests: selectedInterests.toList(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final skills = displayedSkills;
    final hasNoMatches =
        skillQuery.isNotEmpty &&
        skills.every((s) => selectedSkills.contains(s));

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
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Skills & Interests',
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your skills',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: skillSearchController,
                          hint: 'Search skills…',
                          icon: Symbols.search_rounded,
                          trailingIcon: skillQuery.isNotEmpty
                              ? Symbols.close_rounded
                              : null,
                          onTrailingTap: () {
                            skillSearchController.clear();
                            setState(() => skillQuery = '');
                          },
                          onChanged: (v) =>
                              setState(() => skillQuery = v.trim()),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${selectedSkills.length} selected',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
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
                        const SizedBox(height: 24),
                        const Text(
                          'Your interests',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kInterestOptions.map((s) {
                            final selected = selectedInterests.contains(s);
                            return SelectableChip.tint(
                              label: s,
                              selected: selected,
                              onTap: () => setState(
                                () => selected
                                    ? selectedInterests.remove(s)
                                    : selectedInterests.add(s),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Save changes',
                onPressed: selectedSkills.length >= 3 ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
