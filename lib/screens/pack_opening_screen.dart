import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show WidgetRef, HookConsumerWidget;
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/game_provider.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';
import 'package:pico_card/widgets/card%20pack/card_content_widget.dart';
import 'package:pico_card/widgets/card%20pack/card_pack_widget.dart';
import 'package:pico_card/utils/consts/pixel_theme.dart';
import 'package:pico_card/widgets/striped_bg_animator.dart';
import 'package:provider/provider.dart' show Consumer;

class PackOpeningScreen extends HookConsumerWidget {
  final List<GameCard> openedCards;
  const PackOpeningScreen({super.key, required this.openedCards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;
    final ValueNotifier<double> sliderValue = useState(0);
    final ValueNotifier<bool> isOpened = useState(false);
    final controller = useAnimationController(
      duration: Duration(milliseconds: 1000),
    );
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut, // You can use any curve here
    );
    final Animation<Offset> slideDownAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1), // slide down off screen by its height
    ).animate(curvedAnimation);
    final Animation<Offset> slideUpAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -10), // slide down off screen by its height
    ).animate(curvedAnimation);

    useEffect(() {
      if (isOpened.value) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [isOpened.value]);
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(child: NesPixelRowLoadingIndicator());
        }

        return Container(
          width: 500,
          height: 600,
          color: PixelTheme.pixelBlack,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CustomPaint(
                  painter: PixelPatternPainter(
                    rarity: CardRarity.none,
                    animationValue: 999,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height * 0.2,
                child: SlideTransition(
                  position: slideUpAnimation,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height * 0.2,
                    child: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [NesRunningText(text: "RIP THE PACK OPEN!")],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        PixelTheme.pixelBlack,
                        PixelTheme.pixelWhite.withAlpha(100),
                        PixelTheme.pixelRed.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ),
              if (isOpened.value)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height * 0.3,
                    child: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NesPulser(child: NesRunningText(text: "TAP!!!")),
                        ],
                      ),
                    ),
                  ),
                ),
              if (isOpened.value)
                Center(child: CardContentWidget(cards: openedCards)),
              SlideTransition(
                position: slideDownAnimation,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: maxWidth * 0.2,
                    right: maxWidth * 0.2,
                  ),
                  child: Center(
                    child: NesPulser(
                      curve: Curves.easeInBack,
                      interval: Duration(milliseconds: 900),
                      duration: Duration(milliseconds: 800),
                      child: CardPackWidget(
                        sliderValue: sliderValue,
                        isOpened: isOpened,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
