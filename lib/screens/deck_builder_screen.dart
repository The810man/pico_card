import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show useState;
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Consumer, Provider;
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/game_provider.dart';
import '../widgets/cards/card_widget.dart';
import '../utils/consts/pixel_theme.dart';

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
    return HookConsumer(
      builder: (context, ref, child) {
        final showBack = useState(false);
        return Scaffold(
          backgroundColor: PixelTheme.pixelBlack,
          appBar: AppBar(
            title: Text('DECK BUILDER'),
            backgroundColor: PixelTheme.pixelGray,
            iconTheme: IconThemeData(color: PixelTheme.pixelWhite),
            actions: [
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    child: Text('${_workingDeck.length}/$_maxDeckSize'),
                  );
                },
              ),
            ],
          ),
          body: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              if (gameProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: PixelTheme.pixelYellow,
                  ),
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
                        Text('CURRENT DECK'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _workingDeck.isEmpty
                              ? Center(child: Text('No cards in deck'))
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
                                        onTap: () =>
                                            _removeCardFromDeck(card.id),
                                        child: Stack(
                                          children: [
                                            CardWidget(
                                              showBack: showBack,
                                              card: card,
                                              width: 80,
                                              height: 120,
                                            ),
                                            if (count > 1)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: PixelTheme.pixelBlue,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          PixelTheme.pixelWhite,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text('$count'),
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
                          Text('COLLECTION'),
                          const SizedBox(height: 8),
                          Expanded(
                            child: collection.isEmpty
                                ? Center(child: Text('No cards in collection'))
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
                                                showBack: showBack,
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
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        PixelTheme.pixelGreen,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          PixelTheme.pixelWhite,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text('$inDeckCount'),
                                                ),
                                              ),
                                            if (!canAdd && inDeckCount < 3)
                                              Positioned(
                                                bottom: 4,
                                                left: 4,
                                                right: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: PixelTheme.pixelRed
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'DECK FULL',

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
            child: Row(children: [const SizedBox(width: 16)]),
          ),
        );
      },
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
        title: Text('Reset Deck?'),
        content: Text('This will remove all cards from your deck.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Reset'),
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
          content: Text('Deck saved successfully!'),
          backgroundColor: PixelTheme.pixelGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
