import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../b_student/opportunity_details_screen.dart';
import 'postings_screen.dart';

class StartupPublicProfileScreen extends StatelessWidget {
  final StartupBrand startup;
  const StartupPublicProfileScreen({super.key, required this.startup});

  List<Opportunity> get _openRoles => Fixtures.opportunities
      .where((o) => o.startup.name == startup.name)
      .toList();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final roles = _openRoles;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(topPad: topPad, onBack: () => Navigator.of(context).pop()),
            Transform.translate(
              offset: const Offset(0, -34),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppShape.sideMargin,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: LogoTile(startup: startup, size: 76, radius: 22),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Tooltip(
                        message: 'Recognized ALU venture',
                        child: VerifiedBadge(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppShape.sideMargin,
                0,
                AppShape.sideMargin,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    startup.oneLiner,
                    style: AppText.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(label: 'Stage · ${startup.stage}'),
                      _StatChip(label: 'Founded ${startup.founded}'),
                      _StatChip(label: 'Team of ${startup.teamSize}'),
                      _StatChip(label: startup.city),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    startup.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1.55,
                      color: Color(0xFF4A4F64),
                    ),
                  ),
                  const SizedBox(height: AppShape.sectionGap),
                  if (roles.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Open roles (${roles.length})',
                            style: AppText.sectionHeader,
                          ),
                        ),
                        TextLinkButton(
                          label: 'See all',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PostingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        for (var i = 0; i < roles.length; i++) ...[
                          OpportunityListCard(
                            opportunity: roles[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OpportunityDetailsScreen(
                                  opportunity: roles[i],
                                ),
                              ),
                            ),
                          ),
                          if (i != roles.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppShape.sectionGap),
                  ],
                  Text('Founders', style: AppText.sectionHeader),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _FounderTile(
                          initials: 'KM',
                          name: 'Kwame Mensah',
                          program: 'BSc Entrepreneurship',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FounderTile(
                          initials: 'TD',
                          name: 'Thandi Dlamini',
                          program: 'BSc Software Eng',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppShape.sectionGap),
                  Text(
                    'Students who worked here',
                    style: AppText.sectionHeader,
                  ),
                  const SizedBox(height: 12),
                  const _AlumniRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final double topPad;
  final VoidCallback onBack;
  const _Cover({required this.topPad, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168 + topPad,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: topPad + 34,
            right: 28,
            child: Icon(
              Symbols.auto_awesome_rounded,
              size: 26,
              color: Colors.white.withValues(alpha: .28),
            ),
          ),
          Positioned(
            top: topPad + 82,
            right: 80,
            child: Icon(
              Symbols.auto_awesome_rounded,
              size: 15,
              color: Colors.white.withValues(alpha: .2),
            ),
          ),
          Positioned(
            left: AppShape.sideMargin,
            top: topPad + 12,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.pill),
        border: Border.all(color: AppColors.hairline, width: 1.2),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FounderTile extends StatelessWidget {
  final String initials;
  final String name;
  final String program;
  const _FounderTile({
    required this.initials,
    required this.name,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InitialsAvatar(initials: initials, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                program,
                style: AppText.caption.copyWith(fontSize: 10.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlumniRow extends StatelessWidget {
  const _AlumniRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          height: 36,
          width: 92,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: _StampedAvatar(
                  initials: 'AH',
                  gradient: AppColors.avatarGradient,
                ),
              ),
              Positioned(
                left: 28,
                child: _StampedAvatar(
                  initials: 'TD',
                  gradient: LinearGradient(
                    colors: [Color(0xFFF78FB8), Color(0xFFF7A88C)],
                  ),
                ),
              ),
              Positioned(
                left: 56,
                child: _StampedAvatar(
                  initials: 'CO',
                  gradient: LinearGradient(
                    colors: [Color(0xFF2ECC8F), Color(0xFF7FE3B9)],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
          ),
          child: const Text(
            '+5',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.inkSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'passport-verified alumni',
            style: AppText.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StampedAvatar extends StatelessWidget {
  final String initials;
  final Gradient gradient;
  const _StampedAvatar({required this.initials, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 2),
          ),
          child: InitialsAvatar(
            initials: initials,
            size: 36,
            gradient: gradient,
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 14,
            height: 14,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.verified_rounded,
              size: 10,
              color: AppColors.primary,
              fill: 1,
            ),
          ),
        ),
      ],
    );
  }
}
