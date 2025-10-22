import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';
import 'package:pico_card/widgets/cards/card_stats_widget.dart';
import 'package:pico_card/widgets/cards/flip_card_widget.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:pico_card/services/providers/battle_provider.dart';

class CardContentWidget extends HookConsumerWidget {
  final GameCard card;
  final ValueNotifier<bool> showBack;
  final bool showStats;
  final bool canAfford;
  final bool showHealth;
  final bool isEnemy;
  final int stars;
  final VoidCallback? onAttack;

  const CardContentWidget({
    super.key,
    required this.card,
    required this.showBack,
    this.showStats = false,
    this.canAfford = false,
    this.showHealth = false,
    this.isEnemy = false,
    this.stars = 0,
    this.onAttack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Compute upgrade hint for library cards (hand) if they can upgrade a placed card.
    // Show on top-left with upgrade cost, colored red if not affordable.
    final battle = ref.watch(battleProvider);
    int? _upgradeCost;
    bool _showUpgrade = false;
    bool _affordUpgrade = false;

    // Heuristic: library cards render with showHealth == false and showStats == true
    if (!showHealth && showStats && !isEnemy) {
      String _baseId(String id) {
        final idx = id.indexOf('__');
        return idx == -1 ? id : id.substring(0, idx);
      }

      for (final placed in battle.cardPlacedListPlayer) {
        if (_baseId(placed.id) == _baseId(card.id)) {
          final currentStars = battle.starLevels[placed.id] ?? 0;
          if (currentStars < 5) {
            final cost = card.cost + currentStars + 1;
            if (_upgradeCost == null || cost < _upgradeCost!) {
              _upgradeCost = cost;
            }
          }
        }
      }
      if (_upgradeCost != null) {
        _showUpgrade = true;
        _affordUpgrade = battle.playerMana >= _upgradeCost!;
      }
    }

    return GestureDetector(
      onTap: (onAttack != null && !card.isTapped && !isEnemy)
          ? () {
              onAttack!();
            }
          : null,
      child: FlipCardWidget(
        showBack: showBack,
        front: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset("assets/UI/cardBacksideGame.png"),
            _buildFallbackImage(999.9),
            Center(child: Image.asset(card.gifPath)),
            Image.asset(_getCardColorImagePath(card.rarity)),
            // Upgrade hint for library cards (top-left)
            if (_showUpgrade)
              Positioned(
                top: 0,
                left: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upgrade,
                        size: 16,
                        color: _affordUpgrade ? Colors.white : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${_upgradeCost ?? ''}",
                        style: TextStyle(
                          color: _affordUpgrade ? Colors.white : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (showStats)
              CardStatsWidget(
                cost: card.cost,
                canAfford: canAfford,
                health: card.health,
                showHealth: showHealth,
                attack: card.attack,
                isEnemy: isEnemy,
                isTapped: card.isTapped,
                stars: stars,
              ),
            if (onAttack != null && !card.isTapped && !isEnemy)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: NesIcon(
                    iconData: NesIcons.thinArrowRight,
                    primaryColor: Colors.white,
                    size: Size(15, 15),
                  ),
                ),
              ),
          ],
        ),
        back: Image.asset("assets/UI/cardBacksideGame.png"),
      ),
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
