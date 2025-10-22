import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/utils/enums/game_enums.dart';

class GamePauseOverlayWidget extends HookConsumerWidget {
  final TurnType turn;

  /// When true and it's the player's turn, the overlay will be hidden
  /// so the player can select targets without a visual blocker.
  final bool isAttacking;

  const GamePauseOverlayWidget({
    super.key,
    required this.turn,
    this.isAttacking = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide overlay while the player is in attack selection
    if (turn == TurnType.player && isAttacking) {
      return const SizedBox.shrink();
    }

    switch (turn) {
      case TurnType.enemy:
        // Make sure enemy pause overlay never blocks taps (ignore pointers)
        return IgnorePointer(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              "assets/UI/BattleUiplayerPause.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.cover,
            ),
          ),
        );
      case TurnType.player:
        // Keep visual but non-blocking overlay on player's turn
        return IgnorePointer(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              "assets/UI/BattleUiEnemyPause.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.cover,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
