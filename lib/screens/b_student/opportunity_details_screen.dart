import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../c_startup/startup_public_profile_screen.dart';
import 'apply_flow_screen.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  final Opportunity opportunity;
  const OpportunityDetailsScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  List<MatchReason> get _reasons {
    final mine = Fixtures.amina.skills.map((e) => e.toLowerCase()).toSet();
    final reasons = <MatchReason>[];
    for (final s in widget.opportunity.skills) {
      final matched = mine.contains(s.toLowerCase());
      reasons.add(
        MatchReason(
          matched ? '$s — endorsed in your Passport' : 'Missing: $s',
          matched,
        ),
      );
    }
    reasons.add(
      MatchReason(
        'Available ${Fixtures.amina.hoursPerWeek.round()} hrs/wk — role needs it',
        true,
      ),
    );
    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.opportunity;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleIconButton(
                          icon: Symbols.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        CircleIconButton(
                          icon: Symbols.ios_share_rounded,
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    '${o.title} at ${o.startup.name} — via ALULink',
                              ),
                            );
                            if (!context.mounted) return;
                            showAppToast(context, 'Copied to clipboard');
                          },
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: Symbols.bookmark_rounded,
                          color: o.saved ? AppColors.primary : AppColors.ink,
                          onTap: () {
                            setState(() => o.saved = !o.saved);
                            if (o.isLive) {
                              MarketplaceRepository.instance.toggleSaved(
                                o,
                                o.saved,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        LogoTile(startup: o.startup, size: 60, radius: 19),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    o.startup.name,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const VerifiedBadge(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: o.skills.map((s) => TagChip(label: s)).toList(),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShape.cardShadow,
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        childAspectRatio: 5.4,
                        children: [
                          _infoRow(Symbols.schedule_rounded, o.commitment),
                          _infoRow(Symbols.location_on_rounded, o.location),
                          _infoRow(Symbols.payments_rounded, o.compensation),
                          _infoRow(
                            Symbols.calendar_today_rounded,
                            o.postedLabel,
                          ),
                          _infoRow(
                            Symbols.group_rounded,
                            '${o.applicantsCount} applicants so far',
                          ),
                          _infoRow(Symbols.timer_rounded, o.closesLabel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GradientBorderCard(
                      radius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(
                                            Symbols.auto_awesome_rounded,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Why you match',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'SkillSync · your profile vs. this role',
                                        style: AppText.caption.copyWith(
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MatchRing(
                                  percent: o.matchPercent,
                                  size: 54,
                                  strokeWidth: 6,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._reasons.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      r.matched
                                          ? Symbols.check_circle_rounded
                                          : Symbols.cancel_rounded,
                                      size: 18,
                                      color: r.matched
                                          ? AppColors.success
                                          : AppColors.inkMuted,
                                      fill: 1,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        r.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: r.matched
                                              ? const Color(0xFF363B50)
                                              : AppColors.inkSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF1F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Symbols.school_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Close the gap — ALU Wednesday workshop',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Symbols.arrow_forward_rounded,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'About the role',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      o.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A4F64),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StartupPublicProfileScreen(startup: o.startup),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShape.cardShadow,
                          ),
                          child: Row(
                            children: [
                              LogoTile(startup: o.startup),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          o.startup.name,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const VerifiedBadge(pillStyle: false),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${o.startup.category} · ${o.startup.stage} · Team of ${o.startup.teamSize} · ${o.startup.city}',
                                      style: AppText.caption.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Symbols.chevron_right_rounded,
                                color: AppColors.inkFaint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() => o.saved = !o.saved);
                          if (o.isLive) {
                            MarketplaceRepository.instance.toggleSaved(
                              o,
                              o.saved,
                            );
                          }
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFEBE4D8),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Symbols.bookmark_rounded,
                            color: AppColors.primary,
                            fill: o.saved ? 1 : 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BrandButton(
                        label: 'Apply Now',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ApplyFlowScreen(opportunity: o),
                          ),
                        ),
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

  Widget _infoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
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
