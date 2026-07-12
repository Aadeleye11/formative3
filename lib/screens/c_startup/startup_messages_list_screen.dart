import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'startup_chat_thread_screen.dart';

/// Founder-side inbox — conversations with applicants.
class StartupMessagesListScreen extends StatefulWidget {
  const StartupMessagesListScreen({super.key});

  @override
  State<StartupMessagesListScreen> createState() =>
      _StartupMessagesListScreenState();
}

class _StartupMessagesListScreenState
    extends State<StartupMessagesListScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatSummary>>(
      stream: MarketplaceRepository.instance.watchMyChatsAsStartup(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <ChatSummary>[];
        final threads = all.where((t) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          return t.peerName.toLowerCase().contains(q) ||
              t.lastMessage.toLowerCase().contains(q);
        }).toList();
        final loading =
            snapshot.connectionState == ConnectionState.waiting &&
            all.isEmpty;
        return _build(context, threads, loading);
      },
    );
  }

  Widget _build(BuildContext context, List<ChatSummary> threads, bool loading) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _searching
                  ? Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _searchController,
                            hint: 'Search conversations…',
                            icon: Symbols.search_rounded,
                            onChanged: (v) => setState(() => _query = v.trim()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
                          icon: Symbols.close_rounded,
                          onTap: _toggleSearch,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleIconButton(
                          icon: Symbols.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Messages',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        CircleIconButton(
                          icon: Symbols.search_rounded,
                          onTap: _toggleSearch,
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : threads.isEmpty
                  ? Center(
                      child: _query.isEmpty
                          ? const EmptyStateView(
                              icon: Symbols.chat_bubble_rounded,
                              title: 'No conversations yet',
                              subtitle:
                                  "Message an applicant from their profile and it'll show up here.",
                            )
                          : Text(
                              'No conversations match "$_query"',
                              style: AppText.caption.copyWith(fontSize: 12.5),
                            ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: threads.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _ThreadRow(thread: threads[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  final ChatSummary thread;
  const _ThreadRow({required this.thread});

  @override
  Widget build(BuildContext context) {
    final unread = thread.unread;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StartupChatThreadScreen(
              studentUid: thread.peerUid,
              studentName: thread.peerName,
              studentInitials: thread.peerInitials,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShape.cardShadow,
          ),
          child: Row(
            children: [
              InitialsAvatar(initials: thread.peerInitials, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.peerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      thread.lastMessage.isEmpty
                          ? 'Say hello to get started'
                          : thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                        color: unread ? AppColors.ink : AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (unread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const Icon(
                  Symbols.done_all_rounded,
                  size: 16,
                  color: AppColors.inkFaint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
