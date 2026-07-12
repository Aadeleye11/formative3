import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

/// Real chat between the signed-in founder and one of their applicants.
class StartupChatThreadScreen extends StatelessWidget {
  final String studentUid;
  final String studentName;
  final String studentInitials;

  const StartupChatThreadScreen({
    super.key,
    required this.studentUid,
    required this.studentName,
    required this.studentInitials,
  });

  @override
  Widget build(BuildContext context) {
    return ChatThreadView(
      senderIsStudent: false,
      chatIdFuture: MarketplaceRepository.instance.getOrCreateChatAsStartup(
        studentUid: studentUid,
        studentName: studentName,
        studentInitials: studentInitials,
      ),
      header: _header(context),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: AppShape.cardShadow,
      ),
      child: Row(
        children: [
          CircleIconButton(
            icon: Symbols.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          InitialsAvatar(initials: studentInitials, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              studentName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
