import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import '../models/player_model.dart';
import '../services/game_provider.dart';
import '../widgets/card_widget.dart';
import '../screens/pack_opening_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'PICO CARD SHOP',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Pixel.coin, color: Colors.yellow),
                    const SizedBox(width: 4),
                    Text(
                      '${gameProvider.player?.coins ?? 0}',
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
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            );
          }

          final packs = gameProvider.getAvailablePacks();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Card Packs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Card Packs
                ...packs.map(
                  (pack) => _buildPackCard(context, pack, gameProvider),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Preview Cards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Preview some available cards
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: gameProvider.availableCards.length,
                    itemBuilder: (context, index) {
                      final card = gameProvider.availableCards[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CardWidget(card: card, width: 100, height: 140),
                      );
                    },
                  ),
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
    GameProvider gameProvider,
  ) {
    final canAfford = (gameProvider.player?.coins ?? 0) >= pack.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pack icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.purple[700],
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pack.description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pack.cardCount} cards',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
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
                    const Icon(Pixel.coin, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${pack.cost}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: canAfford
                      ? () =>
                            _showPackOpeningDialog(context, pack, gameProvider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? Colors.green[700]
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'BUY',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
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
    GameProvider gameProvider,
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
              final newCards = await gameProvider.buyAndOpenCardPack(pack);

              if (newCards.isNotEmpty && context.mounted) {
                // Navigate to pack opening screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PackOpeningScreen(pack: pack, openedCards: newCards),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Open Pack'),
          ),
        ],
      ),
    );
  }
}
