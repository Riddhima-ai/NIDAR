
import 'package:flutter/material.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg;
  final Color sidebar;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentMuted;
  final Color success;
  final Color successMuted;
  final Color warning;
  final Color warningMuted;
  final Color danger;
  final Color dangerMuted;

  const AppPalette({
    required this.bg,
    required this.sidebar,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentMuted,
    required this.success,
    required this.successMuted,
    required this.warning,
    required this.warningMuted,
    required this.danger,
    required this.dangerMuted,
  });

  static const dark = AppPalette(
    bg: Color(0xFF0A0E17),
    sidebar: Color(0xFF0D1119),
    surface: Color(0xFF12161F),
    surface2: Color(0xFF1A1F2B),
    border: Color(0xFF232937),
    textPrimary: Color(0xFFF2F4F8),
    textSecondary: Color(0xFF8B93A7),
    accent: Color(0xFF4C8DFF),
    accentMuted: Color(0xFF1D2B4A),
    success: Color(0xFF22C55E),
    successMuted: Color(0xFF14301F),
    warning: Color(0xFFE0A930),
    warningMuted: Color(0xFF3A2E10),
    danger: Color(0xFFE5484D),
    dangerMuted: Color(0xFF3A1A1B),
  );

  static const light = AppPalette(
    bg: Color(0xFFF3F5F9),
    sidebar: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F2F6),
    border: Color(0xFFE1E5ED),
    textPrimary: Color(0xFF11141C),
    textSecondary: Color(0xFF667085),
    accent: Color(0xFF2F6FEB),
    accentMuted: Color(0xFFE4EDFF),
    success: Color(0xFF149652),
    successMuted: Color(0xFFE3F7EA),
    warning: Color(0xFFAD7B0C),
    warningMuted: Color(0xFFFBF0DC),
    danger: Color(0xFFD03A3F),
    dangerMuted: Color(0xFFFCE7E7),
  );

  @override
  AppPalette copyWith({
    Color? bg, Color? sidebar, Color? surface, Color? surface2, Color? border,
    Color? textPrimary, Color? textSecondary, Color? accent, Color? accentMuted,
    Color? success, Color? successMuted, Color? warning, Color? warningMuted,
    Color? danger, Color? dangerMuted,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      sidebar: sidebar ?? this.sidebar,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      success: success ?? this.success,
      successMuted: successMuted ?? this.successMuted,
      warning: warning ?? this.warning,
      warningMuted: warningMuted ?? this.warningMuted,
      danger: danger ?? this.danger,
      dangerMuted: dangerMuted ?? this.dangerMuted,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningMuted: Color.lerp(warningMuted, other.warningMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

ThemeData buildAppTheme(AppPalette p, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: Colors.white,
      secondary: p.accent,
      onSecondary: Colors.white,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1),
    textTheme: Typography.material2021(platform: TargetPlatform.macOS)
        .white
        .apply(bodyColor: p.textPrimary, displayColor: p.textPrimary),
    extensions: [p],
  );
}

ThemeData get darkAppTheme => buildAppTheme(AppPalette.dark, Brightness.dark);
ThemeData get lightAppTheme => buildAppTheme(AppPalette.light, Brightness.light);