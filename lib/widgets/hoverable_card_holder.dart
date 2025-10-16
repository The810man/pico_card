import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/battle_provider.dart';
import 'package:pico_card/widgets/cards/card_stats_widget.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';

class HoverableCardHolder extends HookConsumerWidget {
  final BattleProvider battleProvider;
  const HoverableCardHolder({super.key, required this.battleProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> isHovering = useState(false);
    final ValueNotifier<GameCard?> selectedCard = useState(null);
    final ValueNotifier<bool> showBack = useState(false);
    return DragTarget<GameCard>(
      onWillAcceptWithDetails: (data) => isHovering.value = true,
      onLeave: (data) => isHovering.value = false,
      onAcceptWithDetails: (data) {
        isHovering.value = false;
        selectedCard.value = data.data;
        battleProvider.usePlayerMana(data.data.cost);
      },
      builder:
          (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: 105,
                  child: selectedCard.value == null
                      ? Image.asset(
                          isHovering.value
                              ? "assets/UI/CardHoverFrame.gif"
                              : "assets/UI/CardHoverFrame.png",
                          filterQuality: FilterQuality.none,
                          fit: BoxFit.contain,
                        )
                      : CardWidget(
                          card: selectedCard.value!,
                          showBack: showBack,
                          showHealth: true,
                          showStats: true,
                        ),
                ),
                if (isHovering.value && selectedCard.value != null)
                  Center(
                    child: NesPulser(
                      child: NesIcon(
                        iconData: NesIcons.redo,
                        primaryColor: Colors.white,
                        size: Size(25, 25),
                      ),
                    ),
                  ),
              ],
            );
          },
    );
  }
}
