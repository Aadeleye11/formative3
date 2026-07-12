import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:printing/printing.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/passport_pdf.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  Future<void> _sharePassport(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            "${Fixtures.amina.name}'s ALULink Experience Passport — "
            '${Fixtures.passportSummary}',
      ),
    );
    if (!context.mounted) return;
    showAppToast(context, 'Copied to clipboard');
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<PassportEntry> entries,
    Map<String, int> skillCounts,
  ) async {
    try {
      final bytes = await buildPassportPdf(
        student: Fixtures.amina,
        entries: entries,
        skillCounts: skillCounts,
      );
      final fileName =
          '${Fixtures.amina.name.replaceAll(' ', '_')}_ALULink_Passport.pdf';
      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes);
      }
    } catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          "Couldn't generate PDF. Please try again.",
          icon: Symbols.error_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = Fixtures.passport;
    final skillCounts = <String, int>{};
    for (final entry in entries) {
      for (final skill in entry.skills) {
        skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
      }
    }
    final sortedSkills = skillCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
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
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Experience Passport',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        CircleIconButton(
                          icon: Symbols.ios_share_rounded,
                          onTap: () => _sharePassport(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _IdentityCard(
                      rolesCount: entries.length,
                      skillsCount: skillCounts.length,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'WORK HISTORY',
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: EmptyStateView(
                          icon: Symbols.workspace_premium_rounded,
                          title: 'No verified experience yet',
                          subtitle:
                              'Once a founder verifies your work on a role, it shows up here.',
                        ),
                      )
                    else
                      for (var i = 0; i < entries.length; i++)
                        _PassportTimelineRow(
                          entry: entries[i],
                          isLast: i == entries.length - 1,
                        ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShape.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKILL ENDORSEMENTS',
                            style: AppText.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (sortedSkills.isEmpty)
                            Text(
                              'Endorsed skills from verified roles will show up here.',
                              style: AppText.caption.copyWith(fontSize: 12.5),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final s in sortedSkills)
                                  EndorsementChip(
                                    label: s.key,
                                    count: s.value,
                                    tint: CategoryTint.forCategory(s.key),
                                  ),
                              ],
                            ),
                        ],
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
                    Expanded(
                      child: GradientButton(
                        label: 'Share passport',
                        leadingIcon: Symbols.ios_share_rounded,
                        onPressed: () => _sharePassport(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _PdfButton(
                      onTap: () => _exportPdf(context, entries, skillCounts),
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

class _IdentityCard extends StatelessWidget {
  final int rolesCount;
  final int skillsCount;
  const _IdentityCard({required this.rolesCount, required this.skillsCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShape.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -38,
            right: -38,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: .28),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(initials: Fixtures.amina.initials, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Fixtures.amina.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Fixtures.amina.program} · ${Fixtures.amina.cohort}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .65),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniBadge(
                      icon: Symbols.verified_rounded,
                      label:
                          '$rolesCount VERIFIED ROLE${rolesCount == 1 ? '' : 'S'}',
                      bg: AppColors.accent.withValues(alpha: .3),
                      fg: Colors.white,
                    ),
                    _MiniBadge(
                      icon: Symbols.workspace_premium_rounded,
                      label:
                          '$skillsCount ENDORSED SKILL${skillsCount == 1 ? '' : 'S'}',
                      bg: AppColors.success.withValues(alpha: .22),
                      fg: const Color(0xFFCFE9BC),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg, fill: 1),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportTimelineRow extends StatelessWidget {
  final PassportEntry entry;
  final bool isLast;
  const _PassportTimelineRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.check_rounded,
                  size: 15,
                  color: Colors.white,
                  weight: 700,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _PassportCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportCard extends StatelessWidget {
  final PassportEntry entry;
  const _PassportCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShape.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoTile(startup: entry.startup, size: 38, radius: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.role,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const VerifiedBadge(pillStyle: false),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.startup.name} · ${entry.dates}',
                      style: AppText.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.accentTint, width: 2.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.quote,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4A4F64),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '— ${entry.author}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.skills.map((s) => CheckChip(label: s)).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.verified_rounded,
                  size: 14,
                  color: AppColors.inkMuted,
                  fill: 1,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.verifiedOn,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PdfButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppShape.buttonHeight,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppShape.pill),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShape.pill),
              border: Border.all(color: AppColors.hairline, width: 1.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.picture_as_pdf_rounded,
                  size: 18,
                  color: AppColors.ink,
                ),
                SizedBox(width: 8),
                Text(
                  'PDF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
