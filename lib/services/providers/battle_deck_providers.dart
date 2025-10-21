import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';

// Replace this with your own import statement for GameCard
// import 'your_path/game_card.dart';

class PlayerGameCardListNotifier extends StateNotifier<List<GameCard>> {
  PlayerGameCardListNotifier() : super([]);

  void addCard(GameCard card) {
    state = [...state, card];
  }

  void removeCard(GameCard card) {
    state = state.where((c) => c != card).toList();
  }

  void updateCard(int index, GameCard updatedCard) {
    final newList = [...state];
    newList[index] = updatedCard;
    state = newList;
  }

  void clear() {
    state = [];
  }
}

class EnemyGameCardListNotifier extends StateNotifier<List<GameCard>> {
  EnemyGameCardListNotifier() : super([]);

  void addCard(GameCard card) {
    state = [...state, card];
  }

  void removeCard(GameCard card) {
    state = state.where((c) => c != card).toList();
  }

  void updateCard(int index, GameCard updatedCard) {
    final newList = [...state];
    newList[index] = updatedCard;
    state = newList;
  }

  void clear() {
    state = [];
  }
}

final playerGameCardListProvider =
    StateNotifierProvider<PlayerGameCardListNotifier, List<GameCard>>(
      (ref) => PlayerGameCardListNotifier(),
    );

final enemyGameCardListProvider =
    StateNotifierProvider<PlayerGameCardListNotifier, List<GameCard>>(
      (ref) => PlayerGameCardListNotifier(),
    );
