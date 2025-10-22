import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/screens/battle_screen.dart';
import 'package:pico_card/screens/collection_screen.dart';
import 'package:pico_card/screens/deck_builder_screen.dart';
import 'package:pico_card/screens/pack_opening_screen.dart';
import 'package:pico_card/screens/shop_screen.dart';
import 'package:pico_card/services/audio_controller.dart';
import 'package:pico_card/widgets/home_widget.dart';
import 'package:pico_card/screens/settings_screen.dart';

import 'package:pixelarticons/pixel.dart';
import 'services/providers/game_provider.dart';

import 'utils/consts/pixel_theme.dart';

void main() {
  debugPrintBeginFrameBanner = false;
  debugPrintEndFrameBanner = false;
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  final testDeviceIds = ['AF7F69CC6C308A0AF093E911B9EB3018'];
  final requestConfiguration = RequestConfiguration(
    testDeviceIds: testDeviceIds,
  );
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  runApp(riverpod.ProviderScope(child: const PicoCardApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'loader',
      builder: (context, state) => const LoaderScreen(),
    ),
    GoRoute(
      path: '/main_menu',
      name: 'main_menu',
      builder: (context, state) => const MainMenuScreen(),
      routes: [
        GoRoute(
          path: 'shop',
          name: 'shop',
          builder: (context, state) => const ShopScreen(),
          routes: [
            GoRoute(
              path: 'pack_opening',
              name: 'pack_opening',
              builder: (context, state) =>
                  PackOpeningScreen(openedCards: state.extra as List<GameCard>),
            ),
          ],
        ),
        GoRoute(
          path: 'battle',
          name: 'battle',
          builder: (context, state) => const BattleScreen(),
        ),
        GoRoute(
          path: 'deck_builder',
          name: 'deck_builder',
          builder: (context, state) => const DeckBuilderScreen(),
        ),
        GoRoute(
          path: 'collection',
          name: 'collection',
          builder: (context, state) => const CollectionScreen(),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class PicoCardApp extends riverpod.ConsumerWidget {
  const PicoCardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pico Card TCG',
      theme: nesTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoaderScreen extends riverpod.ConsumerStatefulWidget {
  const LoaderScreen({Key? key}) : super(key: key);

  @override
  riverpod.ConsumerState<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends riverpod.ConsumerState<LoaderScreen> {
  bool showTerminal = false;
  @override
  void initState() {
    super.initState();
    // Phase 1: show 810 loader gif
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      setState(() {
        showTerminal = true;
      });

      // Phase 2: NES terminal boot with progress
      final gameNotifier = ref.read(gameProvider);
      await gameNotifier.initialize(onStep: (_) {});

      if (!mounted) return;
      context.goNamed('main_menu');
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!showTerminal) {
      return Material(
        color: Colors.black,
        child: Center(
          child: Image.asset("assets/images/loader/810_loader.gif"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: riverpod.Consumer(
            builder: (context, ref, child) {
              final game = ref.watch(gameProvider);
              return NesContainer(
                backgroundColor: Colors.black,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NesIcon(iconData: NesIcons.tv),
                        const SizedBox(width: 8),
                        const Text(
                          'PICO-BOOT v0.1',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const NesPixelRowLoadingIndicator(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: game.bootLogs.length,
                          itemBuilder: (context, index) {
                            final line = game.bootLogs[index];
                            return Text(
                              line,
                              style: const TextStyle(
                                fontFamily: 'SuperPixel',
                                fontSize: 12,
                                color: Colors.greenAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    AudioRepository();
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NesPulser(child: Text("Pico Card")),
            Text(
              "V0.0.1",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(children: [Text("810"), Icon(Pixel.coin)]),
              Row(children: [Text("70"), Icon(Pixel.trophy)]),
            ],
          ),
        ],
      ),
      body: riverpod.Consumer(
        builder: (context, ref, child) {
          final gameNotifier = ref.watch(gameProvider);
          if (gameNotifier.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NesPixelRowLoadingIndicator(),
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
              NesContainer(
                padding: EdgeInsets.all(1),
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: NesTabView(
                    initialTabIndex: 0,
                    tabs: [
                      NesTabItem(child: HomeWidget(), label: "Main menu"),
                      NesTabItem(child: SettingsScreen(), label: "Settings"),
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
