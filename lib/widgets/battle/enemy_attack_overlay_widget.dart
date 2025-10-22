import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/services/battle_animation_controller.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/services/providers/card_position_provider.dart';

class EnemyAttackOverlayWidget extends HookConsumerWidget {
  const EnemyAttackOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(battleProvider);
    final battleController = ref.watch(battleProvider.notifier);

    // Track last animation key to avoid re-triggering the same animation multiple times
    final lastAnimKey = useState<String?>(null);
    final hasPendingAnim = useState(false);

    useEffect(
      () {
        // Only trigger when enemyAttacking toggles to true and there's an attacking card
        if (battle.enemyAttacking &&
            battle.enemyAttackingCard != null &&
            !hasPendingAnim.value) {
          hasPendingAnim.value = true;

          final enemyCard = battle.enemyAttackingCard!;
          final targetCard = battle.enemyTargetCard;

          final String key = '${enemyCard.id}-${targetCard?.id ?? 'direct'}';
          if (lastAnimKey.value == key) {
            // Already shown this one
            hasPendingAnim.value = false;
            return null;
          }

          lastAnimKey.value = key;

          // Defer any access to inherited widgets (MediaQuery) to post-frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              hasPendingAnim.value = false;
              return;
            }

            // Prefer precise positions from tracked card rects; fallback to approximations
            final size = MediaQuery.of(context).size;
            final pos = ref.read(cardPositionProvider.notifier);

            Offset startPos;
            Offset targetPos;

            // Align a ~100x150 anim sprite centered within the recorded slot rect
            Offset alignInSlot(Rect r) =>
                r.topLeft + Offset((r.width - 100) / 2, (r.height - 150) / 2);

            // Start position: enemy attacking card
            final attackerRect = pos.rectOf(enemyCard.id);
            if (attackerRect != null) {
              startPos = alignInSlot(attackerRect);
            } else {
              // Fallback: approximate enemy row x by index, y by layout
              final int enemyIndex = battle.cardPlacedListEnemy.indexWhere(
                (c) => c.id == enemyCard.id,
              );
              final double ex = enemyIndex >= 0
                  ? (size.width / 4) * (enemyIndex + 1)
                  : size.width * 0.5;
              final double ey = size.height * 0.22;
              startPos = Offset(ex, ey);
            }

            // Target position: player card or direct to player HUD
            if (targetCard != null) {
              final targetRect = pos.rectOf(targetCard.id);
              if (targetRect != null) {
                targetPos = alignInSlot(targetRect);
              } else {
                final int playerIndex = battle.cardPlacedListPlayer.indexWhere(
                  (c) => c.id == targetCard.id,
                );
                final double px = playerIndex >= 0
                    ? (size.width / 4) * (playerIndex + 1)
                    : size.width * 0.5;
                final double py = size.height * 0.64;
                targetPos = Offset(px, py);
              }
            } else {
              // Direct attack towards player's HUD area
              final double px = size.width * 0.5;
              final double py = size.height * 0.50;
              targetPos = Offset(px, py);
            }

            // Show enemy attack animation; damage already applied in provider
            BattleAnimationController.showAttackAnimation(
              context: context,
              attackingCard: enemyCard,
              targetCard: targetCard,
              startPosition: startPos,
              targetPosition: targetPos,
              battleProvider: battleController,
              isEnemyAttack: true,
              performDamage: false,
              showDamageIndicator: true,
            );

            hasPendingAnim.value = false;
          });
        }

        return null;
      },
      [
        battle.enemyAttacking,
        battle.enemyAttackingCard?.id,
        battle.enemyTargetCard?.id,
      ],
    );

    // This widget only orchestrates animations; it renders nothing itself.
    return const SizedBox.shrink();
  }
}
