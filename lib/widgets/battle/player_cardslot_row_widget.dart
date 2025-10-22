import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/hoverable_card_holder.dart';

class PlayerCardslotRowWidget extends ConsumerWidget {
  const PlayerCardslotRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);

    return Positioned(
      right: 0,
      left: 0,
      bottom: MediaQuery.of(context).size.height * 0.2,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            if (index < battle.cardPlacedListPlayer.length) {
              return Stack(
                children: [
                  HoverableCardHolder(
                    initialCard: battle.cardPlacedListPlayer[index],
                  ),
                  if (battle.enemyAttacking &&
                      battle.enemyTargetCard?.id ==
                          battle.cardPlacedListPlayer[index].id)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return HoverableCardHolder();
            }
          }),
        ),
      ),
    );
  }
}
