import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../c_startup/startup_public_profile_screen.dart';

/// Chat between the signed-in student and a startup.
class ChatThreadScreen extends StatelessWidget {
  final String startupUid;
  final String startupName;
  final int startupGradientSeed;

  const ChatThreadScreen({
    super.key,
    required this.startupUid,
    required this.startupName,
    required this.startupGradientSeed,
  });

  Future<void> _viewProfile(BuildContext context) async {
    final brand = await MarketplaceRepository.instance.getStartupByUid(
      startupUid,
    );
    if (!context.mounted) return;
    if (brand == null) {
      showAppToast(context, "This startup's profile isn't available yet");
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StartupPublicProfileScreen(startup: brand),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Symbols.storefront_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'View public profile',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _viewProfile(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatThreadView(
      senderIsStudent: true,
      chatIdFuture: MarketplaceRepository.instance.getOrCreateChatAsStudent(
        startupUid: startupUid,
        startupName: startupName,
        startupGradientSeed: startupGradientSeed,
      ),
      header: _header(context),
    );
  }

  Widget _header(BuildContext context) {
    final gradient = MarketplaceRepository.instance.gradientForSeed(
      startupGradientSeed,
    );
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
          Container(
            width: AppShape.logoTile,
            height: AppShape.logoTile,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppShape.logoTileRadius),
            ),
            child: const Icon(
              Symbols.storefront_rounded,
              color: Colors.white,
              size: AppShape.logoTile * 0.46,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    startupName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                const VerifiedBadge(pillStyle: false),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openMenu(context),
            child: const Icon(
              Symbols.more_vert_rounded,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
