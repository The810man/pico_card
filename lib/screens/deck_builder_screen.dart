import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/game_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/pixel_theme.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({Key? key}) : super(key: key);

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  List<String> _workingDeck = [];
  final int _maxDeckSize = 30;

  @override
  void initState() {
    super.initState();
    // Initialize working deck with current player deck
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _workingDeck = List<String>.from(gameProvider.player?.deck ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelTheme.pixelBlack,
      appBar: AppBar(
        title: Text(
          'DECK BUILDER',
          style: PixelTheme.pixelTextBold(fontSize: 16),
        ),
        backgroundColor: PixelTheme.pixelGray,
        iconTheme: IconThemeData(color: PixelTheme.pixelWhite),
        actions: [
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${_workingDeck.length}/$_maxDeckSize',
                  style: PixelTheme.pixelText(
                    fontSize: 14,
                    color: _workingDeck.length == _maxDeckSize
                        ? PixelTheme.pixelGreen
                        : PixelTheme.pixelYellow,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: PixelTheme.pixelYellow),
            );
          }

          final collection = gameProvider.playerCollection;
          final workingDeckCards = gameProvider.availableCards
              .where((card) => _workingDeck.contains(card.id))
              .toList();

          return Column(
            children: [
              // Current Deck Section
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT DECK',
                      style: PixelTheme.pixelTextBold(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _workingDeck.isEmpty
                          ? Center(
                              child: Text(
                                'No cards in deck',
                                style: PixelTheme.pixelText(
                                  color: PixelTheme.commonColor,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: workingDeckCards.length,
                              itemBuilder: (context, index) {
                                final card = workingDeckCards[index];
                                final count = _workingDeck
                                    .where((id) => id == card.id)
                                    .length;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _removeCardFromDeck(card.id),
                                    child: Stack(
                                      children: [
                                        CardWidget(
                                          card: card,
                                          width: 80,
                                          height: 120,
                                        ),
                                        if (count > 1)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: PixelTheme.pixelBlue,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: PixelTheme.pixelWhite,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                '$count',
                                                style: PixelTheme.pixelTextBold(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 2, color: PixelTheme.pixelGray),

              // Collection Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLLECTION',
                        style: PixelTheme.pixelTextBold(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: collection.isEmpty
                            ? Center(
                                child: Text(
                                  'No cards in collection',
                                  style: PixelTheme.pixelText(
                                    color: PixelTheme.commonColor,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.7,
                                    ),
                                itemCount: collection.length,
                                itemBuilder: (context, index) {
                                  final card = collection[index];
                                  final inDeckCount = _workingDeck
                                      .where((id) => id == card.id)
                                      .length;
                                  final canAdd =
                                      inDeckCount < 3 &&
                                      _workingDeck.length < _maxDeckSize;

                                  return GestureDetector(
                                    onTap: canAdd
                                        ? () => _addCardToDeck(card.id)
                                        : null,
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: canAdd ? 1.0 : 0.5,
                                          child: CardWidget(
                                            card: card,
                                            width: 100,
                                            height: 140,
                                          ),
                                        ),
                                        if (inDeckCount > 0)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: PixelTheme.pixelGreen,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: PixelTheme.pixelWhite,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                '$inDeckCount',
                                                style: PixelTheme.pixelTextBold(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (!canAdd && inDeckCount < 3)
                                          Positioned(
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: PixelTheme.pixelRed
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'DECK FULL',
                                                style: PixelTheme.pixelText(
                                                  fontSize: 8,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PixelTheme.pixelGray,
          border: Border(
            top: BorderSide(color: PixelTheme.pixelWhite, width: 2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: PixelButton(
                text: 'RESET',
                onPressed: _resetDeck,
                color: PixelTheme.pixelRed,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PixelButton(
                text: 'SAVE DECK',
                onPressed: _workingDeck.isNotEmpty ? _saveDeck : null,
                color: PixelTheme.pixelGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCardToDeck(String cardId) {
    setState(() {
      if (_workingDeck.length < _maxDeckSize) {
        final currentCount = _workingDeck.where((id) => id == cardId).length;
        if (currentCount < 3) {
          _workingDeck.add(cardId);
        }
      }
    });
  }

  void _removeCardFromDeck(String cardId) {
    setState(() {
      _workingDeck.remove(cardId);
    });
  }

  void _resetDeck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PixelTheme.pixelGray,
        title: Text('Reset Deck?', style: PixelTheme.pixelTextBold()),
        content: Text(
          'This will remove all cards from your deck.',
          style: PixelTheme.pixelText(color: PixelTheme.commonColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: PixelTheme.pixelText()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _workingDeck.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PixelTheme.pixelRed,
            ),
            child: Text('Reset', style: PixelTheme.pixelText()),
          ),
        ],
      ),
    );
  }

  void _saveDeck() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.updateDeck(_workingDeck);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deck saved successfully!',
            style: PixelTheme.pixelText(),
          ),
          backgroundColor: PixelTheme.pixelGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
