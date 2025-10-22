import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';

class DeckBuilderNotifier extends StateNotifier<List<GameCard>> {
  DeckBuilderNotifier() : super([]);

  void addCard(GameCard card) {
    if (state.length < 5) {
      state = [...state, card];
    }
  }

  void removeCard(GameCard card) {
    state = state.where((c) => c.id != card.id).toList();
  }

  void clearDeck() {
    state = [];
  }
}

final deckBuilderProvider =
    StateNotifierProvider<DeckBuilderNotifier, List<GameCard>>(
      (ref) => DeckBuilderNotifier(),
    );
