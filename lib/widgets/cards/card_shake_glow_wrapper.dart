import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// PROVIDER DEFINITION EXAMPLE

class ShakeGlowCard extends HookConsumerWidget {
  final Widget child;
  final ValueNotifier<bool> provider;
  final Color color;
  final int power;

  const ShakeGlowCard({
    super.key,
    required this.child,
    required this.provider,
    required this.color,
    this.power = 1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trigger = provider.value;

    // Animation controllers
    final shakeController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final glowController = useAnimationController(
      duration: const Duration(milliseconds: 250),
      initialValue: 0.0,
    );

    // Animations
    final shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );
    final glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeOut));

    // React to trigger changes
    useEffect(() {
      if (trigger) {
        shakeController.forward(from: 0);
        glowController.forward();
      } else {
        glowController.reverse();
      }
      return null;
    }, [trigger]);

    return AnimatedBuilder(
      animation: Listenable.merge([shakeController, glowController]),
      builder: (context, childWidget) {
        double progress = shakeAnimation.value;
        double offset = sin(progress * pi * 4) * (1 - progress) * 8;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(glowAnimation.value * 0.7),
                  blurRadius: (18 * power) * glowAnimation.value + 2,
                  spreadRadius: (2 * power) * glowAnimation.value,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
