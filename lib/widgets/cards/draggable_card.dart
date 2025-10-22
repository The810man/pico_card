import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/cards/card_stats_widget.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';

class DraggableCard extends HookConsumerWidget {
  final ValueNotifier<bool> showBack;
  final GameCard card;
  final BattleProvider battleProvider;
  final bool canAfford;
  const DraggableCard({
    super.key,
    required this.showBack,
    required this.card,
    required this.battleProvider,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return canAfford
        ? Draggable<GameCard>(
            // Data is the value this Draggable stores.
            data: card,
            onDragCompleted: () {
              battleProvider.removeCardFromLibary(card);
            },
            feedback: CardWidget(
              card: card,
              width: 100,
              height: 150,
              showBack: showBack,
              showStats: true,
              canAfford: true,
            ),
            childWhenDragging: SizedBox.shrink(),
            child: CardWidget(
              canAfford: canAfford,
              showStats: true,
              card: card,
              width: 100,
              height: 150,
              showBack: showBack,
            ),
          )
        : CardWidget(
            card: card,
            width: 100,
            height: 150,
            showBack: showBack,
            showStats: true,
            canAfford: canAfford,
          );
  }
}
