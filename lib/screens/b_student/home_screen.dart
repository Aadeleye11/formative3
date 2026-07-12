import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'messages_list_screen.dart';
import 'notifications_screen.dart';
import 'opportunity_details_screen.dart';
import 'saved_screen.dart';

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;
  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    (
      label: 'Design',
      icon: Symbols.palette_rounded,
      tint: AppColors.catDesign,
      text: AppColors.catDesignText,
    ),
    (
      label: 'Engineering',
      icon: Symbols.code_rounded,
      tint: AppColors.catEngineering,
      text: AppColors.catEngineeringText,
    ),
    (
      label: 'Marketing',
      icon: Symbols.campaign_rounded,
      tint: AppColors.catMarketing,
      text: AppColors.catMarketingText,
    ),
    (
      label: 'Data',
      icon: Symbols.bar_chart_rounded,
      tint: AppColors.catData,
      text: AppColors.catDataText,
    ),
    (
      label: 'Content',
      icon: Symbols.edit_note_rounded,
      tint: AppColors.catDesign,
      text: AppColors.catDesignText,
    ),
    (
      label: 'Research',
      icon: Symbols.science_rounded,
      tint: AppColors.catResearch,
      text: AppColors.catResearchText,
    ),
  ];

  void _openOpportunity(Opportunity o) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailsScreen(opportunity: o),
      ),
    );
  }

  void _toggleSaved(Opportunity o) {
    setState(() => o.saved = !o.saved);
    if (o.isLive) {
      MarketplaceRepository.instance.toggleSaved(o, o.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Opportunity>>(
      stream: MarketplaceRepository.instance.watchLiveOpportunities(),
      builder: (context, snapshot) {
        final live = snapshot.data ?? const <Opportunity>[];
        final opportunities = [...live, ...Fixtures.opportunities];
        return _build(context, opportunities);
      },
    );
  }

  Widget _build(BuildContext context, List<Opportunity> opportunities) {
    final amina = Fixtures.amina;
    final savedCount = opportunities.where((o) => o.saved).length;
    final firstName = amina.name.split(' ').first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeGreeting(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.7,
                            height: 1.05,
                            color: AppColors.ink,
                          ),
                          children: [
                            TextSpan(text: firstName),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Find meaningful ways to contribute.',
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Symbols.notifications_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  badge: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Symbols.chat_bubble_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MessagesListScreen(),
                    ),
                  ),
                  badge: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => widget.onNavigateToTab(3),
                  child: InitialsAvatar(
                    initials: amina.initials,
                    photoBytes: amina.photoBytes,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Search roles, startups, skills…',
                    onTap: () => widget.onNavigateToTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => widget.onNavigateToTab(1),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShape.ctaShadow(AppColors.primary),
                    ),
                    child: const Icon(
                      Symbols.tune_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Symbols.send_rounded,
                    value: '${Fixtures.applications.length}',
                    label: 'Applications',
                    tint: AppColors.accentTint,
                    text: AppColors.accentDeepText,
                    onTap: () => widget.onNavigateToTab(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Symbols.star_rounded,
                    value: '${Fixtures.shortlistedCount}',
                    label: 'Shortlisted',
                    tint: AppColors.statusReviewTint,
                    text: AppColors.statusReviewText,
                    onTap: () => widget.onNavigateToTab(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Symbols.bookmark_rounded,
                    value: '$savedCount',
                    label: 'Saved',
                    tint: AppColors.catResearch,
                    text: AppColors.catResearchText,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SavedScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (opportunities.isEmpty) ...[
            _SectionHeader(
              title: 'Recommended for you',
              onSeeAll: () => widget.onNavigateToTab(1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShape.cardShadow,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Symbols.search_off_rounded,
                      size: 32,
                      color: AppColors.inkFaint,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No opportunities posted yet',
                      style: AppText.caption.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Once a startup posts a role, it shows up here.',
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _SectionHeader(
              title: 'Recommended for you',
              onSeeAll: () => widget.onNavigateToTab(1),
            ),
            SizedBox(
              height: 264,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: opportunities.length.clamp(0, 4),
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final o = opportunities[i];
                  final brand = o.startup.gradient;
                  final shadowColor = brand is LinearGradient
                      ? brand.colors.first
                      : AppColors.accent;
                  return OpportunityHeroCard(
                    opportunity: o,
                    gradient: brand,
                    shadowColor: shadowColor,
                    onTap: () => _openOpportunity(o),
                    onBookmarkTap: () => _toggleSaved(o),
                  );
                },
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(
              'Browse by category',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final c = _categories[i];
                return GestureDetector(
                  onTap: () => widget.onNavigateToTab(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.tint,
                      borderRadius: BorderRadius.circular(AppShape.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 16, color: c.text),
                        const SizedBox(width: 7),
                        Text(
                          c.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (opportunities.isNotEmpty) ...[
            _SectionHeader(
              title: 'Recent opportunities',
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              onSeeAll: () => widget.onNavigateToTab(1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: opportunities
                    .take(3)
                    .map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OpportunityListCard(
                          opportunity: o,
                          onTap: () => _openOpportunity(o),
                          onBookmarkTap: () => _toggleSaved(o),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final EdgeInsets padding;

  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextLinkButton(label: 'See all', onPressed: onSeeAll),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color tint;
  final Color text;
  final VoidCallback onTap;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: text),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
