import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/providers/battle_provider.dart';

class GameOverOverlayWidget extends ConsumerWidget {
  const GameOverOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);

    if (!battle.gameOver) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: AbsorbPointer(
        absorbing: true, // block interactions below game-over overlay
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: NesContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    battle.winner == 'player' ? 'Victory!' : 'Defeat!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    battle.winner == 'player'
                        ? 'You have defeated the enemy!'
                        : 'The enemy has defeated you!',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  NesButton.text(
                    type: NesButtonType.primary,
                    text: 'Return to Main Menu',
                    onPressed: () {
                      // Navigate back to main menu
                      if (context.mounted) {
                        context.pop(); // Pop the current dialog
                        context.goNamed('main_menu');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
