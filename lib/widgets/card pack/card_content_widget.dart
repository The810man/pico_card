import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/screens/shop_screen.dart';
import 'package:pico_card/widgets/card_widget.dart';

class CardContentWidget extends HookConsumerWidget {
  final List<GameCard> cards;
  const CardContentWidget({super.key, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<List<GameCard>> tmpCards = useState(cards);
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: List.generate(tmpCards.value.length, growable: true, (
          int index,
        ) {
          final ValueNotifier<bool> showBack = useState(true);
          final controller = useAnimationController(
            duration: Duration(milliseconds: 500),
          );
          final curvedAnimation = CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut, // You can use any curve here
          );
          final Animation<Offset> slideAwayAnimation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset(1, 0), // slide down off screen by its width
          ).animate(curvedAnimation);
          return InkWell(
            onTap: () {
              if (!showBack.value) {
                controller.forward().then((val) {
                  tmpCards.value = [...tmpCards.value]..removeAt(index);
                  if (tmpCards.value.isEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ShopScreen()),
                    );
                  }
                });
              }

              if (showBack.value) showBack.value = false;
            },
            child: SlideTransition(
              position: slideAwayAnimation,
              child: Center(
                child: CardWidget(
                  card: tmpCards.value[index],
                  showBack: showBack,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
