import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';

class CardStatsWidget extends ConsumerWidget {
  final int cost;
  final bool canAfford;
  final bool showHealth;
  final int health;
  final int attack;
  final bool isEnemy;
  final bool isTapped;
  final int stars;

  const CardStatsWidget({
    super.key,
    required this.cost,
    required this.canAfford,
    this.health = 1,
    this.showHealth = false,
    this.attack = 0,
    this.isEnemy = false,
    this.isTapped = false,
    this.stars = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cost icon (top right)
          if (!showHealth)
            Positioned(
              top: -10,
              right: -5,
              child: NesIcon(
                size: Size(35, 35),
                iconData: NesIcons.gem,
                primaryColor: PixelTheme.pixelBlue,
                secondaryColor: PixelTheme.pixelBlack,
              ),
            ),
          // Cost text
          if (!showHealth)
            Positioned(
              top: -5,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text(
                  "$cost",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ),
          // Health icon (bottom right)
          if (showHealth)
            Positioned(
              bottom: -10,
              right: -5,
              child: NesIcon(
                size: Size(35, 35),
                iconData: NesIcons.heart,
                primaryColor: PixelTheme.pixelRed,
                secondaryColor: PixelTheme.pixelPurple,
              ),
            ),
          // Health text
          if (showHealth)
            Positioned(
              bottom: -5,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text(
                  "$health",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Attack icon (bottom left)
          if (showHealth)
            Positioned(
              bottom: -10,
              left: -5,
              child: NesIcon(
                size: Size(35, 35),
                iconData: NesIcons.sword,
                primaryColor: PixelTheme.pixelYellow,
                secondaryColor: PixelTheme.pixelBlack,
              ),
            ),
          // Attack text
          if (showHealth)
            Positioned(
              bottom: -5,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text(
                  "$attack",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Stars row (top center) - show only for placed cards with stars > 0
          if (showHealth && stars > 0)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  stars.clamp(0, 5),
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amberAccent,
                    ),
                  ),
                ),
              ),
            ),
          // Tapped indicator - only show for placed cards
          if (isTapped && showHealth)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(Icons.close, color: Colors.red, size: 30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
