import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../core/domain/entities/power_zone.dart';

/// Picks whichever of black/white has the higher WCAG contrast ratio
/// against [background] — used for text drawn directly on a zone-colored
/// fill, since a fixed white label fails AA contrast on the brighter zones
/// (Threshold yellow ≈ 1.2:1, VO2max orange ≈ 2.2:1 — see P7 contrast audit).
Color contrastingTextColor(Color background) {
  final luminance = background.computeLuminance();
  final contrastWithWhite = 1.05 / (luminance + 0.05);
  final contrastWithBlack = (luminance + 0.05) / 0.05;
  return contrastWithBlack >= contrastWithWhite ? Colors.black : Colors.white;
}

/// Convenience accessor: `context.tokens.surfaceTier1`.
///
/// Falls back to [AppTokens.dark] when no [AppTokens] extension is
/// registered on the ambient theme — e.g. a widget test that pumps a bare
/// `MaterialApp` without [AppTheme.light]/[AppTheme.dark] — so a missing
/// extension degrades gracefully instead of crashing the widget tree.
extension AppThemeX on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.dark;
}

/// App-wide design tokens not covered by [ColorScheme] — surface tiers (the
/// black/#111111/#1A1A1A hierarchy used for nav bars, cards, and chart
/// backgrounds), the ride screen's deliberately-near-black surface, the
/// single-source zone color spectrum, data-field text styles, and a spacing
/// scale. Registered as a [ThemeExtension] on both [AppTheme.light] and
/// [AppTheme.dark] so widgets read `context.tokens` instead of hard-coding
/// hex literals.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.surfaceTier0,
    required this.surfaceTier1,
    required this.surfaceTier2,
    required this.surfaceTier3,
    required this.surfaceTier3Line,
    required this.rideSurface,
    required this.rideSurfaceDeep,
    required this.rideSurfaceLine,
    required this.rideOnSurface,
    required this.rideOnSurfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.zoneColors,
    required this.dataFieldValueStyle,
    required this.dataFieldLabelStyle,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
  });

  /// Scaffold background (tier 0 — furthest back).
  final Color surfaceTier0;

  /// Nav bars / header bars (tier 1).
  final Color surfaceTier1;

  /// Cards, dialogs, sheets, dropdowns (tier 2).
  final Color surfaceTier2;

  /// Chart backgrounds, deep insets (tier 3 — closest to black/white).
  final Color surfaceTier3;

  /// Grid lines / dividers drawn on top of [surfaceTier3].
  final Color surfaceTier3Line;

  /// Ride screen surface — deliberately near-black in *both* themes for
  /// readability on a trainer, so it is a token rather than a `Colors.black`
  /// literal (see P7 task 1).
  final Color rideSurface;

  /// Deep inset within the ride screen (live chart / route profile
  /// background) — one shade darker than [rideSurface], also theme-invariant.
  final Color rideSurfaceDeep;

  /// Grid lines / dividers drawn on [rideSurfaceDeep].
  final Color rideSurfaceLine;

  /// Primary text/icon color on [rideSurface].
  final Color rideOnSurface;

  /// Secondary/muted text color on [rideSurface].
  final Color rideOnSurfaceMuted;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  /// Single source of truth for zone-derived coloring (power gauge, zone
  /// bar, live chart, route grade strip). Same length/order as
  /// [PowerZone.coggan7]. Colors are theme-invariant by design — a zone
  /// should read the same on light and dark.
  final List<Color> zoneColors;

  /// Monospaced, tabular-figure style for numeric data fields (ride HUD).
  final TextStyle dataFieldValueStyle;

  /// Small caps-style label under a data field value.
  final TextStyle dataFieldLabelStyle;

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;

  static const dark = AppTokens(
    surfaceTier0: Colors.black,
    surfaceTier1: Color(0xFF111111),
    surfaceTier2: Color(0xFF1A1A1A),
    surfaceTier3: Color(0xFF0A0A0A),
    surfaceTier3Line: Color(0xFF222222),
    rideSurface: Colors.black,
    rideSurfaceDeep: Color(0xFF0A0A0A),
    rideSurfaceLine: Color(0xFF222222),
    rideOnSurface: Colors.white,
    rideOnSurfaceMuted: Colors.white54,
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textTertiary: Colors.white54,
    textDisabled: Colors.white38,
    zoneColors: PowerZone.zoneColorPalette,
    dataFieldValueStyle: TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    dataFieldLabelStyle: TextStyle(
      fontSize: 12,
      color: Colors.white54,
      letterSpacing: 0.5,
    ),
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
  );

  static const light = AppTokens(
    surfaceTier0: Color(0xFFF7F7F7),
    surfaceTier1: Colors.white,
    surfaceTier2: Colors.white,
    surfaceTier3: Color(0xFFEDEDED),
    surfaceTier3Line: Color(0xFFDDDDDD),
    // Deliberately unchanged from dark — see [rideSurface] doc above.
    rideSurface: Colors.black,
    rideSurfaceDeep: Color(0xFF0A0A0A),
    rideSurfaceLine: Color(0xFF222222),
    rideOnSurface: Colors.white,
    rideOnSurfaceMuted: Colors.white54,
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF4D4D4D),
    textTertiary: Color(0xFF757575),
    textDisabled: Color(0xFFBDBDBD),
    zoneColors: PowerZone.zoneColorPalette,
    dataFieldValueStyle: TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A1A1A),
    ),
    dataFieldLabelStyle: TextStyle(
      fontSize: 12,
      color: Color(0xFF757575),
      letterSpacing: 0.5,
    ),
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
  );

  @override
  AppTokens copyWith({
    Color? surfaceTier0,
    Color? surfaceTier1,
    Color? surfaceTier2,
    Color? surfaceTier3,
    Color? surfaceTier3Line,
    Color? rideSurface,
    Color? rideSurfaceDeep,
    Color? rideSurfaceLine,
    Color? rideOnSurface,
    Color? rideOnSurfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    List<Color>? zoneColors,
    TextStyle? dataFieldValueStyle,
    TextStyle? dataFieldLabelStyle,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
  }) {
    return AppTokens(
      surfaceTier0: surfaceTier0 ?? this.surfaceTier0,
      surfaceTier1: surfaceTier1 ?? this.surfaceTier1,
      surfaceTier2: surfaceTier2 ?? this.surfaceTier2,
      surfaceTier3: surfaceTier3 ?? this.surfaceTier3,
      surfaceTier3Line: surfaceTier3Line ?? this.surfaceTier3Line,
      rideSurface: rideSurface ?? this.rideSurface,
      rideSurfaceDeep: rideSurfaceDeep ?? this.rideSurfaceDeep,
      rideSurfaceLine: rideSurfaceLine ?? this.rideSurfaceLine,
      rideOnSurface: rideOnSurface ?? this.rideOnSurface,
      rideOnSurfaceMuted: rideOnSurfaceMuted ?? this.rideOnSurfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      zoneColors: zoneColors ?? this.zoneColors,
      dataFieldValueStyle: dataFieldValueStyle ?? this.dataFieldValueStyle,
      dataFieldLabelStyle: dataFieldLabelStyle ?? this.dataFieldLabelStyle,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      surfaceTier0: Color.lerp(surfaceTier0, other.surfaceTier0, t)!,
      surfaceTier1: Color.lerp(surfaceTier1, other.surfaceTier1, t)!,
      surfaceTier2: Color.lerp(surfaceTier2, other.surfaceTier2, t)!,
      surfaceTier3: Color.lerp(surfaceTier3, other.surfaceTier3, t)!,
      surfaceTier3Line: Color.lerp(surfaceTier3Line, other.surfaceTier3Line, t)!,
      rideSurface: Color.lerp(rideSurface, other.rideSurface, t)!,
      rideSurfaceDeep: Color.lerp(rideSurfaceDeep, other.rideSurfaceDeep, t)!,
      rideSurfaceLine: Color.lerp(rideSurfaceLine, other.rideSurfaceLine, t)!,
      rideOnSurface: Color.lerp(rideOnSurface, other.rideOnSurface, t)!,
      rideOnSurfaceMuted:
          Color.lerp(rideOnSurfaceMuted, other.rideOnSurfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      // Discrete palette — zone colors don't crossfade, they snap at the
      // midpoint of a theme transition.
      zoneColors: t < 0.5 ? zoneColors : other.zoneColors,
      dataFieldValueStyle:
          TextStyle.lerp(dataFieldValueStyle, other.dataFieldValueStyle, t)!,
      dataFieldLabelStyle:
          TextStyle.lerp(dataFieldLabelStyle, other.dataFieldLabelStyle, t)!,
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
    );
  }
}

/// Material 3 [ThemeData] factory for OpenBike's light and dark themes.
/// Both seed from the same deep-orange accent; only surfaces/text tokens
/// diverge (see [AppTokens]).
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppTokens.light);
  static ThemeData get dark => _build(Brightness.dark, AppTokens.dark);

  static ThemeData _build(Brightness brightness, AppTokens tokens) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.surfaceTier0,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surfaceTier0,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: tokens.surfaceTier2,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(color: tokens.surfaceTier3Line),
      listTileTheme: ListTileThemeData(iconColor: tokens.textTertiary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surfaceTier1,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: tokens.textDisabled,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: tokens.surfaceTier1,
      ),
      extensions: [tokens],
    );
  }
}
