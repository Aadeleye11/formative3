import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../services/marketplace_repository.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'verification_pending_screen.dart';

class StartupVerificationScreen extends StatefulWidget {
  const StartupVerificationScreen({super.key});

  @override
  State<StartupVerificationScreen> createState() =>
      _StartupVerificationScreenState();
}

class _StartupVerificationScreenState extends State<StartupVerificationScreen> {
  int stage = 1; // Idea/MVP/Revenue
  final nameController = TextEditingController();
  final oneLinerController = TextEditingController();
  final categoryController = TextEditingController();
  bool _submitting = false;
  bool _pickingLogo = false;
  Uint8List? _logoBytes;
  String? _affiliationProofName;

  @override
  void dispose() {
    nameController.dispose();
    oneLinerController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _pickingLogo = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final rawBytes = await file.readAsBytes();
      // The decoder below has no GPU acceleration, so a huge file can freeze
      // the tab — reject early rather than let it hang.
      if (rawBytes.lengthInBytes > 6 * 1024 * 1024) {
        if (!mounted) return;
        showAppToast(
          context,
          'That image is too large — please choose one under 6 MB',
          icon: Symbols.error_rounded,
        );
        return;
      }
      // image_picker's resize options aren't reliable on web, so decode and
      // resize ourselves to stay under Firestore's 1MB document limit.
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        if (!mounted) return;
        showAppToast(
          context,
          "That file doesn't look like an image",
          icon: Symbols.error_rounded,
        );
        return;
      }
      final resized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: 256)
          : img.copyResize(decoded, height: 256);
      final jpg = Uint8List.fromList(img.encodeJpg(resized, quality: 82));
      if (!mounted) return;
      setState(() => _logoBytes = jpg);
    } finally {
      if (mounted) setState(() => _pickingLogo = false);
    }
  }

  Future<void> _pickAffiliationProof() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final name = result?.files.singleOrNull?.name;
    if (name == null || !mounted) return;
    setState(() => _affiliationProofName = name);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await MarketplaceRepository.instance.saveStartupProfile(
        name: nameController.text.trim().isEmpty
            ? 'My Startup'
            : nameController.text.trim(),
        category: categoryController.text.trim().isEmpty
            ? 'Startup'
            : categoryController.text.trim(),
        city: 'Kigali',
        oneLiner: oneLinerController.text.trim(),
        stage: const ['Idea', 'MVP', 'Revenue'][stage],
        logoBytes: _logoBytes,
        affiliationProofName: _affiliationProofName,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerificationPendingScreen(
            startupName: nameController.text.trim().isEmpty
                ? 'My Startup'
                : nameController.text.trim(),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('saveStartupProfile failed: $e\n$st');
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppToast(
        context,
        "Couldn't submit. Please try again.",
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Verify your startup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentTint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Symbols.shield_rounded,
                              size: 17,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Only recognized ALU ventures get listed. Reviewed by the campus team.',
                                style: AppText.caption.copyWith(
                                  fontSize: 11.5,
                                  color: AppColors.accentDeepText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: _pickingLogo ? null : _pickLogo,
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5EFE4),
                                borderRadius: BorderRadius.circular(19),
                                border: Border.all(
                                  color: const Color(0xFFC3C9E0),
                                  width: 2,
                                ),
                              ),
                              child: _pickingLogo
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                        ),
                                      ),
                                    )
                                  : _logoBytes != null
                                  ? Image.memory(
                                      _logoBytes!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Symbols.upload_rounded,
                                      size: 26,
                                      color: AppColors.primary,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _logoBytes != null
                                      ? 'Logo selected'
                                      : 'Upload logo',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _logoBytes != null
                                      ? 'Tap to change'
                                      : 'PNG · 512×512 or larger',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Startup name',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: nameController,
                        hint: 'Learnify',
                        icon: Symbols.rocket_launch_rounded,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'One-liner',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: oneLinerController,
                        hint: 'Peer-powered revision app for ALU students',
                        icon: Symbols.edit_rounded,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: categoryController,
                                  hint: 'Edtech',
                                  trailingIcon: Symbols.expand_more_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stage',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppSegmentedControl(
                                  labels: const ['Idea', 'MVP', 'Revenue'],
                                  index: stage,
                                  onChanged: (i) => setState(() => stage = i),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _pickAffiliationProof,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFC3C9E0),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.accent.withValues(alpha: .03),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _affiliationProofName != null
                                    ? Symbols.check_circle_rounded
                                    : Symbols.upload_file_rounded,
                                size: 28,
                                color: _affiliationProofName != null
                                    ? AppColors.success
                                    : AppColors.primary,
                                fill: _affiliationProofName != null ? 1 : 0,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ALU affiliation proof',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Venture Lab certificate or faculty endorsement letter · PDF, JPG · max 10 MB',
                                textAlign: TextAlign.center,
                                style: AppText.caption.copyWith(
                                  fontSize: 11.5,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_affiliationProofName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: AppShape.cardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _affiliationProofName!
                                                .toLowerCase()
                                                .endsWith('.pdf')
                                            ? Symbols.picture_as_pdf_rounded
                                            : Symbols.image_rounded,
                                        size: 22,
                                        color: AppColors.danger,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _affiliationProofName!,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Symbols.check_circle_rounded,
                                        size: 18,
                                        color: AppColors.success,
                                        fill: 1,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  'Tap to choose a file',
                                  style: AppText.caption.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: _submitting ? 'Submitting…' : 'Submit for review',
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
