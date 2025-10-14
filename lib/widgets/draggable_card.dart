import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/game_provider.dart';
import 'package:pico_card/widgets/card_widget.dart';

class DraggableCard extends HookConsumerWidget {
  final ValueNotifier<bool> showBack;
  const DraggableCard({super.key, required this.showBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = GameCard(
      id: "0",
      name: "name",
      description: "description",
      cost: 0,
      attack: 0,
      health: 0,
      rarity: CardRarity.common,
      type: CardType.creature,
      imagePlaceholder: "imagePlaceholder",
      gifPath: "gifPath",
    );
    return Draggable<int>(
      // Data is the value this Draggable stores.
      data: 10,

      feedback: Text("dragging"),
      child: CardWidget(
        card: card,
        width: 105,
        height: 170,
        showBack: showBack,
      ),
    );
  }
}
