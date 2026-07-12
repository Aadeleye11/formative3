import 'package:flutter/material.dart';
import '../theme.dart';

/// Wraps [child] in a gradient border for featured surfaces like Passport cards.
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final Color innerColor;
  final Gradient gradient;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderWidth = 1.5,
    this.innerColor = AppColors.surface,
    this.gradient = AppColors.heroGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: innerColor,
          borderRadius: BorderRadius.circular(radius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
