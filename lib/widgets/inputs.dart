import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';

/// Filled r16 h48 text field with a leading icon — the standard form input.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool obscure;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final FontWeight fontWeight;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.trailingIcon,
    this.onTrailingTap,
    this.obscure = false,
    this.hasError = false,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.fontWeight = FontWeight.w500,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: maxLines > 1 ? 96 : AppShape.inputHeight,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(AppShape.inputRadius),
            border: hasError
                ? Border.all(color: AppColors.danger, width: 1.5)
                : null,
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: hasError ? AppColors.danger : AppColors.inkSecondary,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  onChanged: onChanged,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: AppText.body.copyWith(
                    fontWeight: fontWeight,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    counterText: '',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (trailingIcon != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Icon(
                    trailingIcon,
                    size: 20,
                    color: AppColors.inkFaint,
                  ),
                ),
            ],
          ),
        ),
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
      ],
    );
  }
}

/// Search bar with leading search glyph.
class SearchField extends StatelessWidget {
  final String hint;
  final bool focused;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SearchField({
    super.key,
    this.hint = 'Search…',
    this.focused = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppShape.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: focused ? Colors.white : AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppShape.inputRadius),
          border: focused
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: focused ? AppShape.cardShadow : null,
        ),
        child: Row(
          children: [
            Icon(
              Symbols.search_rounded,
              size: 20,
              color: focused ? AppColors.primary : AppColors.inkSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Pill-track segmented control — animates the active pill position.
class AppSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const AppSegmentedControl({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppShape.pill),
                    boxShadow: i == index ? AppShape.cardShadow : null,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: i == index
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: i == index
                          ? AppColors.primary
                          : AppColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dark toast matching the mockup's snackbar treatment.
void showAppToast(
  BuildContext context,
  String message, {
  IconData icon = Symbols.check_circle_rounded,
  String? actionLabel,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.success, fill: 1),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
            if (actionLabel != null)
              Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFFB9C2E6),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
}
