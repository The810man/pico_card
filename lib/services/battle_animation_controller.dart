import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/widgets/battle/attack_animation_widget.dart';

class BattleAnimationController {
  static void showAttackAnimation({
    required BuildContext context,
    required GameCard attackingCard,
    GameCard? targetCard,
    required Offset startPosition,
    required Offset targetPosition,
    required BattleProvider battleProvider,
    bool isEnemyAttack = false,
    bool performDamage = true,
    bool targetDies = false,
    bool showDamageIndicator = true,
  }) {
    // Use root navigator and make it dismissible to avoid input lock if something goes wrong.
    // Also attach a timeout fallback to ensure the dialog cannot get stuck.
    final dialogFuture = showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            AttackAnimationWidget(
              attackingCard: attackingCard,
              targetCard: targetCard,
              startPosition: startPosition,
              targetPosition: targetPosition,
              isEnemyAttack: isEnemyAttack,
              onComplete: () {
                // Handle attack completion (optional)
                if (performDamage) {
                  if (targetCard != null) {
                    battleProvider.damageCard(attackingCard, targetCard);
                  } else {
                    battleProvider.playerAttackEnemy(attackingCard);
                  }
                }
                // Show damage indicator at the target position (optional)
                if (showDamageIndicator) {
                  BattleAnimationController.showDamageAnimation(
                    context: context,
                    position: targetPosition,
                    damage: attackingCard.attack,
                    // If it's an enemy attack, damage is to player (blue),
                    // otherwise damage is to enemy (red)
                    isEnemy: !isEnemyAttack,
                  );
                }
                // Exit attack mode after animation completes
                battleProvider.cancelAttackMode();
              },
            ),
          ],
        ),
      ),
    );

    // Fail-safe: if the dialog did not close for any reason, auto-close it after ~1.8s.
    dialogFuture.timeout(
      const Duration(milliseconds: 1800),
      onTimeout: () {
        if (context.mounted) {
          final nav = Navigator.of(context, rootNavigator: true);
          if (nav.canPop()) {
            nav.pop();
          }
        }
        return null;
      },
    );
  }

  static void showCardPlaceAnimation({
    required BuildContext context,
    required GameCard card,
    required Offset startPosition,
    required Offset targetPosition,
  }) {
    // Simple fade and slide animation for card placement
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: AnimatedPositioned(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          left: targetPosition.dx,
          top: targetPosition.dy,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: 1.0,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.add_circle, color: Colors.green, size: 40),
              ),
            ),
          ),
        ),
      ),
    );

    // Auto-close after animation
    Future.delayed(Duration(milliseconds: 500), () {
      if (context.mounted) {
        context.pop();
      }
    });
  }

  static void showDamageAnimation({
    required BuildContext context,
    required Offset position,
    required int damage,
    bool isEnemy = false,
  }) {
    // Smooth float-up fade using TweenAnimationBuilder
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, t, _) {
                  // t: 0 -> 1
                  final double dy = -30.0 * t; // move up
                  final double opacity = 1.0 - t; // fade out
                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: Text(
                        '-$damage',
                        style: TextStyle(
                          color: isEnemy ? Colors.red : Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    // Auto-close after animation
    Future.delayed(const Duration(milliseconds: 820), () {
      if (context.mounted) {
        context.pop();
      }
    });
  }

  static void showDeathAnimation({
    required BuildContext context,
    required Offset position,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Material(
        color: Colors.transparent,
        child: AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          left: position.dx - 20,
          top: position.dy - 20,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: 0.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.9),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Auto-close after animation
    Future.delayed(const Duration(milliseconds: 350), () {
      if (context.mounted) {
        context.pop();
      }
    });
  }
}
