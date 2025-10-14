import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/main.dart';
import 'package:pico_card/utils/consts/game_enums.dart';
import 'package:pico_card/utils/delay_tool.dart';
import 'package:pico_card/widgets/draggable_card.dart';
import 'package:pico_card/widgets/hoverable_card_holder.dart';

class BattleScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<PauseState> pauseState = useState(PauseState.none);
    final showBack_0 = useState(true);
    final showBack_1 = useState(true);
    final showBack_2 = useState(true);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(delayProvider).delay(Duration(seconds: 1));
        showBack_0.value = false;
        await ref.read(delayProvider).delay(Duration(milliseconds: 500));
        showBack_1.value = false;
        await ref.read(delayProvider).delay(Duration(milliseconds: 500));
        showBack_2.value = false;
      });
      return null;
    }, []);
    return NesContainer(
      padding: EdgeInsets.all(1),
      child: Stack(
        children: [
          NesContainer(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(4),
            child: Image.asset(
              "assets/UI/BattleScreenBackground.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DraggableCard(showBack: showBack_0),
                  DraggableCard(showBack: showBack_1),
                  DraggableCard(showBack: showBack_2),
                ],
              ),
            ),
          ),

          Positioned(
            right: 0,
            left: 0,
            bottom: MediaQuery.of(context).size.height * 0.2,
            child: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HoverableCardHolder(),
                  HoverableCardHolder(),
                  HoverableCardHolder(),
                ],
              ),
            ),
          ),
          if (pauseState.value != PauseState.none &&
              pauseState.value != PauseState.gamePause)
            Positioned(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(4),
                child: Image.asset(
                  pauseState.value == PauseState.enemyPause
                      ? "assets/UI/BattleUiEnemyPause.png"
                      : "assets/UI/BattleUiplayerPause.png",
                  filterQuality: FilterQuality.none,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 30,
            child: NesButton.icon(
              type: NesButtonType.warning,
              icon: pauseState.value != PauseState.gamePause
                  ? NesIcons.pause
                  : NesIcons.play,
              onPressed: () {
                pauseState.value = PauseState.gamePause;
                NesDialog.show(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 150,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("paused game"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NesButton(
                                type: NesButtonType.success,
                                child: Text("End Battle"),
                                onPressed: () =>
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => MainMenuScreen(),
                                      ),
                                      (route) => false,
                                    ),
                              ),

                              NesButton(
                                type: NesButtonType.normal,
                                child: Text("continue"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ).then((_) {
                  pauseState.value = PauseState.none;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
