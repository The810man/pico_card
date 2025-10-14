import 'package:flutter/material.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/widgets/pixel_theme.dart';

class PixelPatternPainter extends CustomPainter {
  final CardRarity rarity;
  final double animationValue;

  PixelPatternPainter({required this.rarity, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getRarityColor(
        rarity,
      ).withAlpha((0.1 + (animationValue * 0.2)).toInt())
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    // Create pixel pattern
    const pixelSize = 4.0;
    for (double x = 0; x < size.width; x += pixelSize * 2) {
      for (double y = 0; y < size.height; y += pixelSize * 2) {
        if ((x + y) % (pixelSize * 4) == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PixelPatternPainter &&
        oldDelegate.animationValue != animationValue;
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return PixelTheme.commonColor;
      case CardRarity.rare:
        return PixelTheme.rareColor;
      case CardRarity.epic:
        return PixelTheme.epicColor;
      case CardRarity.legendary:
        return PixelTheme.legendaryColor;
      case CardRarity.broken:
        return PixelTheme.brokenColor;
      default:
        return Colors.black;
    }
  }
}
