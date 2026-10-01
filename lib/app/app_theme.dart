import 'package:flutter/material.dart';

class AppTheme {
  static const orange = Color(0xffff4b14);
  static const blue = Color(0xff0877c9);
  static const green = Color(0xff2e9b47);
  static const surface = Color(0xfffbfaf8);
  static const ink = Color(0xff151515);
  static const border = Color(0xffeeeeee);

  static const supportedLocales = [
    Locale('en'),
    Locale('so'),
    Locale('ar'),
    Locale('zh'),
    Locale('fr'),
    Locale('es'),
    Locale('tr'),
    Locale('sw'),
    Locale('hi'),
    Locale('pt'),
  ];

  static Locale localeFor(String language) {
    return switch (language) {
      'Somali' => const Locale('so'),
      'Arabic' => const Locale('ar'),
      'Chinese' => const Locale('zh'),
      'French' => const Locale('fr'),
      'Spanish' => const Locale('es'),
      'Turkish' => const Locale('tr'),
      'Swahili' => const Locale('sw'),
      'Hindi' => const Locale('hi'),
      'Portuguese' => const Locale('pt'),
      _ => const Locale('en'),
    };
  }

  // Somali is supported by the app translations but not by Flutter's
  // built-in MaterialLocalizations delegate, so Material uses English safely.
  static Locale materialLocaleFor(String language) {
    return language == 'Somali' ? const Locale('en') : localeFor(language);
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: orange,
        secondary: blue,
        tertiary: green,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: Typography.blackMountainView.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: orange,
      brightness: Brightness.dark,
      primary: orange,
      secondary: blue,
      tertiary: green,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff121212),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xff1e1e1e),
        surfaceTintColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: Color(0xff353535)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1e1e1e),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff353535)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff353535)),
        ),
      ),
    );
  }
}
