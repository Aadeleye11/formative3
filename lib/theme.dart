// Design tokens & theme, matching the original mockup board.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFFFAF3EA); // warm cream off-white
  static const surface = Color(0xFFFFFFFF); // cards
  static const inputFill = Color(0xFFF4EDE1); // filled inputs / search
  static const hairline = Color(0xFFEFE9DD); // dividers, nav border

  // Ink
  static const ink = Color(0xFF2D3142); // primary text & icons
  static const inkSecondary = Color(0xFF6B7086); // secondary text
  static const inkMuted = Color(0xFF9295A6); // muted / closed / inactive nav
  static const inkFaint = Color(0xFFC6C8D3); // placeholder icons, chevrons

  // Brand — crimson. Use sparingly: logo, Apply Now, Post role, success orb.
  static const brand = Color(0xFFB33951);
  static const brandPressed = Color(0xFF93293F);

  // Interactive — periwinkle
  static const primary = Color(0xFF5A6AAE); // buttons, links, active nav
  static const primaryPressed = Color(0xFF47558F);
  static const accent = Color(0xFF7D8CC4); // match rings, selected fills
  static const accentTint = Color(0xFFEAEDF6); // selected chip bg, badge tint
  static const accentDeepText = Color(0xFF4D5C9E); // text on accentTint

  // Success / verified — leaf green
  static const success = Color(0xFF628B48);
  static const successDeep = Color(0xFF4E7139); // text on successTint
  static const successTint = Color(0xFFEAF0E4);

  // Statuses (always pair tint bg + label, never color alone)
  static const statusReview = Color(0xFFE09F3E);
  static const statusReviewText = Color(0xFFA9762C);
  static const statusReviewTint = Color(0xFFFBF0DD);
  static const statusInterview = Color(0xFF7D8CC4);
  static const statusInterviewText = Color(0xFF5A6AAE);
  static const statusInterviewTint = Color(0xFFEAEDF6);
  static const statusAccepted = success;
  static const statusAcceptedText = successDeep;
  static const statusAcceptedTint = successTint;
  static const statusClosed = Color(0xFF9295A6);
  static const statusClosedText = Color(0xFF6E7183);
  static const statusClosedTint = Color(0xFFEDEEF1);
  static const danger = Color(0xFFC7333E);
  static const dangerText = Color(0xFFA72934);
  static const dangerTint = Color(0xFFF9E1E3);

  // Cream — gradient warm-end, empty-state circles. Never a full background.
  static const cream = Color(0xFFF1DAC4);

  // Category chip tints (~12%) + label colors
  static const catDesign = Color(0xFFF5E3E7); // rose
  static const catDesignText = Color(0xFFAC5C6E);
  static const catEngineering = Color(0xFFEAEDF6); // periwinkle
  static const catEngineeringText = Color(0xFF5A6AAE);
  static const catData = Color(0xFFEAF0E4); // sage
  static const catDataText = Color(0xFF628B48);
  static const catMarketing = Color(0xFFF8ECDC); // sand
  static const catMarketingText = Color(0xFFB9843B);
  static const catResearch = Color(0xFFEDEBF4); // lilac
  static const catResearchText = Color(0xFF7A6FA8);

  // Signature gradient — hero cards, featured CTAs (135° ≈ topLeft→bottomRight)
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7D8CC4), Color(0xFFF1DAC4)],
  );

  // Avatar fallback gradient (deep→light periwinkle, white initials)
  static const avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A6AAE), Color(0xFF7D8CC4)],
  );

  // Startup logo-tile identity gradients (44×44, r14, white glyph)
  static const logoLearnify = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C7FC4), Color(0xFF96A3D8)],
  );
  static const logoEduBridge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF78FB8), Color(0xFFF7A88C)],
  );
  static const logoGreenLoop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ECC8F), Color(0xFF7FE3B9)],
  );
  static const logoSokoFresh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB067), Color(0xFFFF8E6E)],
  );
  static const logoIleZao = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7FD8A8), Color(0xFF4FBFA0)],
  );
  static const logoKoraHealth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF16D6D), Color(0xFFF7A88C)],
  );
}

// Typography — Plus Jakarta Sans
abstract final class AppText {
  static TextStyle get _base =>
      GoogleFonts.plusJakartaSans(color: AppColors.ink, height: 1.3);

  static TextStyle get greeting => // 28/700 — "Hello, Amina 👋"
  _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle get screenTitle => // 20/700
  _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle get cardTitle => // 17/600
      _base.copyWith(fontSize: 17, fontWeight: FontWeight.w600);
  static TextStyle get sectionHeader => // 15/700
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700);
  static TextStyle get body => // 14/400
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySecondary =>
      body.copyWith(color: AppColors.inkSecondary);
  static TextStyle get caption => // 12/500
  _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSecondary,
  );
  static TextStyle get chipLabel => // 12/600
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get badgeLabel => // 10.5–11/800 status badges, match %
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w800);
  static TextStyle get buttonLabel => // 16/700 on pills
  _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

// Shape, spacing, elevation
abstract final class AppShape {
  static const cardRadius = 20.0; // list cards (hero cards: 24)
  static const heroRadius = 24.0;
  static const inputRadius = 16.0;
  static const logoTileRadius = 14.0;
  static const pill = 999.0;

  static const buttonHeight = 52.0; // primary pills
  static const buttonHeightSecondary = 48.0;
  static const inputHeight = 48.0;
  static const logoTile = 44.0; // 44×44 — also min touch target

  static const sideMargin = 20.0; // screen side padding
  static const sectionGap = 24.0; // vertical rhythm

  /// Soft card shadow.
  static const cardShadow = [
    BoxShadow(color: Color(0x0D2D3142), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// Glow behind a CTA button.
  static List<BoxShadow> ctaShadow(Color c) => [
    BoxShadow(
      color: c.withValues(alpha: .32),
      offset: const Offset(0, 12),
      blurRadius: 26,
    ),
  ];
}

// Theme
ThemeData buildAluLinkTheme() {
  final textTheme = GoogleFonts.plusJakartaSansTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.surface,
    ),
    textTheme: textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style:
          FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(AppShape.buttonHeight),
            shape: const StadiumBorder(),
            textStyle: AppText.buttonLabel,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.pressed)
                  ? AppColors.primaryPressed
                  : AppColors.primary,
            ),
          ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.inkSecondary,
        side: const BorderSide(color: AppColors.hairline, width: 1.5),
        minimumSize: const Size.fromHeight(AppShape.buttonHeightSecondary),
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      hintStyle: AppText.body.copyWith(color: AppColors.inkSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShape.inputRadius),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShape.inputRadius),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.inkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink, // dark toast, e.g. "Your role is live 🎉"
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: AppText.body.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
    ),
  );
}

// Brand (crimson) button — reserve for Apply Now / Post a role / Get started.
class BrandButtonStyle {
  static ButtonStyle get style =>
      FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(AppShape.buttonHeight),
        shape: const StadiumBorder(),
        textStyle: AppText.buttonLabel.copyWith(fontWeight: FontWeight.w800),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.pressed)
              ? AppColors.brandPressed
              : AppColors.brand,
        ),
      );
}
