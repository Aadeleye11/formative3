import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<int> _readIndices = {};

  bool _isUnread(List<NotificationItem> items, int i) =>
      items[i].unread && !_readIndices.contains(i);

  void _markAllRead(int count) {
    setState(() => _readIndices.addAll(List.generate(count, (i) => i)));
  }

  ({IconData icon, Color tint, Color iconColor, Color accent, bool filled})
  _kindConfig(NotifKind kind) {
    return switch (kind) {
      NotifKind.celebration => (
        icon: Symbols.celebration_rounded,
        tint: AppColors.successTint,
        iconColor: AppColors.success,
        accent: AppColors.success,
        filled: true,
      ),
      NotifKind.match => (
        icon: Symbols.auto_awesome_rounded,
        tint: AppColors.accentTint,
        iconColor: AppColors.primary,
        accent: AppColors.primary,
        filled: true,
      ),
      NotifKind.interview => (
        icon: Symbols.event_rounded,
        tint: AppColors.accentTint,
        iconColor: AppColors.primary,
        accent: AppColors.primary,
        filled: true,
      ),
      NotifKind.message => (
        icon: Symbols.chat_bubble_rounded,
        tint: AppColors.statusClosedTint,
        iconColor: AppColors.inkSecondary,
        accent: AppColors.hairline,
        filled: false,
      ),
      NotifKind.status => (
        icon: Symbols.swap_horiz_rounded,
        tint: AppColors.statusClosedTint,
        iconColor: AppColors.inkSecondary,
        accent: AppColors.hairline,
        filled: false,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationItem>>(
      stream: MarketplaceRepository.instance.watchMyNotifications(),
      builder: (context, snapshot) {
        final items = [
          ...snapshot.data ?? const <NotificationItem>[],
          ...Fixtures.notifications,
        ];
        return _build(context, items);
      },
    );
  }

  Widget _build(BuildContext context, List<NotificationItem> items) {
    final todayCount = items.length >= 3 ? 3 : items.length;
    final today = List.generate(todayCount, (i) => i);
    final earlier = List.generate(
      items.length - todayCount,
      (i) => todayCount + i,
    );

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
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _markAllRead(items.length),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: EmptyStateView(
                        icon: Symbols.notifications_rounded,
                        title: 'No notifications yet',
                        subtitle:
                            "You'll see updates here when something changes on one of your applications or postings.",
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      children: [
                        if (today.isNotEmpty) ...[
                          _sectionHeader('TODAY'),
                          const SizedBox(height: 10),
                          ...today.map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _notifRow(items, i),
                            ),
                          ),
                        ],
                        if (earlier.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _sectionHeader('EARLIER'),
                          const SizedBox(height: 10),
                          ...earlier.map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _notifRow(items, i),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: AppText.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _notifRow(List<NotificationItem> items, int index) {
    final item = items[index];
    final unread = _isUnread(items, index);
    final cfg = _kindConfig(item.kind);

    return GestureDetector(
      onTap: () => setState(() => _readIndices.add(index)),
      child: Opacity(
        opacity: unread ? 1 : 0.72,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShape.cardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: cfg.accent),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: cfg.tint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cfg.icon,
                                size: 19,
                                color: cfg.iconColor,
                                fill: cfg.filled ? 1 : 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.subtitle,
                                      style: AppText.caption.copyWith(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inkFaint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unread)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
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
