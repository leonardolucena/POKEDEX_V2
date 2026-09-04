import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/core/theme/app_status_bar_style.dart';

enum AppFontFamily {
  pressStart2P,
  montserrat,
}

abstract final class AppTheme {
  static const AppFontFamily fontFamily = AppFontFamily.pressStart2P;

  static ThemeData light() {
    final textTheme = _textTheme();
    final fontFamilyName = _fontFamilyName();

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      useMaterial3: true,
      fontFamily: fontFamilyName,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: AppStatusBarStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
    );
  }

  static TextTheme _textTheme() {
    return switch (fontFamily) {
      AppFontFamily.pressStart2P => GoogleFonts.pressStart2pTextTheme(),
      AppFontFamily.montserrat => GoogleFonts.montserratTextTheme(),
    };
  }

  static String? _fontFamilyName() {
    return switch (fontFamily) {
      AppFontFamily.pressStart2P => GoogleFonts.pressStart2p().fontFamily,
      AppFontFamily.montserrat => GoogleFonts.montserrat().fontFamily,
    };
  }
}
