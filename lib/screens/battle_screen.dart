import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState, useEffect;
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/providers/game_provider.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/utils/enums/game_enums.dart';
import 'package:pico_card/utils/delay_tool.dart';
import 'package:pico_card/widgets/battle/background_widget.dart';
import 'package:pico_card/widgets/battle/game_pause_overlay_widget.dart';
import 'package:pico_card/widgets/battle/game_stat_widget.dart';
import 'package:pico_card/widgets/battle/pause_btn_widget.dart';
import 'package:pico_card/widgets/battle/player_cardslot_row_widget.dart';
import 'package:pico_card/widgets/battle/enemy_cardslot_row_widget.dart';
import 'package:pico_card/widgets/cards/draggable_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:pico_card/widgets/battle/game_over_overlay_widget.dart';
import 'package:pico_card/widgets/battle/enemy_attack_overlay_widget.dart';
import 'package:pico_card/services/battle_animation_controller.dart';
import 'package:pico_card/services/providers/card_position_provider.dart';

class BattleScreen extends HookConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<PauseState> pauseState = useState(PauseState.none);
    final showBack_0 = useState(true);
    final showBack_1 = useState(true);
    final showBack_2 = useState(true);
    final didCardGenerate = useState(false);
    final List<ValueNotifier<bool>> showBackList = [
      showBack_0,
      showBack_1,
      showBack_2,
    ];

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        for (ValueNotifier<bool> item in showBackList) {
          await ref.read(delayProvider).delay(Duration(seconds: 1));
          item.value = false;
        }
      });
      return null;
    }, []);

    // Gets the BattleProvider for actions
    final BattleState battle = ref.watch(battleProvider); // Reads BattleState
    final BattleProvider battleController = ref.watch(battleProvider.notifier);
    // We'll use the battle state directly instead of separate providers

    return riverpod.Consumer(
      builder: (context, ref, child) {
        final gameNotifier = ref.watch(gameProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!didCardGenerate.value) {
            battleController.generateLibary(gameNotifier);
            didCardGenerate.value = true;
          }
        });
        return NesContainer(
          padding: EdgeInsets.all(1),
          child: Stack(
            children: [
              BackgroundWidget(),

              Positioned(
                bottom: 12,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      battle.cardLibaryListPlayer.length > 3
                          ? 3
                          : battle.cardLibaryListPlayer.length,
                      (int index) => DraggableCard(
                        canAfford:
                            battle.playerMana >=
                                battle.cardLibaryListPlayer[index].cost &&
                            battle.turn == TurnType.player,
                        battleProvider: battleController,
                        showBack: showBackList.length > index
                            ? showBackList[index]
                            : useState(true),
                        card: battle.cardLibaryListPlayer[index],
                      ),
                    ),
                  ),
                ),
              ),
              PlayerCardslotRowWidget(),
              EnemyCardslotRowWidget(),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.44,
                right: 5,
                child: GameStatWidget(
                  mana: battle.enemyMana,
                  health: battle.enemyLife,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.54,
                right: 5,
                child: GameStatWidget(
                  mana: battle.playerMana,
                  health: battle.playerLife,
                ),
              ),

              ///everyting above is over the pause screen
              GamePauseOverlayWidget(
                turn: battle.turn,
                isAttacking: battle.attackMode,
              ),
              EnemyAttackOverlayWidget(),

              ///everything below is under the pause and cannot be touched when its not ur turn
              PauseBtnWidget(pauseState: pauseState),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 - 15,
                right: 0,
                child: battle.turn == TurnType.player
                    ? Column(
                        children: [
                          if (battle.attackMode)
                            NesButton.text(
                              type: NesButtonType.warning,
                              text: "Cancel Attack",
                              onPressed: () {
                                battleController.cancelAttackMode();
                              },
                            )
                          else
                            NesButton.text(
                              type: NesButtonType.success,
                              text: "end turn",
                              onPressed: () {
                                if (context.mounted) {
                                  battleController.endTurn(gameNotifier);
                                }
                              },
                            ),
                          if (battle.attackMode &&
                              battle.cardPlacedListEnemy.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: NesButton.text(
                                type: NesButtonType.primary,
                                text: "Attack Enemy",
                                onPressed: () {
                                  // Animate from the selected player's card to the enemy HUD,
                                  // then apply damage and exit attack mode.
                                  final attacking =
                                      battle.selectedAttackingCard;
                                  if (attacking == null) return;

                                  final size = MediaQuery.of(context).size;
                                  final pos = ref.read(
                                    cardPositionProvider.notifier,
                                  );

                                  // Start position from the attacking card center (if tracked)
                                  final attackerCenter = pos.centerOf(
                                    attacking.id,
                                  );
                                  Offset startPos = attackerCenter != null
                                      ? attackerCenter - const Offset(50, 75)
                                      : Offset(
                                          size.width * 0.5,
                                          size.height * 0.68,
                                        );

                                  // Target: approximate enemy HUD (where enemy stats are drawn)
                                  // GameStatWidget for enemy is near height * 0.44, right side.
                                  final Offset targetPos = Offset(
                                    size.width * 0.85,
                                    size.height * 0.44,
                                  );

                                  if (context.mounted) {
                                    BattleAnimationController.showAttackAnimation(
                                      context: context,
                                      attackingCard: attacking,
                                      targetCard: null,
                                      startPosition: startPos,
                                      targetPosition: targetPos,
                                      battleProvider: battleController,
                                      performDamage: true,
                                      showDamageIndicator: true,
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      )
                    : NesButton.text(
                        type: NesButtonType.error,
                        text: "enemy turn",
                      ),
              ),
              GameOverOverlayWidget(),
            ],
          ),
        );
      },
    );
  }
}
