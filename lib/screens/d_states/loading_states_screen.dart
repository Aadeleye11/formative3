import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class LoadingStatesScreen extends StatelessWidget {
  const LoadingStatesScreen({super.key});

  static const _navItems = [
    NavItemSpec(
      icon: Symbols.home_rounded,
      activeIcon: Symbols.home_rounded,
      label: 'Home',
    ),
    NavItemSpec(
      icon: Symbols.search_rounded,
      activeIcon: Symbols.search_rounded,
      label: 'Explore',
    ),
    NavItemSpec(
      icon: Symbols.work_rounded,
      activeIcon: Symbols.work_rounded,
      label: 'Applications',
    ),
    NavItemSpec(
      icon: Symbols.person_rounded,
      activeIcon: Symbols.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: CircleIconButton(
                icon: Symbols.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonBox(width: 160, height: 24, radius: 6),
                              SizedBox(height: 8),
                              SkeletonBox(width: 190, height: 14, radius: 6),
                            ],
                          ),
                        ),
                        const SkeletonBox(width: 40, height: 40, radius: 20),
                        const SizedBox(width: 8),
                        const SkeletonBox(width: 40, height: 40, radius: 20),
                        const SizedBox(width: 8),
                        const SkeletonBox(width: 40, height: 40, radius: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Row(
                        children: const [
                          Expanded(
                            child: SkeletonBox(
                              width: double.infinity,
                              height: 48,
                              radius: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          SkeletonBox(width: 48, height: 48, radius: 16),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: SkeletonBox(width: 160, height: 15, radius: 6),
                  ),
                  SizedBox(
                    height: 176,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 2,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => const SkeletonBox(
                        width: 296,
                        height: 176,
                        radius: AppShape.heroRadius,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: SkeletonBox(width: 160, height: 15, radius: 6),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (i) => const Column(
                          children: [
                            SkeletonBox(width: 54, height: 54, radius: 27),
                            SizedBox(height: 6),
                            SkeletonBox(width: 40, height: 11, radius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: SkeletonBox(width: 160, height: 15, radius: 6),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppShape.cardRadius,
                              ),
                              boxShadow: AppShape.cardShadow,
                            ),
                            child: Row(
                              children: [
                                const SkeletonBox(
                                  width: 44,
                                  height: 44,
                                  radius: 14,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      SkeletonBox(
                                        width: double.infinity,
                                        height: 14,
                                        radius: 6,
                                      ),
                                      SizedBox(height: 8),
                                      SkeletonBox(
                                        width: 120,
                                        height: 12,
                                        radius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const SkeletonBox(
                                  width: 52,
                                  height: 22,
                                  radius: 11,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNav(currentIndex: 0, onTap: (_) {}, items: _navItems),
          ],
        ),
      ),
    );
  }
}
