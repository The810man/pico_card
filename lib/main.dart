import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  runApp(const PicoCardApp());
}

class PicoCardApp extends StatelessWidget {
  const PicoCardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider()..initialize(),
      child: MaterialApp(
        title: 'Pico Card TCG',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.black87,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
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
                ],
              ),
            );
          }

          return Stack(
            children: [
              InfiniteStripedBackground(isRed: true),
              InfiniteStripedBackground(),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                bottom: 0,
                left: MediaQuery.of(context).size.height * 0.03,
                right: MediaQuery.of(context).size.height * 0.03,
                child: Container(
                  child: Image.asset(
                    fit: BoxFit.fill,
                    "assets/images/main_frame_open.png",
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.transparent),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Game Title
                              Text(
                                'PICO CARD',
                                style: PixelTheme.pixelTextBold(
                                  color: PixelTheme.pixelYellow,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Trading Card Game',
                                style: PixelTheme.pixelText(
                                  color: PixelTheme.pixelLightGray,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              PlayerBannerWidget(
                                name: "Paul Gerümpel",
                                money: 5,
                                width: 300,
                                height: 100,
                              ),
                              // // Player info
                              // PixelCard(
                              //   backgroundColor: PixelTheme.pixelGray,
                              //   borderColor: PixelTheme.pixelLightGray,
                              //   child: Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       Icon(
                              //         Pixel.user,
                              //         color: PixelTheme.pixelBlue,
                              //       ),
                              //       const SizedBox(width: 8),
                              //       Text(
                              //         gameProvider.player?.name ?? 'Player',
                              //         style: PixelTheme.pixelTextBold(
                              //           color: PixelTheme.pixelWhite,
                              //           fontSize: 16,
                              //         ),
                              //       ),
                              //       const SizedBox(width: 16),
                              //       Icon(
                              //         Pixel.coin,
                              //         color: PixelTheme.pixelYellow,
                              //       ),
                              //       const SizedBox(width: 4),
                              //       Text(
                              //         '${gameProvider.player?.coins ?? 0}',
                              //         style: PixelTheme.pixelTextBold(
                              //           color: PixelTheme.pixelYellow,
                              //           fontSize: 16,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      // Menu buttons
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PixelButton(
                                text: 'BATTLE',
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
                                text: 'COLLECTION',
                                icon: Pixel.imagemultiple,
                                color: PixelTheme.pixelBlue,
                                width: 200,
                                height: 60,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CollectionScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              PixelButton(
                                text: 'DECK BUILDER',
                                icon: Pixel.editbox,
                                color: PixelTheme.pixelPurple,
                                width: 200,
                                height: 60,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DeckBuilderScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              PixelButton(
                                text: 'SHOP',
                                icon: Pixel.shoppingbag,
                                color: PixelTheme.pixelGreen,
                                width: 200,
                                height: 60,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'PIXEL TCG • LOW POLY STYLE',
                          style: PixelTheme.pixelText(
                            color: PixelTheme.pixelLightGray,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
