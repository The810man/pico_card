import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';
import 'package:pico_card/widgets/flip_card_widget.dart';
import 'package:pixelarticons/pixel.dart';
import '../models/card_model.dart';
import 'pixel_theme.dart';

class CardWidget extends HookConsumerWidget {
  final GameCard card;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showDetails;
  final ValueNotifier<bool> showBack;

  CardWidget({
    super.key,
    required this.card,
    required this.showBack,
    this.isSelected = false,
    this.onTap,
    this.width,
    this.height,
    this.showDetails = true,
  });

  String getCardColorImagePath(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return "assets/images/card_frame_common.png";
      case CardRarity.rare:
        return "assets/images/card_frame_rare.png";
      case CardRarity.epic:
        return "assets/images/card_frame_epic.png";
      case CardRarity.legendary:
        return "assets/images/card_frame_legendary.png";
      case CardRarity.broken:
        return "assets/images/card_frame_broken.png";
      default:
        return "none";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnimationController controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final scaleAnimation = useAnimation(_scaleAnimation);
    final glowAnimation = useAnimation(_glowAnimation);
    final ValueNotifier<bool> isHovered = useState(false);
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color.fromARGB(0, 112, 112, 112),
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTap,
          onTapDown: (_) {
            isHovered.value = false;
            controller.forward();
          },
          onTapUp: (_) {
            isHovered.value = false;
            controller.reverse();
          },
          onTapCancel: () {
            isHovered.value = false;
            controller.reverse();
          },
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,

                child: NesContainer(
                  borderColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  width: width ?? 120,
                  height: height ?? 160,
                  child: FlipCardWidget(
                    showBack: showBack,
                    front: !showBack.value
                        ? Padding(
                            padding: const EdgeInsets.all(0),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Cost indicator
                                      Container(
                                        height: 20,
                                        color: _getRarityColor(card.rarity),
                                        child: Center(
                                          child: Text('${card.cost}'),
                                        ),
                                      ),

                                      // Card image
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          color: PixelTheme.pixelGray,
                                          child: Stack(
                                            children: [
                                              // Image or fallback pattern
                                              if (card
                                                      .imagePlaceholder
                                                      .isNotEmpty &&
                                                  card.gifPath.isNotEmpty)
                                                Stack(
                                                  children: [
                                                    _buildPixelPattern(
                                                      glowAnimation,
                                                    ),
                                                    Positioned.fill(
                                                      child: ClipRRect(
                                                        child: Image.asset(
                                                          card.gifPath,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return _buildFallbackImage(
                                                                  glowAnimation,
                                                                );
                                                              },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                _buildFallbackImage(
                                                  glowAnimation,
                                                ),
                                              // Rarity badge
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),

                                                  child: Text(
                                                    card.rarity.displayName
                                                        .substring(0, 1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  getCardColorImagePath(card.rarity),
                                  filterQuality: FilterQuality.none,
                                  scale: 0.25,
                                ),
                                if (showDetails) ...[
                                  // Card name
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      color: const Color.fromARGB(
                                        0,
                                        10,
                                        10,
                                        10,
                                      ),
                                      child: Text(
                                        card.name,

                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  // Stats
                                ],

                                Positioned(
                                  bottom: 15,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),

                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Pixel.zap),
                                        Text("${card.attack}"),
                                        Icon(Pixel.heart),
                                        Text('${card.health}'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    back: Image.asset("assets/UI/cardBacksideGame.png"),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage(glowAnimation) {
    return Stack(
      children: [
        // Pixel pattern background
        _buildPixelPattern(glowAnimation),
        // Card type icon
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
}
