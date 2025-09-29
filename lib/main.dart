import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/widgets/player_banner_widget.dart';
import 'package:pico_card/widgets/striped_bg_animator.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'screens/shop_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/deck_builder_screen.dart';
import 'widgets/pixel_theme.dart';

void main() {
  debugPrintBeginFrameBanner = false;
  debugPrintEndFrameBanner = false;
  runApp(riverpod.ProviderScope(child: const PicoCardApp()));
}

class PicoCardApp extends StatelessWidget {
  const PicoCardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider()..initialize(),
      child: MaterialApp(
        title: 'Pico Card TCG',
        theme: flutterNesTheme(),
        home: const LoaderScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({Key? key}) : super(key: key);

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainMenuScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Center(child: Image.asset("assets/images/loader/810_loader.gif")),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NesPulser(child: Text("Pico Card")),
            NesRunningText(
              text: "V0.0.1",
              speed: 0.3,
              textStyle: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [Text("810"), Icon(Pixel.coin)],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.yellow),
                  SizedBox(height: 16),
                  Text(
                    'Loading Pico Card...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  NesPixelRowLoadingIndicator(),
                ],
              ),
            );
          }

          return Stack(
            children: [
              NesContainer(
                padding: EdgeInsets.all(1),
                child: NesTabView(
                  initialTabIndex: 1,
                  tabs: [
                    NesTabItem(child: homeWidget(context), label: "Main menu"),
                    NesTabItem(child: Text("data"), label: "Settings"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget homeWidget(BuildContext context) {
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
                    borderColor: Colors.white,
                    padding: EdgeInsets.all(1),
                    child: Image.asset(
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      "assets/images/imagePlaceholderPixel.png",
                    ),
                  ),
                ),
                SizedBox(height: 30),

                PixelButton(
                  text: ' BATTLE',
                  type: NesButtonType.error,
                  icon: Pixel.zap,
                  color: PixelTheme.pixelRed,
                  width: 200,
                  height: 60,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BattleScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                PixelButton(
                  text: ' COLLECTION',
                  icon: Pixel.imagemultiple,
                  type: NesButtonType.success,
                  color: PixelTheme.pixelBlue,
                  width: 200,
                  height: 60,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectionScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                PixelButton(
                  text: ' DECK BUILDER',
                  icon: Pixel.editbox,
                  type: NesButtonType.primary,
                  color: PixelTheme.pixelPurple,
                  width: 200,
                  height: 60,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeckBuilderScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                PixelButton(
                  text: ' SHOP',
                  icon: Pixel.shoppingbag,
                  type: NesButtonType.warning,
                  color: PixelTheme.pixelGreen,
                  width: 200,
                  height: 60,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
