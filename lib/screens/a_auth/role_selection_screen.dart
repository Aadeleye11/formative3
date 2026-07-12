import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'sign_in_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AppRole role = AppRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How will you\nuse ALULink?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pick a role to tailor your experience. You can switch workspaces anytime.',
                style: AppText.body.copyWith(color: AppColors.inkSecondary),
              ),
              const SizedBox(height: 30),
              _RoleCard(
                title: "I'm a student looking for experience",
                subtitle:
                    'Match with verified ALU startups and build your Experience Passport.',
                selected: role == AppRole.student,
                onTap: () => setState(() => role = AppRole.student),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'I run a startup and need talent',
                subtitle:
                    'Post roles, review matched applicants, and hire from campus.',
                selected: role == AppRole.startup,
                onTap: () => setState(() => role = AppRole.startup),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue',
                trailingIcon: Symbols.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SignInScreen(role: role)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFF4EDE1),
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .14),
                    offset: const Offset(0, 12),
                    blurRadius: 28,
                  ),
                ]
              : AppShape.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFFE9E2D6), width: 2),
              ),
              child: selected
                  ? const Icon(
                      Symbols.check_rounded,
                      size: 30,
                      color: Colors.white,
                      weight: 700,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(
                        fontSize: 12.5,
                        height: 1.5,
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
