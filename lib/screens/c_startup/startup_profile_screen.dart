import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../a_auth/onboarding_screen.dart';
import '../a_auth/student_setup_screen.dart';
import '../b_student/help_support_screen.dart';
import '../b_student/student_shell.dart';
import 'analytics_screen.dart';
import 'no_startup_prompt.dart';
import 'postings_screen.dart';
import 'startup_public_profile_screen.dart';

class StartupProfileScreen extends StatelessWidget {
  const StartupProfileScreen({super.key});

  Future<void> _switchToStudentWorkspace(BuildContext context) async {
    final target = Fixtures.amina.hasCompletedSetup
        ? const StudentShell()
        : const StudentSetupScreen();
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => target), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StartupBrand?>(
      stream: MarketplaceRepository.instance.watchMyStartup(),
      builder: (context, startupSnap) {
        if (startupSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final startup = startupSnap.data;
        if (startup == null) {
          return const NoStartupPrompt();
        }
        return StreamBuilder<List<Opportunity>>(
          stream: MarketplaceRepository.instance.watchMyPostings(),
          builder: (context, postingsSnap) {
            return StreamBuilder<List<Applicant>>(
              stream: MarketplaceRepository.instance
                  .watchApplicantsForMyPostings(),
              builder: (context, applicantsSnap) {
                final activeRoles =
                    (postingsSnap.data ?? const <Opportunity>[]).length;
                final applicants = applicantsSnap.data ?? const <Applicant>[];
                final totalApplicants = applicants.length;
                final shortlisted = applicants
                    .where((a) => a.stage == PipelineStage.offer)
                    .length;
                return _build(
                  context,
                  startup,
                  activeRoles,
                  totalApplicants,
                  shortlisted,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _build(
    BuildContext context,
    StartupBrand startup,
    int activeRoles,
    int totalApplicants,
    int shortlisted,
  ) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                LogoTile(startup: startup, size: 76, radius: 22),
                const SizedBox(height: 12),
                Text(
                  startup.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  startup.oneLiner,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const VerifiedBadge(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShape.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatColumn(value: activeRoles, label: 'Active Roles'),
                ),
                const _StatDivider(),
                Expanded(
                  child: _StatColumn(
                    value: totalApplicants,
                    label: 'Applicants',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _StatColumn(
                    value: shortlisted,
                    label: 'Shortlisted',
                    valueColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.storefront_rounded,
                label: 'View public profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        StartupPublicProfileScreen(startup: startup),
                  ),
                ),
              ),
              _MenuRow(
                icon: Symbols.bar_chart_rounded,
                label: 'Analytics',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                ),
              ),
              _MenuRow(
                icon: Symbols.groups_rounded,
                label: 'Team & Roles',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PostingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.school_rounded,
                label: 'Switch to student workspace',
                subtitle: 'Browse and apply to roles as a student.',
                trailingIcon: Symbols.swap_horiz_rounded,
                onTap: () => _switchToStudentWorkspace(context),
              ),
              _MenuRow(
                icon: Symbols.help_rounded,
                label: 'Help & Support',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),
              _MenuRow(
                icon: Symbols.logout_rounded,
                label: 'Logout',
                color: AppColors.danger,
                trailingIcon: null,
                onTap: () async {
                  await AuthService.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;
  final Color valueColor;
  const _StatColumn({
    required this.value,
    required this.label,
    this.valueColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.hairline);
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final IconData? trailingIcon;
  final Color color;
  final VoidCallback onTap;

  const _MenuRow({
    this.icon,
    required this.label,
    this.subtitle,
    this.trailingIcon = Symbols.chevron_right_rounded,
    this.color = AppColors.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 20, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
