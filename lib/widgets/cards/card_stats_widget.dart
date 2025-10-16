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
  const CardStatsWidget({
    super.key,
    required this.cost,
    required this.canAfford,
    this.health = 1,
    this.showHealth = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -10,
            right: -5,
            child: !showHealth
                ? NesIcon(
                    size: Size(35, 35),
                    iconData: NesIcons.gem,
                    primaryColor: PixelTheme.pixelBlue,
                    secondaryColor: PixelTheme.pixelBlack,
                  )
                : NesIcon(
                    size: Size(35, 35),
                    iconData: NesIcons.heart,
                    primaryColor: PixelTheme.pixelRed,
                    secondaryColor: PixelTheme.pixelPurple,
                  ),
          ),
          Positioned(
            top: -5,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4),
              child: !showHealth
                  ? Text(
                      "$cost",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: canAfford ? Colors.white : Colors.red,
                      ),
                    )
                  : Text(
                      "$health",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
