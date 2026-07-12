import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'role_selection_screen.dart';

class _Slide {
  final Color circleColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _Slide({
    required this.circleColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

const _slides = [
  _Slide(
    circleColor: AppColors.accentTint,
    icon: Symbols.school_rounded,
    iconColor: AppColors.primary,
    title: 'Find real experience,\nright on campus',
    subtitle:
        'Internships and gigs from verified student ventures: a five-minute walk from class.',
  ),
  _Slide(
    circleColor: AppColors.successTint,
    icon: Symbols.workspace_premium_rounded,
    iconColor: AppColors.primary,
    title: 'Build a verified\ntrack record',
    subtitle:
        'Every completed role becomes a founder-endorsed entry in your Experience Passport.',
  ),
  _Slide(
    circleColor: AppColors.catMarketing,
    icon: Symbols.rocket_launch_rounded,
    iconColor: AppColors.statusReview,
    title: 'Help a startup\ntake off',
    subtitle:
        'Your skills move ALU ventures forward. Match, contribute, and grow together.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    // A brief post-mount window resize on Windows desktop can make PageView
    // report a spurious page change; ignore drift until things settle.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _settled = true;
    });
  }

  void _goToRole() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, top: 8),
                child: TextButton(
                  onPressed: _goToRole,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  if (!_settled) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _controller.hasClients) {
                        _controller.jumpToPage(0);
                      }
                    });
                    return;
                  }
                  setState(() => _index = i);
                },
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(AppShape.pill),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isLast
                  ? GradientButton(label: 'Get started →', onPressed: _goToRole)
                  : PrimaryButton(
                      label: 'Next',
                      trailingIcon: Symbols.arrow_forward_rounded,
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 216,
                  height: 216,
                  decoration: BoxDecoration(
                    color: slide.circleColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: slide.iconColor.withValues(alpha: .2),
                        offset: const Offset(0, 16),
                        blurRadius: 34,
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, size: 44, color: slide.iconColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: AppColors.inkSecondary,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
