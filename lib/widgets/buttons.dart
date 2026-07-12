import 'package:flutter/material.dart';
import '../theme.dart';

/// Solid periwinkle pill button — the default primary CTA.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.height = AppShape.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppShape.pill),
          boxShadow: onPressed == null
              ? null
              : AppShape.ctaShadow(AppColors.primary),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style:
              FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: .45,
                ),
                shape: const StadiumBorder(),
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.pressed)
                      ? AppColors.primaryPressed
                      : null,
                ),
              ),
          child: _ButtonContent(
            label: label,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
          ),
        ),
      ),
    );
  }
}

/// Solid crimson pill — reserved for high-commitment actions like Apply Now.
class BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final double height;

  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.height = AppShape.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppShape.pill),
          boxShadow: onPressed == null
              ? null
              : AppShape.ctaShadow(AppColors.brand),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: BrandButtonStyle.style,
          child: _ButtonContent(
            label: label,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
            weight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Gradient pill for featured CTAs.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.height = AppShape.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppShape.pill),
          boxShadow: AppShape.ctaShadow(AppColors.accent),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppShape.pill),
            onTap: onPressed,
            child: _ButtonContent(
              label: label,
              leadingIcon: leadingIcon,
              weight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// White pill with hairline border — secondary action.
class OutlineAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final Color textColor;
  final double height;

  const OutlineAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.textColor = AppColors.ink,
    this.height = AppShape.buttonHeightSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.hairline, width: 1.5),
          shape: const StadiumBorder(),
        ),
        child: _ButtonContent(
          label: label,
          leadingIcon: leadingIcon,
          color: textColor,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: AppText.chipLabel.copyWith(
          color: color,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color color;
  final FontWeight weight;

  const _ButtonContent({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.color = Colors.white,
    this.weight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppText.buttonLabel.copyWith(
              color: color,
              fontWeight: weight,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18, color: color),
        ],
      ],
    );
  }
}
