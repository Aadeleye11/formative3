import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../dev/screen_gallery.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _openGallery(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScreenGalleryScreen()));
  }

  void _getStarted(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -110,
            child: _blurOrb(340, AppColors.accent.withValues(alpha: .32)),
          ),
          Positioned(
            bottom: -80,
            right: -120,
            child: _blurOrb(360, AppColors.cream.withValues(alpha: .6)),
          ),
          Positioned(
            top: 260,
            right: -90,
            child: _blurOrb(220, AppColors.accent.withValues(alpha: .16)),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onLongPress: () => _openGallery(context),
                  child: Container(
                    width: 106,
                    height: 106,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: .35),
                          offset: const Offset(0, 20),
                          blurRadius: 44,
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: -0.785,
                      child: const Icon(
                        Icons.link_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ALULink',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Where ALU talent meets ALU ventures.',
                  style: AppText.body.copyWith(color: AppColors.inkSecondary),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GradientButton(
                  label: 'Get started',
                  onPressed: () => _getStarted(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
