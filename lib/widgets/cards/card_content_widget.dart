import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';
import 'package:pico_card/widgets/cards/card_stats_widget.dart';
import 'package:pico_card/widgets/cards/flip_card_widget.dart';
import 'package:pixelarticons/pixel.dart';

class CardContentWidget extends HookConsumerWidget {
  final GameCard card;
  final ValueNotifier<bool> showBack;
  final bool showStats;
  final bool canAfford;
  final bool showHealth;
  const CardContentWidget({
    super.key,
    required this.card,
    required this.showBack,
    this.showStats = false,
    this.canAfford = false,
    this.showHealth = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlipCardWidget(
      showBack: showBack,
      front: Stack(
        children: [
          Image.asset("assets/UI/cardBacksideGame.png"),
          _buildFallbackImage(999.9),
          Center(child: Image.asset(card.gifPath)),
          Image.asset(_getCardColorImagePath(card.rarity)),
          if (showStats)
            CardStatsWidget(
              cost: card.cost,
              canAfford: canAfford,
              health: card.health,
              showHealth: showHealth,
            ),
        ],
      ),
      back: Image.asset("assets/UI/cardBacksideGame.png"),
    );
  }

  Widget _buildFallbackImage(glowAnimation) {
    return Stack(
      children: [
        _buildPixelPattern(glowAnimation),
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              _getCardTypeIcon(card.type),
              size: 32,
              color: _getRarityColor(card.rarity),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCardTypeIcon(CardType type) {
    switch (type) {
      case CardType.creature:
        return Pixel.user;
      case CardType.spell:
        return Pixel.zap;
      case CardType.artifact:
        return Icons.diamond;
    }
  }

  Widget _buildPixelPattern(glowAnimation) {
    return Positioned.fill(
      child: CustomPaint(
        painter: PixelPatternPainter(
          rarity: card.rarity,
          animationValue: glowAnimation,
        ),
      ),
    );
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

  String _getCardColorImagePath(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return "assets/images/cardFrontCommon.png";
      case CardRarity.rare:
        return "assets/images/cardFrontRare.png";
      case CardRarity.epic:
        return "assets/images/cardFrontEpic.png";
      case CardRarity.legendary:
        return "assets/images/cardFrontLegendary.png";
      case CardRarity.broken:
        return "assets/images/cardFrontBroken.png";
      default:
        return "none";
    }
  }
}
