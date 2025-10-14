import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/widgets/home_widget.dart';

import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';

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
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Pico Card TCG',
        theme: nesTheme,
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
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.initialize(onStep: (_) {});

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainMenuScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
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
          child: Consumer<GameProvider>(
            builder: (context, game, _) {
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
        actions: [Text("810"), Icon(Pixel.coin)],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
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
                      NesTabItem(child: Text("data"), label: "Settings"),
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
