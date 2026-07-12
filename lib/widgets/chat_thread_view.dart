import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/models.dart';
import '../services/auth_service.dart';
import '../services/marketplace_repository.dart';
import '../theme.dart';

/// Shared message list + input bar for a chat thread. [header] is owned by
/// the caller, since student vs. founder show different chrome.
class ChatThreadView extends StatefulWidget {
  final Future<String> chatIdFuture;
  final bool senderIsStudent;
  final Widget header;

  const ChatThreadView({
    super.key,
    required this.chatIdFuture,
    required this.senderIsStudent,
    required this.header,
  });

  @override
  State<ChatThreadView> createState() => _ChatThreadViewState();
}

class _ChatThreadViewState extends State<ChatThreadView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  String? _chatId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    widget.chatIdFuture.then((id) {
      if (!mounted) return;
      setState(() => _chatId = id);
      MarketplaceRepository.instance.markChatRead(
        id,
        asStudent: widget.senderIsStudent,
      );
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final chatId = _chatId;
    final text = _inputController.text.trim();
    if (chatId == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _inputController.clear();
    try {
      await MarketplaceRepository.instance.sendMessage(
        chatId,
        text,
        senderIsStudent: widget.senderIsStudent,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.instance.currentUser?.uid;
    final chatId = _chatId;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            widget.header,
            Expanded(
              child: chatId == null
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : StreamBuilder<List<ChatMessageDoc>>(
                      stream: MarketplaceRepository.instance.watchMessages(
                        chatId,
                      ),
                      builder: (context, snapshot) {
                        final messages =
                            snapshot.data ?? const <ChatMessageDoc>[];
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            messages.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                            ),
                          );
                        }
                        if (messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Say hello — this is the start of your conversation.',
                                textAlign: TextAlign.center,
                                style: AppText.caption.copyWith(
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          );
                        }
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _scrollToBottom(),
                        );
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: messages.length,
                          itemBuilder: (context, i) => _bubble(
                            messages[i],
                            messages[i].senderUid == myUid,
                          ),
                        );
                      },
                    ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatMessageDoc m, bool mine) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 264),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : Colors.white,
          boxShadow: mine ? null : AppShape.cardShadow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                m.text,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: mine ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                m.createdAt != null ? _timeLabel(m.createdAt!) : '',
                style: TextStyle(
                  fontSize: 10,
                  color: mine ? Colors.white70 : AppColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _inputController,
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.send_rounded,
                color: Colors.white,
                fill: 1,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
