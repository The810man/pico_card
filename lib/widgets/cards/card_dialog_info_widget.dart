import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';

class CardDialogInfoWidget extends ConsumerWidget {
  final GameCard card;
  const CardDialogInfoWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NesRunningTextLines(
      speed: 0.001,
      texts: [
        "Name: ${card.name}\n",
        "Health: ${card.health.toString()}\n",
        "Attack: ${card.attack.toString()} \n",
        "Cost: ${card.cost.toString()} \n",
        //"Abilitys: ${card.abilities} \n",
        "Description: ${card.description}\n",
        "Rarity: ${card.rarity.displayName}\n",
      ],
    );
  }
}
