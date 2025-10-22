import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/main.dart';
import 'package:pico_card/utils/enums/game_enums.dart';

class PauseBtnWidget extends ConsumerWidget {
  final ValueNotifier pauseState;
  const PauseBtnWidget({super.key, required this.pauseState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
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
                          onPressed: () {
                            if (context.mounted) {
                              context.goNamed('main_menu');
                            }
                          },
                        ),

                        NesButton(
                          type: NesButtonType.normal,
                          child: Text("continue"),
                          onPressed: () => context.pop(),
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
    );
  }
}
