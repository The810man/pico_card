import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState, useEffect;
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/battle_provider.dart';
import 'package:pico_card/services/game_provider.dart';
import 'package:pico_card/utils/enums/game_enums.dart';
import 'package:pico_card/utils/delay_tool.dart';
import 'package:pico_card/widgets/battle/background_widget.dart';
import 'package:pico_card/widgets/battle/game_pause_overlay_widget.dart';
import 'package:pico_card/widgets/battle/game_stat_widget.dart';
import 'package:pico_card/widgets/battle/pause_btn_widget.dart';
import 'package:pico_card/widgets/battle/player_cardslot_row_widget.dart';
import 'package:pico_card/widgets/cards/draggable_card.dart';
import 'package:provider/provider.dart' show Consumer;

class BattleScreen extends HookConsumerWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<PauseState> pauseState = useState(PauseState.none);
    final showBack_0 = useState(true);
    final showBack_1 = useState(true);
    final showBack_2 = useState(true);
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
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          battleController.generateLibary(gameProvider);
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
                      battle.cardLibaryList.length,
                      (int index) => DraggableCard(
                        canAfford:
                            battle.playerMana >=
                            battle.cardLibaryList[index].cost,
                        battleProvider: battleController,
                        showBack: showBackList[index],
                        card: battle.cardLibaryList[index],
                      ),
                    ),
                  ),
                ),
              ),
              PlayerCardslotRowWidget(battleProvider: battleController),
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
              GamePauseOverlayWidget(turn: battle.turn),

              ///everything below is under the pause and cannot be touched when its not ur turn
              PauseBtnWidget(pauseState: pauseState),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 - 15,
                right: 0,
                child: battle.turn == TurnType.player
                    ? NesButton.text(
                        type: NesButtonType.success,
                        text: "end turn",
                        onPressed: () {
                          battleController.endTurn();
                        },
                      )
                    : NesButton.text(
                        type: NesButtonType.error,
                        text: "enemy turn",
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
