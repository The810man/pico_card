import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/widgets/card%20pack/card_pack_slider.dart';
import 'package:pico_card/widgets/card%20pack/pack_rip_widget.dart';

class CardPackWidget extends HookConsumerWidget {
  final ValueNotifier<double> sliderValue;
  final ValueNotifier<bool> isOpened;
  const CardPackWidget({
    super.key,
    required this.sliderValue,
    required this.isOpened,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 300, // should match image width for visibility
        child: Stack(
          children: [
            PackRipWidget(progress: sliderValue.value),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CardPackSlider(
                sliderValue: sliderValue,
                isOpened: isOpened,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
