import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../c_startup/startup_shell.dart';

class VerificationPendingScreen extends StatelessWidget {
  final String startupName;
  const VerificationPendingScreen({super.key, required this.startupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(
                          Symbols.hourglass_top_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Verification in progress',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Most reviews are completed within 48 hours. We'll notify you either way.",
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      color: AppColors.inkSecondary,
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShape.cardShadow,
                ),
                child: const Column(
                  children: [
                    TimelineRow(
                      state: TimelineNodeState.done,
                      title: 'Submitted',
                      subtitle: 'Just now',
                    ),
                    TimelineRow(
                      state: TimelineNodeState.current,
                      title: 'Under review',
                      subtitle:
                          'Campus team is checking your Venture Lab certificate.',
                    ),
                    TimelineRow(
                      state: TimelineNodeState.next,
                      title: 'Approved',
                      subtitle: "You'll get a push the moment it's done.",
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GradientBorderCard(
                radius: 18,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.verified_rounded,
                        size: 20,
                        color: AppColors.primary,
                        fill: 1,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF363B50),
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Once approved, $startupName shows a ',
                              ),
                              const TextSpan(
                                text: '✓ ALU Verified',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' badge on every card, post, and message.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              OutlineAppButton(
                label: 'Got it — back to home',
                height: 52,
                textColor: const Color(0xFF4A4F64),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartupShell()),
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
