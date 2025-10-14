import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FlipCardWidget extends HookConsumerWidget {
  final Widget front;
  final Widget back;
  final ValueNotifier<bool> showBack;

  const FlipCardWidget({
    super.key,
    required this.front,
    required this.back,
    required this.showBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    useEffect(() {
      void listener() {
        if (showBack.value) {
          controller.forward();
        } else {
          controller.reverse();
        }
      }

      showBack.addListener(listener);
      // Trigger once on mount
      listener();

      return () => showBack.removeListener(listener);
    }, [showBack]);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final isUnder = animation.value > 0.5;
        final angle = animation.value * pi;
        Widget displayChild;
        if (isUnder) {
          displayChild = back;
        } else {
          displayChild = front;
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isUnder
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: displayChild,
                )
              : displayChild,
        );
      },
    );
  }
}
