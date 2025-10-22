import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';
import 'package:pico_card/services/battle_animation_controller.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/providers/card_position_provider.dart';

class EnemyCardslotRowWidget extends ConsumerWidget {
  const EnemyCardslotRowWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);
    final battleController = ref.watch(battleProvider.notifier);
    final List<GameCard> enemyDeck = battle.cardPlacedListEnemy;

    // Safety check to prevent range errors
    final int maxIndex = enemyDeck.length > 3 ? 3 : enemyDeck.length;

    return Positioned(
      right: 0,
      left: 0,
      top: MediaQuery.of(context).size.height * 0.244,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            if (index < maxIndex) {
              return AnimatedContainer(
                key: ValueKey(enemyDeck[index].id),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 160,
                width: 105,
                child: Stack(
                  children: [
                    CardWidget(
                      card: enemyDeck[index],
                      showBack: ValueNotifier(
                        enemyDeck[index].isTapped,
                      ), // Show back if tapped
                      showHealth: true,
                      isPlaced: true,
                      // Show enemy health/attack indicators
                      showStats: true,
                      isEnemy: true,
                      stars: (battle.starLevels[enemyDeck[index].id] ?? 0),
                      onTap: (battle.attackMode && !enemyDeck[index].isTapped)
                          ? () {
                              final attacking = battle.selectedAttackingCard;
                              if (attacking == null) return;

                              // Compute if this hit is lethal for a death burst (optional)
                              final bool targetDies =
                                  attacking.attack >= enemyDeck[index].health;

                              // Use precise on-screen rects of attacker/target; fallback to approximations
                              final size = MediaQuery.of(context).size;
                              final pos = ref.read(
                                cardPositionProvider.notifier,
                              );
                              final targetRect = pos.rectOf(
                                enemyDeck[index].id,
                              );
                              final attackerRect = pos.rectOf(attacking.id);

                              Offset startPos;
                              Offset targetPos;

                              // Align a 100x150 anim sprite centered within the recorded slot rect
                              Offset alignInSlot(Rect r) =>
                                  r.topLeft +
                                  Offset(
                                    (r.width - 100) / 2,
                                    (r.height - 150) / 2,
                                  );

                              if (attackerRect != null) {
                                startPos = alignInSlot(attackerRect);
                              } else {
                                // Fallback to approximate attacker row position
                                final double x = size.width * 0.5;
                                final double y = size.height * 0.68;
                                startPos = Offset(x, y);
                              }

                              if (targetRect != null) {
                                targetPos = alignInSlot(targetRect);
                              } else {
                                // Fallback to approximate enemy slot position
                                final double x = (size.width / 4) * (index + 1);
                                final double y = size.height * 0.22;
                                targetPos = Offset(x, y);
                              }

                              // Run animation and perform damage; shows damage indicator
                              BattleAnimationController.showAttackAnimation(
                                context: context,
                                attackingCard: attacking,
                                targetCard: enemyDeck[index],
                                startPosition: startPos,
                                targetPosition: targetPos,
                                battleProvider: battleController,
                                performDamage: true,
                                targetDies: targetDies,
                                showDamageIndicator: true,
                              );

                              // Exit attack mode after scheduling the animation
                              battleController.cancelAttackMode();
                            }
                          : null,
                    ),
                    if (battle.attackMode && !enemyDeck[index].isTapped)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    if (battle.enemyAttacking &&
                        battle.enemyAttackingCard?.id == enemyDeck[index].id)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Container(
                height: 160,
                width: 105,

                child: Stack(
                  children: [
                    if (battle.attackMode)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
