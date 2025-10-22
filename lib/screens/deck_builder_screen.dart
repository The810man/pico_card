import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/card_service.dart';
import 'package:pico_card/services/providers/deck_builder_provider.dart';
import 'package:pico_card/services/providers/game_provider.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';
import 'package:pico_card/models/card_model.dart';

class DeckBuilderScreen extends ConsumerWidget {
  static const String route = '/deck_builder';

  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameNotifier = ref.watch(gameProvider);
    final allCards = gameNotifier.playerCollection
        .toSet()
        .toList(); // Get unique cards
    final selectedCards = ref.watch(deckBuilderProvider);

    return Material(
      child: NesScaffold(
        body: Expanded(
          child: Column(
            children: [
              Text(
                'Available Cards Count: ${allCards.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Selected Cards Count: ${selectedCards.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Deck Size: ${gameNotifier.playerDeck.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              NesContainer(
                label: 'Your Deck (${selectedCards.length}/5)',
                child: SizedBox(
                  height: 200,
                  child: selectedCards.isEmpty
                      ? Center(
                          child: Text(
                            'No cards in deck',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedCards.length,
                          itemBuilder: (context, index) {
                            final card = selectedCards[index];
                            return CardWidget(
                              card: card,
                              showBack: ValueNotifier(false),
                              onTap: () {
                                ref
                                    .read(deckBuilderProvider.notifier)
                                    .removeCard(card);
                              },
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: NesContainer(
                  label: 'Available Cards',
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: allCards.length,
                    itemBuilder: (context, index) {
                      final card = allCards[index];
                      final isSelected = selectedCards.contains(card);
                      return CardWidget(
                        card: card,
                        showBack: ValueNotifier(false),
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelected) {
                            ref
                                .read(deckBuilderProvider.notifier)
                                .removeCard(card);
                          } else {
                            ref
                                .read(deckBuilderProvider.notifier)
                                .addCard(card);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              NesButton(
                type: NesButtonType.primary,
                onPressed: () async {
                  final newDeck = selectedCards.map((card) => card.id).toList();
                  await gameNotifier.updateDeck(newDeck);
                  NesSnackbar.show(
                    context,
                    text: 'Your deck has been successfully saved!',
                  );
                },
                child: const Text('Save Deck'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
