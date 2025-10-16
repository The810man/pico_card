import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/utils/enums/game_enums.dart';

class GamePauseOverlayWidget extends HookConsumerWidget {
  final TurnType turn;
  const GamePauseOverlayWidget({super.key, required this.turn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (turn) {
      case TurnType.enemy:
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(4),
          child: Image.asset(
            "assets/UI/BattleUiplayerPause.png",
            filterQuality: FilterQuality.none,
            fit: BoxFit.cover,
          ),
        );
      case TurnType.player:
        return IgnorePointer(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(4),
            child: Image.asset(
              "assets/UI/BattleUiEnemyPause.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.cover,
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }
}
