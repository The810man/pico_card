import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';

class GameStatWidget extends HookConsumerWidget {
  final int mana;
  final int health;
  const GameStatWidget({super.key, required this.mana, required this.health});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: NesContainer(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NesIcon(
              iconData: NesIcons.heart,
              primaryColor: PixelTheme.brokenColor,
              size: Size(15, 15),
            ),
            Divider(indent: 5),
            Text(health.toString()),
            Divider(indent: 10),
            NesIcon(
              iconData: NesIcons.gem,
              primaryColor: Colors.blue,
              secondaryColor: Colors.blueAccent,
              size: Size(15, 15),
            ),
            Divider(indent: 5),

            Text(mana.toString()),
          ],
        ),
      ),
    );
  }
}
