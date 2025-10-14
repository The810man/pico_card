import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/screens/battle_screen.dart';
import 'package:pico_card/screens/shop_screen.dart';
import 'package:pico_card/widgets/player_banner_widget.dart';
import 'package:pico_card/widgets/striped_bg_animator.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';

class HomeWidget extends ConsumerWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        InfiniteStripedBackground(),
        Container(
          padding: EdgeInsets.fromLTRB(15, 60, 15, 30),
          child: NesContainer(
            child: Column(
              children: [
                PlayerBannerWidget(
                  name: "Super Gamer 123",
                  money: 300,
                  width: double.infinity,
                  height: 80,
                ),
                SizedBox(height: 30),

                Expanded(
                  child: NesContainer(
                    backgroundColor: Color.fromARGB(255, 41, 41, 41),
                    width: double.infinity,
                    borderColor: Colors.white,
                    padding: EdgeInsets.only(top: 2),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox.expand(
                            child: CustomPaint(
                              painter: PixelPatternPainter(
                                rarity: CardRarity.none,
                                animationValue: 999,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          right: 8,
                          child: Text(">> > Base Plate < <<"),
                        ),
                        Positioned(
                          left: 8,
                          top: 28,
                          child: Text(
                            "next arena: Bunker of doom",
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 38,
                          child: Text(
                            "..    needs 15 Stars",
                            style: TextStyle(fontSize: 8),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(child: SizedBox.shrink()),
                            NesContainer(
                              backgroundColor: Color(0xFF1D2B53),
                              height: 130,
                              width: MediaQuery.of(context).size.width,
                              borderColor: Colors.white,
                              padding: EdgeInsets.all(8),
                              child: Stack(
                                children: [
                                  SizedBox.expand(
                                    child: CustomPaint(
                                      painter: PixelPatternPainter(
                                        rarity: CardRarity.common,
                                        animationValue: 300,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Image.asset(
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      "assets/arenaGifs/arena0.gif",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                NesButton(
                  type: NesButtonType.normal,
                  child: Row(children: [Text("Battle")]),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BattleScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                NesButton(
                  type: NesButtonType.primary,
                  child: Row(children: [Text("Deck Builder")]),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                NesButton(
                  type: NesButtonType.success,
                  child: Row(children: [Text("Shop")]),
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => ShopScreen())),
                ),
                const SizedBox(height: 16),

                NesButton(
                  type: NesButtonType.warning,
                  child: Row(children: [Text("Collection")]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
