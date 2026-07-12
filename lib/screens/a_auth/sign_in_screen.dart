import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'startup_verification_screen.dart';
import 'student_setup_screen.dart';

class SignInScreen extends StatefulWidget {
  final AppRole role;
  const SignInScreen({super.key, required this.role});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _googleLoading = false;
  bool _showError = false;
  String? _rejectedEmail;

  void _navigateToNextStep() {
    final target = widget.role == AppRole.student
        ? const StudentSetupScreen()
        : const StartupVerificationScreen();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _showError = false;
    });
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        // User cancelled the account picker.
        setState(() => _googleLoading = false);
        return;
      }
      _navigateToNextStep();
    } on NotAluEmailException catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        _showError = true;
        _rejectedEmail = e.email;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _googleLoading = false);
      showAppToast(
        context,
        'Sign-in failed. Please try again.',
        icon: Symbols.error_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: .3),
                      offset: const Offset(0, 10),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -0.785,
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to your campus marketplace.',
                style: AppText.body.copyWith(color: AppColors.inkSecondary),
              ),
              if (_showError) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0C8CC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Symbols.error_rounded,
                        size: 20,
                        color: AppColors.danger,
                        fill: 1,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _rejectedEmail != null
                                  ? "$_rejectedEmail isn't part of the ALU community."
                                  : "This email isn't part of the ALU community.",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dangerText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Sign in with your @alustudent.com or @alueducation.com email.',
                              style: AppText.caption.copyWith(
                                fontSize: 12,
                                color: const Color(0xFFAF5F68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _googleLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(
                      color: Color(0xFFEBE4D8),
                      width: 1.5,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: _googleLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'G',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Continue with Google',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.school_rounded,
                        size: 14,
                        color: AppColors.primary,
                        fill: 1,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'ALU emails only · @alustudent.com · @alueducation.com',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentDeepText,
                          ),
                        ),
                      ),
                    ],
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
