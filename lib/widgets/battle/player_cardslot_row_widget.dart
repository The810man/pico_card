import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/services/battle_provider.dart';
import 'package:pico_card/widgets/hoverable_card_holder.dart';

class PlayerCardslotRowWidget extends ConsumerWidget {
  final BattleProvider battleProvider;
  const PlayerCardslotRowWidget({super.key, required this.battleProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
