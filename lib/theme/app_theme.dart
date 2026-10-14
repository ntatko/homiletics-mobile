import 'package:flutter/material.dart';

/// Font families bundled in assets/fonts (see pubspec.yaml).
class AppFonts {
  /// Scripture, titles and section headings.
  static const String serif = 'Newsreader';

  /// Everything else: labels, body copy, buttons.
  static const String sans = 'PublicSans';
}

/// One step of a homiletic, or one section of a word study, with the color
/// that identifies it everywhere it appears (editor, progress bar, PDF).
enum StudyStep {
  content('Content'),
  divisions('Divisions'),
  summary('Summary sentence'),
  fcf('FCF'),
  aim('Aim'),
  application('Application');

  final String label;
  const StudyStep(this.label);
}

/// The app's color tokens ("Scripture Desk"): a warm paper ground, white
/// cards, ink text and a single teal accent, plus one earthy color per
/// [StudyStep]. Read with `AppColors.of(context)`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Page background.
  final Color ground;

  /// Cards, panels, the verse panel.
  final Color surface;

  /// A slightly sunken surface (drag handles, tinted rows).
  final Color surfaceSunken;

  /// Hairline borders and dividers.
  final Color line;

  /// Stronger outlines (secondary buttons, empty checkboxes).
  final Color lineStrong;

  /// Primary text.
  final Color ink;

  /// Secondary text; meets 4.5:1 on [ground] and [surface].
  final Color muted;

  /// The accent: primary buttons, links, verse numbers, selected tabs.
  final Color accent;

  /// Text/icons drawn on [accent].
  final Color onAccent;

  /// A pale wash of [accent] for chips and icon tiles.
  final Color accentTint;

  /// The dark recording bar and its foreground.
  final Color recordingBar;
  final Color onRecordingBar;

  /// Live-recording red, and the destructive red for delete actions.
  final Color recording;
  final Color danger;

  /// Highlight behind a word-study word in the passage.
  final Color highlight;

  /// Per-step color and a pale tint of it, indexed by [StudyStep.index].
  final List<Color> stepColors;
  final List<Color> stepTints;

  const AppColors({
    required this.ground,
    required this.surface,
    required this.surfaceSunken,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.recordingBar,
    required this.onRecordingBar,
    required this.recording,
    required this.danger,
    required this.highlight,
    required this.stepColors,
    required this.stepTints,
  });

  static const AppColors light = AppColors(
    ground: Color(0xFFF6F5F1),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEFEDE7),
    line: Color(0xFFE2E0DA),
    lineStrong: Color(0xFFC9C6BE),
    ink: Color(0xFF1D232B),
    muted: Color(0xFF5A626C),
    accent: Color(0xFF0E5C61),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0xFFE3EEEE),
    recordingBar: Color(0xFF1D232B),
    onRecordingBar: Color(0xFFFFFFFF),
    recording: Color(0xFFC2382A),
    danger: Color(0xFFB3261E),
    highlight: Color(0xFFF3E3B5),
    stepColors: [
      Color(0xFF0E5C61), // content: teal
      Color(0xFF6B4A8C), // divisions: plum
      Color(0xFF4F6B2E), // summary: moss
      Color(0xFFA04A1F), // fcf: rust
      Color(0xFF9A3557), // aim: berry
      Color(0xFF2F5785), // application: ink blue
    ],
    stepTints: [
      Color(0xFFE3EEEE),
      Color(0xFFF0EBF5),
      Color(0xFFEAF0E1),
      Color(0xFFF6E8DF),
      Color(0xFFF5E5EB),
      Color(0xFFE3EAF3),
    ],
  );

  static const AppColors dark = AppColors(
    ground: Color(0xFF14171B),
    surface: Color(0xFF1D2126),
    surfaceSunken: Color(0xFF181B1F),
    line: Color(0xFF2D3239),
    lineStrong: Color(0xFF454B54),
    ink: Color(0xFFECE9E2),
    muted: Color(0xFFA4AAB3),
    accent: Color(0xFF6CC0BF),
    onAccent: Color(0xFF0B2A2B),
    accentTint: Color(0xFF1C3335),
    recordingBar: Color(0xFF0E1013),
    onRecordingBar: Color(0xFFECE9E2),
    recording: Color(0xFFF06A5A),
    danger: Color(0xFFF2857A),
    highlight: Color(0xFF5C4A1C),
    stepColors: [
      Color(0xFF6CC0BF),
      Color(0xFFB79BD6),
      Color(0xFFA5C27A),
      Color(0xFFE79A6E),
      Color(0xFFE38AAB),
      Color(0xFF8FB3E0),
    ],
    stepTints: [
      Color(0xFF1C3335),
      Color(0xFF2A2433),
      Color(0xFF242C1C),
      Color(0xFF33251C),
      Color(0xFF33202A),
      Color(0xFF1D2836),
    ],
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  Color step(StudyStep s) => stepColors[s.index];
  Color stepTint(StudyStep s) => stepTints[s.index];

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      ground: l(ground, other.ground),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      line: l(line, other.line),
      lineStrong: l(lineStrong, other.lineStrong),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentTint: l(accentTint, other.accentTint),
      recordingBar: l(recordingBar, other.recordingBar),
      onRecordingBar: l(onRecordingBar, other.onRecordingBar),
      recording: l(recording, other.recording),
      danger: l(danger, other.danger),
      highlight: l(highlight, other.highlight),
      stepColors: [
        for (int i = 0; i < stepColors.length; i++)
          l(stepColors[i], other.stepColors[i])
      ],
      stepTints: [
        for (int i = 0; i < stepTints.length; i++)
          l(stepTints[i], other.stepTints[i])
      ],
    );
  }
}

/// Text styles from the mockups. Colors come from the theme, so these only
/// set family, size and weight; apply a color with `.copyWith` when needed.
class AppText {
  /// Big serif passage title ("Revelation 2:1–11" on the week card).
  static const TextStyle display = TextStyle(
      fontFamily: AppFonts.serif,
      fontSize: 30,
      height: 1.15,
      fontWeight: FontWeight.w500);

  /// Serif page/section title ("Continue", "Divisions").
  static const TextStyle title = TextStyle(
      fontFamily: AppFonts.serif, fontSize: 21, fontWeight: FontWeight.w500);

  /// Serif passage field in editor headers.
  static const TextStyle passageField = TextStyle(
      fontFamily: AppFonts.serif, fontSize: 22, fontWeight: FontWeight.w500);

  /// Scripture text in the verse panel.
  static const TextStyle scripture =
      TextStyle(fontFamily: AppFonts.serif, fontSize: 17, height: 1.6);

  /// Small uppercase label ("THIS WEEK", "WORLD ENGLISH BIBLE").
  static const TextStyle overline = TextStyle(
      fontFamily: AppFonts.sans,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.9);

  static const TextStyle body =
      TextStyle(fontFamily: AppFonts.sans, fontSize: 15, height: 1.45);

  static const TextStyle bodyStrong = TextStyle(
      fontFamily: AppFonts.sans, fontSize: 16, fontWeight: FontWeight.w500);

  static const TextStyle caption =
      TextStyle(fontFamily: AppFonts.sans, fontSize: 13);
}

/// Shared radii and spacing.
class AppRadius {
  static const double card = 20;
  static const double panel = 18;
  static const double tile = 14;
  static const double control = 12;
}

ThemeData buildAppTheme(Brightness brightness) {
  final AppColors c =
      brightness == Brightness.dark ? AppColors.dark : AppColors.light;

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: c.accentTint,
    onPrimaryContainer: c.ink,
    secondary: c.accent,
    onSecondary: c.onAccent,
    secondaryContainer: c.accentTint,
    onSecondaryContainer: c.ink,
    tertiary: c.stepColors[1],
    onTertiary: c.onAccent,
    error: c.danger,
    onError: brightness == Brightness.dark ? c.ground : Colors.white,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.muted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.ground,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface,
    surfaceContainerHighest: c.surfaceSunken,
    outline: c.lineStrong,
    outlineVariant: c.line,
    shadow: Colors.black,
    inverseSurface: c.ink,
    onInverseSurface: c.ground,
  );

  final TextTheme base = ThemeData(brightness: brightness).textTheme.apply(
        fontFamily: AppFonts.sans,
        bodyColor: c.ink,
        displayColor: c.ink,
      );

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.ground,
    fontFamily: AppFonts.sans,
    textTheme: base.copyWith(
      headlineMedium: base.headlineMedium
          ?.copyWith(fontFamily: AppFonts.serif, fontWeight: FontWeight.w500),
      headlineSmall: base.headlineSmall
          ?.copyWith(fontFamily: AppFonts.serif, fontWeight: FontWeight.w500),
      titleLarge: base.titleLarge
          ?.copyWith(fontFamily: AppFonts.serif, fontWeight: FontWeight.w500),
    ),
    extensions: [c],
    appBarTheme: AppBarTheme(
      backgroundColor: c.ground,
      foregroundColor: c.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.title.copyWith(color: c.ink),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: c.line),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      hintStyle: AppText.body.copyWith(color: c.muted),
      labelStyle: AppText.body.copyWith(color: c.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: inputBorder(c.line),
      enabledBorder: inputBorder(c.line),
      focusedBorder: inputBorder(c.accent, 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        minimumSize: const Size(0, 46),
        textStyle: const TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 15,
            fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(0, 46),
        side: BorderSide(color: c.lineStrong),
        textStyle: const TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 15,
            fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        textStyle: const TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      side: BorderSide(color: c.lineStrong),
      labelStyle: AppText.caption.copyWith(color: c.ink),
      shape: const StadiumBorder(),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppText.title.copyWith(color: c.ink),
      contentTextStyle: AppText.body.copyWith(color: c.ink),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.lineStrong,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.tile)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: AppText.body.copyWith(color: c.ground),
      actionTextColor: brightness == Brightness.dark
          ? AppColors.light.accent
          : AppColors.dark.accent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
    tabBarTheme: TabBarThemeData(
      labelColor: c.ink,
      unselectedLabelColor: c.muted,
      indicatorColor: c.accent,
      dividerColor: c.line,
      labelStyle: const TextStyle(
          fontFamily: AppFonts.sans, fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
          fontFamily: AppFonts.sans, fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
