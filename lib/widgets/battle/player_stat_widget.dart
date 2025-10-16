import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';

class PlayerStatWidget extends HookConsumerWidget {
  const PlayerStatWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NesContainer();
  }
}
