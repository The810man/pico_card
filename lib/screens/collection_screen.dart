import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/game_provider.dart';
import '../widgets/card_widget.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'COLLECTION',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.grey[900],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ALL CARDS'),
            Tab(text: 'MY DECK'),
          ],
          indicatorColor: Colors.yellow,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.grey[400],
        ),
        actions: [
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Pixel.imagemultiple, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${gameProvider.playerCollection.length}',
                      style: const TextStyle(
                        color: Colors.blue,
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
      body: TabBarView(
        controller: _tabController,
        children: [_buildCollectionTab(), _buildDeckTab()],
      ),
    );
  }

  Widget _buildCollectionTab() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.yellow),
          );
        }

        final collection = gameProvider.playerCollection;

        if (collection.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Pixel.imagemultiple, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No cards yet!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visit the shop to buy some card packs',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Group cards by rarity for better display
        final groupedCards = <CardRarity, List<GameCard>>{};
        for (final card in collection) {
          groupedCards.putIfAbsent(card.rarity, () => []).add(card);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collection stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: CardRarity.values.map((rarity) {
                    final count = groupedCards[rarity]?.length ?? 0;
                    return Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            color: _getRarityColor(rarity),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rarity.displayName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Cards by rarity
              ...CardRarity.values.map((rarity) {
                final cards = groupedCards[rarity] ?? [];
                if (cards.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rarity.displayName,
                      style: TextStyle(
                        color: _getRarityColor(rarity),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StaggeredGrid.count(
                      crossAxisCount: 3,
                      children: cards
                          .map(
                            (card) => _buildCollectionCard(card, gameProvider),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeckTab() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.yellow),
          );
        }

        final deck = gameProvider.playerDeck;
        final collection = gameProvider.playerCollection;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deck info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.style, color: Colors.yellow),
                    const SizedBox(width: 8),
                    Text(
                      'Current Deck: ${deck.length}/30 cards',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: deck.length >= 3
                          ? () => _showDeckBuilderDialog(context, gameProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                      child: const Text('Edit Deck'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (deck.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No deck built yet!',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                StaggeredGrid.count(
                  crossAxisCount: 3,
                  children: deck
                      .map(
                        (card) => CardWidget(
                          card: card,
                          onTap: () => _showCardDetails(context, card),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollectionCard(GameCard card, GameProvider gameProvider) {
    final isInDeck = gameProvider.playerDeck.any(
      (deckCard) => deckCard.id == card.id,
    );

    return CardWidget(
      card: card,
      onTap: () => _showCardDetails(context, card),
      isSelected: isInDeck,
    );
  }

  void _showCardDetails(BuildContext context, GameCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardWidget(card: card, width: 200, height: 280),
              const SizedBox(height: 16),
              Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                card.description,
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              if (card.abilities.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...card.abilities.map(
                  (ability) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      ability,
                      style: TextStyle(
                        color: Colors.yellow[300],
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeckBuilderDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Deck Builder',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deck builder feature coming soon! For now, your first 3 cards are automatically in your deck.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.rare:
        return Colors.blue;
      case CardRarity.epic:
        return Colors.purple;
      case CardRarity.legendary:
        return Colors.orange;
      case CardRarity.broken:
        return Colors.red;
    }
  }
}
