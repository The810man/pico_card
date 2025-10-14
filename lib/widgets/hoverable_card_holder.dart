import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HoverableCardHolder extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> isHovering = useState(false);
    return DragTarget<int>(
      onWillAcceptWithDetails: (data) => isHovering.value = true,
      onLeave: (data) => isHovering.value = false,
      onAcceptWithDetails: (data) => isHovering.value = false,
      builder:
          (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: 115,
                  child: Image.asset(
                    isHovering.value
                        ? "assets/UI/CardHoverFrame.gif"
                        : "assets/UI/CardHoverFrame.png",
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          },
    );
  }
}
