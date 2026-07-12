import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'opportunity_details_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Opportunity> _liveSaved = [];
  StreamSubscription<List<Opportunity>>? _liveSub;

  @override
  void initState() {
    super.initState();
    _liveSub = MarketplaceRepository.instance
        .watchMySavedOpportunities()
        .listen((items) {
          if (mounted) setState(() => _liveSaved = items);
        });
  }

  @override
  void dispose() {
    _liveSub?.cancel();
    super.dispose();
  }

  void _toggleSaved(Opportunity o) {
    setState(() => o.saved = !o.saved);
    if (o.isLive) {
      MarketplaceRepository.instance.toggleSaved(o, o.saved);
    }
  }

  List<Opportunity> get _saved => [
    ..._liveSaved,
    ...Fixtures.opportunities.where((o) => o.saved),
  ];

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                '${saved.length} saved · swipe left to remove',
                style: AppText.caption.copyWith(fontSize: 12.5),
              ),
            ),
            Expanded(
              child: saved.isEmpty
                  ? Center(
                      child: EmptyStateView(
                        icon: Symbols.bookmark_rounded,
                        title: 'Nothing saved yet',
                        subtitle:
                            'Tap the bookmark on any role to keep it here for later.',
                        ctaLabel: 'Explore opportunities',
                        onCta: () => Navigator.of(context).pop(),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: saved.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final o = saved[i];
                        return Dismissible(
                          key: ValueKey(o.id),
                          direction: DismissDirection.endToStart,
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
                                  'Remove',
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
                          onDismissed: (_) => _toggleSaved(o),
                          child: OpportunityListCard(
                            opportunity: o,
                            onTap: () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => OpportunityDetailsScreen(
                                      opportunity: o,
                                    ),
                                  ),
                                )
                                .then((_) => setState(() {})),
                            onBookmarkTap: () => _toggleSaved(o),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
