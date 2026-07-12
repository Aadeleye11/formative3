import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../theme.dart';

/// Category tint pairs used for skill/category chips across the app.
class CategoryTint {
  final Color bg;
  final Color text;
  const CategoryTint(this.bg, this.text);

  static const design = CategoryTint(
    AppColors.catDesign,
    AppColors.catDesignText,
  );
  static const engineering = CategoryTint(
    AppColors.catEngineering,
    AppColors.catEngineeringText,
  );
  static const data = CategoryTint(AppColors.catData, AppColors.catDataText);
  static const marketing = CategoryTint(
    AppColors.catMarketing,
    AppColors.catMarketingText,
  );
  static const research = CategoryTint(
    AppColors.catResearch,
    AppColors.catResearchText,
  );

  static const _cycle = [engineering, design, data, marketing, research];

  static CategoryTint forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return design;
      case 'engineering':
        return engineering;
      case 'data':
        return data;
      case 'marketing':
      case 'content':
        return marketing;
      case 'research':
      case 'operations':
        return research;
      default:
        return _cycle[category.hashCode.abs() % _cycle.length];
    }
  }
}

/// Plain filled tag chip, e.g. skill tags on opportunity cards.
class TagChip extends StatelessWidget {
  final String label;
  final CategoryTint? tint;
  const TagChip({super.key, required this.label, this.tint});

  @override
  Widget build(BuildContext context) {
    final t = tint ?? CategoryTint.forCategory(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Text(
        label,
        style: AppText.chipLabel.copyWith(color: t.text, fontSize: 11.5),
      ),
    );
  }
}

/// Selectable pill chip with optional check icon (filter chips, skill picker).
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color selectedFill;
  final Color selectedText;

  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.selectedFill = AppColors.primary,
    this.selectedText = Colors.white,
  });

  /// Tint variant: fill = accentTint, text/border = primary (used in filter sheets).
  const SelectableChip.tint({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  }) : selectedFill = AppColors.accentTint,
       selectedText = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? selectedFill : Colors.white,
          borderRadius: BorderRadius.circular(AppShape.pill),
          border: Border.all(
            color: selected
                ? (selectedFill == Colors.white
                      ? AppColors.primary
                      : selectedFill)
                : const Color(0xFFE9E2D6),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Symbols.check_rounded,
                size: 14,
                color: selectedText,
                weight: 600,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppText.chipLabel.copyWith(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? selectedText : const Color(0xFF4A4F64),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Endorsement chip with count, e.g. "Flutter ×3" (green check tint).
class EndorsementChip extends StatelessWidget {
  final String label;
  final int count;
  final CategoryTint tint;
  const EndorsementChip({
    super.key,
    required this.label,
    required this.count,
    this.tint = CategoryTint.engineering,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tint.bg,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Text(
        '$label ×$count',
        style: AppText.chipLabel.copyWith(
          color: tint.text,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Small check + label chip used for endorsed skills (green).
class CheckChip extends StatelessWidget {
  final String label;
  const CheckChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successTint,
        borderRadius: BorderRadius.circular(AppShape.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symbols.check_rounded,
            size: 11,
            color: AppColors.successDeep,
            weight: 600,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppText.chipLabel.copyWith(
              color: AppColors.successDeep,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
