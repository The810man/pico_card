import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/utils/painters/stich_painter.dart';

class CardPackSlider extends HookConsumerWidget {
  final ValueNotifier<double> sliderValue;
  final ValueNotifier<bool> isOpened;
  const CardPackSlider({
    super.key,
    required this.sliderValue,
    required this.isOpened,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SizedBox(
          height: 50,
          child: CustomPaint(
            painter: StitchesPainter(sliderValue.value),
            willChange: true,
            size: Size.fromWidth(MediaQuery.of(context).size.width),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Slider(
            min: 0,
            max: 1,
            value: sliderValue.value,
            onChanged: (val) {
              sliderValue.value = val;
              if (val >= 1.0) isOpened.value = true;
            },
            thumbColor: const Color.fromARGB(120, 0, 26, 255),
            activeColor: const Color.fromARGB(144, 255, 255, 255),
            inactiveColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
