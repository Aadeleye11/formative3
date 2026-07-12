import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

/// A living reference for every shared widget in the design system.
class ComponentSheetScreen extends StatefulWidget {
  const ComponentSheetScreen({super.key});

  @override
  State<ComponentSheetScreen> createState() => _ComponentSheetScreenState();
}

class _ComponentSheetScreenState extends State<ComponentSheetScreen> {
  int segIndex = 0;
  bool skillSelected = true;

  // Inline sample data just for card previews — real fixture lists are empty.
  static final _sampleOpportunity = Opportunity(
    id: 'sample',
    title: 'Flutter Developer Intern',
    startup: Fixtures.learnify,
    category: 'Engineering',
    skills: const ['Flutter', 'Firebase', 'UI Testing'],
    commitment: 'Part-time · 8–10 hrs/wk',
    location: 'On-campus · Kigali',
    compensation: 'Stipend',
    postedLabel: 'Posted 3 days ago',
    closesLabel: 'Closes in 12 days',
    applicantsCount: 4,
    matchPercent: 92,
    description: 'Sample opportunity for the component library.',
  );

  static final _sampleApplicant = Applicant(
    name: 'Sample Applicant',
    initials: 'SA',
    avatarGradient: AppColors.avatarGradient,
    program: 'BSc Software Engineering',
    cohort: "Class of '27",
    city: 'Kigali',
    skills: const ['Flutter', 'Firebase'],
    matchPercent: 92,
    appliedLabel: '2h ago',
    motivation: 'Sample applicant for the component library.',
    screening: const {'Weekly hours': '8–10 hrs'},
    skillsFit: 0.95,
    availabilityFit: 1.0,
    interestsFit: 0.8,
    stage: PipelineStage.newApplicant,
  );

  @override
  Widget build(BuildContext context) {
    final opp = _sampleOpportunity;
    final applicant = _sampleApplicant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component sheet'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section('Buttons', [
            PrimaryButton(label: 'Periwinkle primary', onPressed: () {}),
            const SizedBox(height: 10),
            BrandButton(label: 'Apply Now / Post role', onPressed: () {}),
            const SizedBox(height: 10),
            GradientButton(label: 'Gradient CTA', onPressed: () {}),
            const SizedBox(height: 10),
            OutlineAppButton(label: 'Outline secondary', onPressed: () {}),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextLinkButton(label: 'Text button', onPressed: () {}),
                TextLinkButton(
                  label: 'Destructive',
                  onPressed: () {},
                  color: AppColors.danger,
                ),
                const Text(
                  'Disabled',
                  style: TextStyle(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ]),
          _Section('Chips', [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                const TagChip(label: 'Design'),
                const TagChip(label: 'Engineering'),
                const TagChip(label: 'Data'),
                const TagChip(label: 'Marketing'),
                const TagChip(label: 'Research'),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                SelectableChip(
                  label: 'Filter · on',
                  selected: true,
                  onTap: () {},
                ),
                SelectableChip(
                  label: 'Filter · off',
                  selected: false,
                  onTap: () {},
                ),
                SelectableChip(
                  label: 'Skill',
                  selected: skillSelected,
                  onTap: () => setState(() => skillSelected = !skillSelected),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const EndorsementChip(label: 'Flutter', count: 3),
          ]),
          _Section('Status badges — color + label, never color alone', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values
                  .map((s) => StatusBadge(status: s))
                  .toList(),
            ),
          ]),
          _Section('Match ring · S + M', [
            Row(
              children: [
                const MatchRing(percent: 92, size: 46),
                const SizedBox(width: 18),
                const MatchRing(
                  percent: 87,
                  size: 72,
                  strokeWidth: 7,
                  fontSize: 16,
                ),
                const SizedBox(width: 18),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const MatchRing.onGradient(percent: 92, size: 46),
                ),
              ],
            ),
          ]),
          _Section('Inputs · segmented · toast', [
            const AppTextField(
              hint: 'Search field',
              icon: Symbols.search_rounded,
            ),
            const SizedBox(height: 10),
            const AppTextField(
              hint: 'Input · error state',
              icon: Symbols.mail_rounded,
              hasError: true,
              errorText: 'Email domain not recognized as ALU',
            ),
            const SizedBox(height: 10),
            AppSegmentedControl(
              labels: const ['Active', 'Tab', 'Tab'],
              index: segIndex,
              onChanged: (i) => setState(() => segIndex = i),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => showAppToast(
                context,
                'Your role is live 🎉',
                actionLabel: 'View',
              ),
              child: const Text('Show toast'),
            ),
          ]),
          _Section('Opportunity card · list + hero', [
            OpportunityListCard(opportunity: opp),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: OpportunityHeroCard(opportunity: opp),
            ),
          ]),
          _Section('Applicant card', [ApplicantMiniCard(applicant: applicant)]),
          _Section('Timeline nodes · skeleton · empty style', [
            const TimelineRow(
              state: TimelineNodeState.done,
              title: 'Done',
              subtitle: 'Completed step',
            ),
            const TimelineRow(
              state: TimelineNodeState.current,
              title: 'Current',
              subtitle: 'In progress',
            ),
            const TimelineRow(
              state: TimelineNodeState.next,
              title: 'Next',
              subtitle: 'Upcoming',
              isLast: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                SkeletonBox(width: 44, height: 44, radius: 14),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 100, height: 9),
                    ],
                  ),
                ),
              ],
            ),
          ]),
          _Section('Logo tiles · 44×44 r14', [
            Wrap(
              spacing: 8,
              children: [
                LogoTile(startup: Fixtures.learnify),
                LogoTile(startup: Fixtures.eduBridge),
                LogoTile(startup: Fixtures.greenLoop),
                LogoTile(startup: Fixtures.sokoFresh),
                LogoTile(startup: Fixtures.ileZao),
                LogoTile(startup: Fixtures.koraHealth),
              ],
            ),
          ]),
          _Section('Bottom nav · student + startup', [
            SizedBox(
              height: 76,
              child: AppBottomNav(
                currentIndex: 0,
                onTap: (_) {},
                items: const [
                  NavItemSpec(
                    icon: Symbols.home_rounded,
                    activeIcon: Symbols.home_rounded,
                    label: 'Home',
                  ),
                  NavItemSpec(
                    icon: Symbols.search_rounded,
                    activeIcon: Symbols.search_rounded,
                    label: 'Explore',
                  ),
                  NavItemSpec(
                    icon: Symbols.work_rounded,
                    activeIcon: Symbols.work_rounded,
                    label: 'Applications',
                  ),
                  NavItemSpec(
                    icon: Symbols.person_rounded,
                    activeIcon: Symbols.person_rounded,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ]),
          _Section('Verified badge + type scale', [
            const VerifiedBadge(),
            const SizedBox(height: 12),
            Text('Greeting 28/700', style: AppText.greeting),
            Text('Screen title 20/700', style: AppText.screenTitle),
            Text('Card title 17/600', style: AppText.cardTitle),
            Text('Section header 15/700', style: AppText.sectionHeader),
            Text(
              'Body 14/400 · secondary #6B7086',
              style: AppText.bodySecondary,
            ),
            Text('Caption 12/500', style: AppText.caption),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.inkSecondary,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
