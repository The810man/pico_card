import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PackRipWidget extends HookConsumerWidget {
  final double progress;
  const PackRipWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Image.asset(
          'assets/UI/packBottom.png',
          width: 300,
          height: 400,
          fit: BoxFit.contain,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Transform(
            alignment: Alignment.centerRight, // rotate around left edge
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(
                -progress * math.pi / 2,
              ), // rotate from 0 to -90 degrees around Y axis
            child: Image.asset(
              'assets/UI/packTop.png',
              width: 300,
              height: 400,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
