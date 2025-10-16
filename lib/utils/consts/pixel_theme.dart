import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';

class PixelTheme {
  // Pixel color palette
  static const Color pixelBlack = Color.fromARGB(255, 13, 43, 69);
  static const Color pixelGray = Color.fromARGB(255, 32, 60, 86);
  static const Color pixelLightGray = Color.fromARGB(255, 84, 78, 104);
  static const Color pixelWhite = Color(0xFFffecd6);
  static const Color pixelYellow = Color(0xFFffaa5e);
  static const Color pixelRed = Color.fromARGB(255, 252, 39, 121);
  static const Color pixelBlue = Color(0xFF4444FF);
  static const Color pixelGreen = Color(0xFF44FF44);
  static const Color pixelPurple = Color.fromARGB(255, 165, 95, 128);
  static const Color pixelOrange = Color(0xFFd08159);
  static const Color uiBoxBg = Color.fromARGB(255, 130, 118, 156);

  // Rarity colors
  static const Color commonColor = Color(0xFF888888);
  static const Color rareColor = Color(0xFF4488FF);
  static const Color epicColor = Color(0xFFAA44FF);
  static const Color legendaryColor = Color(0xFFFF8800);
  static const Color brokenColor = Color.fromARGB(255, 255, 0, 76);
}

final nesTheme = flutterNesTheme(
  primaryColor: PixelTheme.pixelBlack,

  brightness: Brightness.dark,
  nesButtonTheme: NesButtonTheme(
    normal: PixelTheme.pixelGray,
    primary: PixelTheme.pixelLightGray,
    success: PixelTheme.pixelPurple,
    warning: PixelTheme.pixelRed,
    error: PixelTheme.pixelOrange,
    lightLabelColor: PixelTheme.pixelWhite,
    darkLabelColor: PixelTheme.pixelWhite,
    lightIconTheme: NesIconTheme(
      primary: PixelTheme.pixelWhite,
      secondary: PixelTheme.pixelPurple,
      accent: PixelTheme.pixelRed,
      shadow: PixelTheme.pixelGray,
    ),
    darkIconTheme: NesIconTheme(
      primary: PixelTheme.pixelWhite,
      secondary: PixelTheme.pixelPurple,
      accent: PixelTheme.pixelRed,
      shadow: PixelTheme.pixelGray,
    ),
  ),
);
