import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../data/fixtures.dart';
import '../../data/student_options.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final nameController = TextEditingController(text: Fixtures.amina.name);
  late final cohortController = TextEditingController(
    text: Fixtures.amina.cohort,
  );
  late final cityController = TextEditingController(text: Fixtures.amina.city);
  late (String, String) selectedProgram = kPrograms.firstWhere(
    (p) => '${p.$2} ${p.$1}' == Fixtures.amina.program,
    orElse: () => kPrograms.first,
  );
  Uint8List? pickedPhotoBytes;
  bool pickingPhoto = false;

  @override
  void dispose() {
    nameController.dispose();
    cohortController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => pickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => pickedPhotoBytes = bytes);
    } finally {
      if (mounted) setState(() => pickingPhoto = false);
    }
  }

  void _save() {
    final enteredName = nameController.text.trim();
    final enteredCohort = cohortController.text.trim();
    final enteredCity = cityController.text.trim();
    Fixtures.amina = Fixtures.amina.copyWith(
      name: enteredName.isEmpty ? null : enteredName,
      initials: enteredName.isEmpty
          ? null
          : initialsFromName(enteredName, fallback: Fixtures.amina.initials),
      cohort: enteredCohort.isEmpty ? null : enteredCohort,
      city: enteredCity.isEmpty ? null : enteredCity,
      program: '${selectedProgram.$2} ${selectedProgram.$1}',
      photoBytes: pickedPhotoBytes,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final existingPhoto = pickedPhotoBytes ?? Fixtures.amina.photoBytes;
    final googlePhotoUrl = AuthService.instance.currentUser?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                        'Edit profile',
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: pickingPhoto ? null : _pickPhoto,
                            child: Column(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5EFE4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC3C9E0),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (existingPhoto != null)
                                        Image.memory(
                                          existingPhoto,
                                          fit: BoxFit.cover,
                                        )
                                      else if (googlePhotoUrl != null)
                                        Image.network(
                                          googlePhotoUrl,
                                          fit: BoxFit.cover,
                                        )
                                      else
                                        const Center(
                                          child: Icon(
                                            Symbols.photo_camera_rounded,
                                            size: 34,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      if (pickingPhoto)
                                        Container(
                                          color: Colors.black.withValues(
                                            alpha: .35,
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.background,
                                              width: 3,
                                            ),
                                          ),
                                          child: const Icon(
                                            Symbols.edit_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Change photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Full name',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: nameController,
                          hint: 'Enter your full name',
                          icon: Symbols.person_rounded,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Program',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ProgramDropdown(
                          value: selectedProgram,
                          options: kPrograms,
                          onChanged: (p) => setState(() => selectedProgram = p),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cohort',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: cohortController,
                          hint: "Class of '27",
                          icon: Symbols.calendar_today_rounded,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'City',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: cityController,
                          hint: 'Kigali, Rwanda',
                          icon: Symbols.location_on_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Save changes', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
