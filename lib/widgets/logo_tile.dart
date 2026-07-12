import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme.dart';

/// 44×44 r14 gradient tile with a white glyph — a startup's brand mark.
class LogoTile extends StatelessWidget {
  final StartupBrand startup;
  final double size;
  final double radius;

  const LogoTile({
    super.key,
    required this.startup,
    this.size = AppShape.logoTile,
    this.radius = AppShape.logoTileRadius,
  });

  @override
  Widget build(BuildContext context) {
    final logo = startup.logoBytes;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: logo == null ? startup.gradient : null,
        color: logo == null ? null : Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: logo == null
          ? Icon(startup.icon, color: Colors.white, size: size * 0.46)
          : Image.memory(logo, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// Circular avatar — a photo if [photoBytes] is set, else initials.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Gradient gradient;
  final Uint8List? photoBytes;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.gradient = AppColors.avatarGradient,
    this.photoBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      child: photoBytes != null
          ? Image.memory(
              photoBytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.32,
              ),
            ),
    );
  }
}

/// White circular icon button used for back/share/bookmark chrome floating over content.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final Widget? badge;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppColors.ink,
    this.size = 40,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShape.cardShadow,
              ),
              child: Icon(icon, size: size * 0.5, color: color),
            ),
          ),
        ),
        if (badge != null) Positioned(top: -2, right: -2, child: badge!),
      ],
    );
  }
}
