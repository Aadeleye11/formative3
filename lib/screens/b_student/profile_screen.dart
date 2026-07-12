import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../a_auth/onboarding_screen.dart';
import '../a_auth/startup_verification_screen.dart';
import '../c_startup/startup_shell.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';
import 'passport_screen.dart';
import 'saved_screen.dart';
import 'skills_interests_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEditProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))
        .then((_) => setState(() {}));
  }

  void _openSkillsInterests() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SkillsInterestsScreen()))
        .then((_) => setState(() {}));
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  Future<void> _switchToStartupWorkspace() async {
    final existing = await MarketplaceRepository.instance.getMyStartupOnce();
    if (!mounted) return;

    if (existing == null) {
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set up your startup workspace'),
          content: const Text(
            "You haven't created a startup profile yet. Set one up to post "
            'roles and review applicants as a founder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Get started'),
            ),
          ],
        ),
      );
      if (shouldCreate == true && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StartupVerificationScreen()),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartupShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Opportunity>>(
      stream: MarketplaceRepository.instance.watchMySavedOpportunities(),
      builder: (context, savedSnap) {
        return StreamBuilder<List<Application>>(
          stream: MarketplaceRepository.instance.watchMyApplications(),
          builder: (context, appsSnap) {
            final applications = appsSnap.data ?? const <Application>[];
            return _build(
              context,
              savedCount: savedSnap.data?.length ?? 0,
              applicationsCount: applications.length,
              shortlistedCount: applications
                  .where((a) => a.status == ApplicationStatus.shortlisted)
                  .length,
              acceptedCount: applications
                  .where((a) => a.status == ApplicationStatus.accepted)
                  .length,
            );
          },
        );
      },
    );
  }

  Widget _build(
    BuildContext context, {
    required int savedCount,
    required int applicationsCount,
    required int shortlistedCount,
    required int acceptedCount,
  }) {
    final amina = Fixtures.amina;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openEditProfile,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InitialsAvatar(
                        initials: amina.initials,
                        photoBytes: amina.photoBytes,
                        size: 86,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Symbols.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  amina.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${amina.program} · ${amina.cohort}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Symbols.location_on_rounded,
                      size: 14,
                      color: AppColors.inkSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      amina.city,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
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
                  child: _StatColumn(
                    value: applicationsCount,
                    label: 'Applications',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _StatColumn(
                    value: shortlistedCount,
                    label: 'Shortlisted',
                  ),
                ),
                const _StatDivider(),
                Expanded(
                  child: _StatColumn(
                    value: acceptedCount,
                    label: 'Accepted',
                    valueColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PassportScreen())),
              child: GradientBorderCard(
                radius: 24,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Symbols.workspace_premium_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Experience Passport',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                      const Icon(
                        Symbols.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.person_rounded,
                label: 'My Profile',
                onTap: _openEditProfile,
              ),
              _MenuRow(
                icon: Symbols.psychology_rounded,
                label: 'Skills & Interests',
                onTap: _openSkillsInterests,
              ),
              _MenuRow(
                icon: Symbols.bookmark_rounded,
                label: 'Saved Opportunities',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$savedCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentDeepText,
                    ),
                  ),
                ),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SavedScreen())),
              ),
              _MenuRow(
                icon: Symbols.notifications_rounded,
                label: 'Notifications',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.rocket_launch_rounded,
                label: 'Switch to startup workspace',
                subtitle: "You're a founder at ALU too? Run both.",
                trailingIcon: Symbols.swap_horiz_rounded,
                onTap: _switchToStartupWorkspace,
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
                onTap: _logout,
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
  final Widget? trailing;
  final IconData? trailingIcon;
  final Color color;
  final VoidCallback onTap;

  const _MenuRow({
    this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
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
              if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
              if (trailingIcon != null)
                Icon(trailingIcon, size: 20, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
