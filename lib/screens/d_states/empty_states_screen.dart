import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class EmptyStatesScreen extends StatelessWidget {
  const EmptyStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Empty states',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: EmptyStateView(
                        icon: Symbols.forum_rounded,
                        title: 'No messages yet',
                        subtitle:
                            'Conversations start when you apply — or when a startup reaches out about your profile.',
                        ctaLabel: 'Find a role to apply for',
                        onCta: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Also reused for:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SecondaryPreviewRow(
                      icon: Symbols.work_history_rounded,
                      caption: 'No applications yet (student) — friendly nudge',
                      linkLabel: 'Explore',
                    ),
                    const SizedBox(height: 10),
                    _SecondaryPreviewRow(
                      icon: Symbols.post_add_rounded,
                      caption: 'No postings yet (startup)',
                      linkLabel: 'Post your first role',
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

class _SecondaryPreviewRow extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String linkLabel;

  const _SecondaryPreviewRow({
    required this.icon,
    required this.caption,
    required this.linkLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        boxShadow: AppShape.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              caption,
              style: AppText.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          TextLinkButton(label: linkLabel, onPressed: () {}),
        ],
      ),
    );
  }
}
