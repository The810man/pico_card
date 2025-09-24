import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../models/card_model.dart';
import 'pixel_theme.dart';

class CardWidget extends StatefulWidget {
  final GameCard card;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showDetails;

  const CardWidget({
    Key? key,
    required this.card,
    this.isSelected = false,
    this.onTap,
    this.width,
    this.height,
    this.showDetails = true,
  }) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Container(
                  width: widget.width ?? 120,
                  height: widget.height ?? 160,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cost indicator
                      Container(
                        height: 20,
                        color: _getRarityColor(widget.card.rarity),
                        child: Center(
                          child: Text(
                            '${widget.card.cost}',
                            style: PixelTheme.pixelTextBold(
                              color: PixelTheme.pixelWhite,
                              fontSize: 12,
                            ),
                          ),
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
                              if (widget.card.imagePlaceholder.isNotEmpty &&
                                  widget.card.gifPath.isNotEmpty)
                                Stack(
                                  children: [
                                    _buildPixelPattern(),
                                    Positioned.fill(
                                      child: ClipRRect(
                                        child: Image.asset(
                                          widget.card.gifPath,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return _buildFallbackImage();
                                              },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                _buildFallbackImage(),
                              // Rarity badge
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: PixelTheme.pixelContainer(
                                    color: _getRarityColor(widget.card.rarity),
                                    borderColor: PixelTheme.pixelWhite,
                                    borderWidth: 1,
                                  ),
                                  child: Text(
                                    widget.card.rarity.displayName.substring(
                                      0,
                                      1,
                                    ),
                                    style: PixelTheme.pixelTextBold(
                                      color: PixelTheme.pixelWhite,
                                      fontSize: 8,
                                    ),
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
                  getCardColorImagePath(widget.card.rarity),
                  filterQuality: FilterQuality.none,
                  scale: 0.25,
                ),
                if (widget.showDetails) ...[
                  // Card name
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: const Color.fromARGB(0, 10, 10, 10),
                      child: Text(
                        widget.card.name,
                        style: PixelTheme.pixelTextBold(
                          color: PixelTheme.pixelWhite,
                          fontSize: 6,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Stats
                ],
                if (widget.card.type == CardType.creature)
                  Positioned(
                    left: 5,
                    bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Attack
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),

                          child: Row(
                            children: [
                              Icon(Pixel.zap),
                              Text(
                                '${widget.card.attack}',
                                style: PixelTheme.pixelTextBold(
                                  color: const Color.fromARGB(255, 32, 32, 32),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Health
                      ],
                    ),
                  ),
                Positioned(
                  bottom: 15,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Pixel.heart),
                        Text(
                          '${widget.card.health}',
                          style: PixelTheme.pixelTextBold(
                            color: const Color.fromARGB(255, 27, 27, 27),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Stack(
      children: [
        // Pixel pattern background
        _buildPixelPattern(),
        // Card type icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: PixelTheme.pixelContainer(
              color: PixelTheme.pixelBlack.withOpacity(0.7),
              borderColor: _getRarityColor(widget.card.rarity),
              borderWidth: 1,
            ),
            child: Icon(
              _getCardTypeIcon(widget.card.type),
              size: 32,
              color: _getRarityColor(widget.card.rarity),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPixelPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PixelPatternPainter(
          rarity: widget.card.rarity,
          animationValue: _glowAnimation.value,
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

class PixelPatternPainter extends CustomPainter {
  final CardRarity rarity;
  final double animationValue;

  PixelPatternPainter({required this.rarity, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getRarityColor(
        rarity,
      ).withOpacity(0.1 + (animationValue * 0.2))
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
    }
  }
}
