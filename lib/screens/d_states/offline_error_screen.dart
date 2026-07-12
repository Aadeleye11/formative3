import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class OfflineErrorScreen extends StatelessWidget {
  const OfflineErrorScreen({super.key});

  List<Opportunity> get _savedOffline {
    final saved = Fixtures.opportunities.where((o) => o.saved).take(2).toList();
    if (saved.length >= 2) return saved;
    return Fixtures.opportunities.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final saved = _savedOffline;
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
                    'Offline',
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => showAppToast(
                        context,
                        'Retrying…',
                        icon: Symbols.sync_rounded,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.cloud_off_rounded,
                              size: 18,
                              color: AppColors.statusReview,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "You're offline — showing saved opportunities",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Retry',
                              style: TextStyle(
                                color: Color(0xFFB9C2E6),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: EmptyStateView(
                        icon: Symbols.wifi_off_rounded,
                        title: 'Connection lost',
                        subtitle:
                            "Your saved roles are still here. New matches and messages will sync when you're back online.",
                        circleColor: AppColors.catMarketing,
                        iconColor: AppColors.statusReview,
                        ctaLabel: 'Retry',
                        onCta: () => showAppToast(
                          context,
                          'Retrying…',
                          icon: Symbols.sync_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'SAVED · AVAILABLE OFFLINE',
                      style: AppText.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < saved.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == saved.length - 1 ? 0 : 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OpportunityListCard(opportunity: saved[i]),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, left: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Symbols.offline_bolt_rounded,
                                    size: 12,
                                    color: AppColors.inkMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cached ${i == 0 ? 1 : 3}h ago',
                                    style: AppText.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
