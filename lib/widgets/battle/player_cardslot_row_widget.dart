import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/hoverable_card_holder.dart';
import 'package:pico_card/models/card_model.dart';

class PlayerCardslotRowWidget extends ConsumerWidget {
  const PlayerCardslotRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);

    // Build a slot-based view: show exactly 3 positions (0..2).
    // Each position displays the card that is assigned to that slot (by id),
    // or an empty drop target for that specific slot.
    final List<GameCard?> slotCards = [null, null, null];

    // Try to position by stored mapping first; if missing, fill from left to right.
    final used = <int>{};
    for (final c in battle.cardPlacedListPlayer) {
      final idx = battle.playerSlotIndex[c.id];
      if (idx != null && idx >= 0 && idx <= 2 && slotCards[idx] == null) {
        slotCards[idx] = c;
        used.add(idx);
      }
    }
    // Assign any remaining cards without mapping to the next free slot(s)
    for (final c in battle.cardPlacedListPlayer) {
      if (slotCards.contains(c)) continue; // already placed via mapping
      final nextFree = [
        0,
        1,
        2,
      ].firstWhere((i) => slotCards[i] == null, orElse: () => -1);
      if (nextFree != -1) {
        slotCards[nextFree] = c;
      }
    }

    return Positioned(
      right: 0,
      left: 0,
      bottom: MediaQuery.of(context).size.height * 0.2,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            final cardAtSlot = slotCards[index];
            if (cardAtSlot != null) {
              return Stack(
                children: [
                  HoverableCardHolder(
                    initialCard: cardAtSlot,
                    slotIndex: index,
                  ),
                  if (battle.enemyAttacking &&
                      battle.enemyTargetCard?.id == cardAtSlot.id)
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
              // Empty slot: make it a target for precise placement into this slot
              return HoverableCardHolder(slotIndex: index);
            }
          }),
        ),
      ),
    );
  }
}
