import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'analytics_screen.dart';
import 'post_role_screen.dart';

class PostingsScreen extends StatelessWidget {
  const PostingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Opportunity>>(
      stream: MarketplaceRepository.instance.watchMyPostings(),
      builder: (context, snapshot) {
        final postings = snapshot.data ?? const <Opportunity>[];
        return _build(context, postings);
      },
    );
  }

  Widget _build(BuildContext context, List<Opportunity> postings) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Postings',
                  style: AppText.screenTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  width: 118,
                  child: BrandButton(
                    label: '+ New',
                    height: 40,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PostRoleScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: postings.isEmpty
                ? Center(
                    child: EmptyStateView(
                      icon: Symbols.description_rounded,
                      title: 'No postings yet',
                      subtitle:
                          'Post your first role to start meeting ALU talent.',
                      ctaLabel: 'Post a role',
                      onCta: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PostRoleScreen(),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: postings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final o = postings[i];
                      final card = _PostingCard(
                        opportunity: o,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        ),
                      );
                      if (!o.isLive) return card;
                      return Dismissible(
                        key: ValueKey(o.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context, o),
                        onDismissed: (_) => MarketplaceRepository.instance
                            .deleteOpportunity(o.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(
                              AppShape.cardRadius,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Symbols.delete_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        child: card,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Opportunity o) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this posting?'),
        content: Text(
          '"${o.title}" will be removed permanently, along with its place in '
          "applicants' history. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

class _PostingCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;

  const _PostingCard({required this.opportunity, this.onTap});

  @override
  Widget build(BuildContext context) {
    final live = !opportunity.closesLabel.contains('Closed');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            boxShadow: AppShape.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Symbols.chevron_right_rounded,
                    size: 20,
                    color: AppColors.inkFaint,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: live ? AppColors.success : AppColors.inkMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    live ? 'Live' : 'Closed',
                    style: AppText.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: live ? AppColors.successDeep : AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Symbols.group_rounded,
                    size: 14,
                    color: AppColors.inkSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${opportunity.applicantsCount} applicants',
                    style: AppText.caption.copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    opportunity.postedLabel,
                    style: AppText.caption.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
