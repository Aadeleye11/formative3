import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';

/// Eloquent animated dropdown for picking a (program name, degree) pair.
class ProgramDropdown extends StatefulWidget {
  final (String, String) value;
  final List<(String, String)> options;
  final ValueChanged<(String, String)> onChanged;

  const ProgramDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  State<ProgramDropdown> createState() => _ProgramDropdownState();
}

class _ProgramDropdownState extends State<ProgramDropdown> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            height: AppShape.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(AppShape.inputRadius),
                bottom: Radius.circular(expanded ? 0 : AppShape.inputRadius),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.school_rounded,
                  size: 20,
                  color: AppColors.inkSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.value.$1} · ${widget.value.$2}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Symbols.expand_more_rounded,
                    size: 20,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: !expanded
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(AppShape.inputRadius),
                    ),
                    boxShadow: AppShape.cardShadow,
                  ),
                  child: Column(
                    children: widget.options.map((p) {
                      final active = p == widget.value;
                      return GestureDetector(
                        onTap: () {
                          widget.onChanged(p);
                          setState(() => expanded = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.background),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.$1,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: active
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentTint,
                                  borderRadius: BorderRadius.circular(
                                    AppShape.pill,
                                  ),
                                ),
                                child: Text(
                                  p.$2,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              if (active) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Symbols.check_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                  weight: 700,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
