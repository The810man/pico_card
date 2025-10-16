import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';

class BackgroundWidget extends ConsumerWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NesContainer(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(4),
      child: Image.asset(
        "assets/UI/BattleScreenBackground.png",
        filterQuality: FilterQuality.none,
        fit: BoxFit.cover,
      ),
    );
  }
}
