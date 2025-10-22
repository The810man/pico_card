import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/screens/shop_screen.dart';
import 'package:pico_card/services/audio_controller.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';
import 'package:pico_card/widgets/cards/card_shake_glow_wrapper.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';
import 'package:pico_card/widgets/home_widget.dart';

class CardContentWidget extends HookConsumerWidget {
  final List<GameCard> cards;
  const CardContentWidget({super.key, required this.cards});

  bool shouldGlow(GameCard card) {
    switch (card.rarity) {
      case CardRarity.broken:
        return true;
      case CardRarity.legendary:
        return true;
      case CardRarity.epic:
        return true;
      default:
        return false;
    }
  }

  Color getGlowColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.broken:
        return PixelTheme.brokenColor;
      case CardRarity.common:
        return PixelTheme.pixelLightGray;
      case CardRarity.epic:
        return PixelTheme.epicColor;
      case CardRarity.legendary:
        return PixelTheme.legendaryColor;
      case CardRarity.rare:
        return PixelTheme.pixelBlue;
      default:
        return PixelTheme.pixelBlack;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<List<GameCard>> tmpCards = useState(cards);
    final ValueNotifier<bool> shouldGlow = useState(false);
    final AudioRepository audio = AudioRepository();
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 150,
        width: 100,
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
            return ShakeGlowCard(
              color: getGlowColor(cards[index].rarity),
              provider: shouldGlow,
              child: InkWell(
                onTap: () {
                  shouldGlow.value = true;

                  if (!showBack.value) {
                    controller.forward().then((val) {
                      tmpCards.value = [...tmpCards.value]..removeAt(index);
                      if (tmpCards.value.isEmpty) {
                        context.pop();
                      }
                    });
                  }

                  if (showBack.value) showBack.value = false;
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: SlideTransition(
                    position: slideAwayAnimation,
                    child: Center(
                      child: CardWidget(
                        width: 100,
                        height: 150,
                        card: tmpCards.value[index],
                        showBack: showBack,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
