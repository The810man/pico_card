import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:pico_card/widgets/rewarded_button.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:nes_ui/nes_ui.dart';
import '../models/player_model.dart';
import '../services/providers/game_provider.dart';
import '../widgets/cards/card_widget.dart';
import '../screens/pack_opening_screen.dart';
import '../widgets/shop/all_cards_dialog.dart';

class ShopScreen extends HookConsumerWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBack = useState(false);
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'PICO CARD SHOP',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          riverpod.Consumer(
            builder: (context, ref, child) {
              final gameNotifier = ref.watch(gameProvider);
              return Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Pixel.coin, color: Colors.yellow),
                    const SizedBox(width: 4),
                    Text(
                      '${gameNotifier.player?.coins ?? 0}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: riverpod.Consumer(
        builder: (context, ref, child) {
          final gameNotifier = ref.watch(gameProvider);
          if (gameNotifier.isLoading) {
            return const Center(child: NesPixelRowLoadingIndicator());
          }

          final packs = gameNotifier.getAvailablePacks();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NesContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        NesIcon(iconData: NesIcons.market),
                        SizedBox(width: 8),
                        Text(
                          'Available Card Packs',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Packs
                ...packs.map(
                  (pack) => _buildPackCard(context, pack, gameNotifier),
                ),

                const SizedBox(height: 16),
                NesContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(Pixel.coin, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Earn Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RewardedAdButton(),

                const SizedBox(height: 16),
                NesContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        NesIcon(iconData: NesIcons.gallery),
                        SizedBox(width: 8),
                        Text(
                          'Preview Cards',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Preview all available cards button
                NesButton(
                  type: NesButtonType.normal,
                  onPressed: () =>
                      _showAllCardsDialog(context, gameNotifier, showBack),
                  child: const Text('VIEW ALL CARDS'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackCard(
    BuildContext context,
    CardPack pack,
    GameProvider gameNotifier,
  ) {
    final canAfford = (gameNotifier.player?.coins ?? 0) >= pack.cost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NesContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Pack icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple[700],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Pixel.gift, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),

            // Pack info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pack.description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pack.cardCount} cards',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Price and buy button
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Pixel.coin, color: Colors.yellow, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${pack.cost}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                NesButton(
                  type: NesButtonType.primary,
                  onPressed: canAfford
                      ? () =>
                            _showPackOpeningDialog(context, pack, gameNotifier)
                      : null,
                  child: const Text('BUY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPackOpeningDialog(
    BuildContext context,
    CardPack pack,
    GameProvider gameNotifier,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Open ${pack.name}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will cost ${pack.cost} coins and give you ${pack.cardCount} random cards.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Buy the pack and get the opened cards
              final newCards = await gameNotifier.buyAndOpenCardPack(pack);

              if (newCards.isNotEmpty && context.mounted) {
                // Navigate to pack opening screen
                context.pushNamed('pack_opening', extra: newCards);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Open Pack'),
          ),
        ],
      ),
    );
  }

  void _showAllCardsDialog(
    BuildContext context,
    GameProvider gameNotifier,
    ValueNotifier<bool> showBack,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          AllCardsDialog(gameProvider: gameNotifier, showBack: showBack),
    );
  }
}
