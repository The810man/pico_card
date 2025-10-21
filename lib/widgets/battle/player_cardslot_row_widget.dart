import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/battle_deck_providers.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/hoverable_card_holder.dart';

class PlayerCardslotRowWidget extends ConsumerWidget {
  final BattleProvider battleProvider;
  const PlayerCardslotRowWidget({super.key, required this.battleProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<GameCard> enemyDeck = ref.watch(enemyGameCardListProvider);
    final List<GameCard> playerDeck = ref.watch(playerGameCardListProvider);
    return Positioned(
      right: 0,
      left: 0,
      bottom: MediaQuery.of(context).size.height * 0.2,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            HoverableCardHolder(battleProvider: battleProvider),
            HoverableCardHolder(battleProvider: battleProvider),
            HoverableCardHolder(battleProvider: battleProvider),
          ],
        ),
      ),
    );
  }
}
