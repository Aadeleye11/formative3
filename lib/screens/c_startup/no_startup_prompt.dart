import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../a_auth/startup_verification_screen.dart';

/// Shown in place of real content until the founder completes verification.
class NoStartupPrompt extends StatelessWidget {
  const NoStartupPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.storefront_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Set up your startup workspace',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your venture to start posting roles and reviewing applicants.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: AppColors.inkSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              BrandButton(
                label: 'Get started',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StartupVerificationScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
