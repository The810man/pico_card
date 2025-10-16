import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/game_provider.dart';
import 'package:pico_card/services/player_service.dart';
import 'package:pico_card/utils/consts/value_consts.dart';
import 'package:pico_card/utils/enums/game_enums.dart';

class BattleState {
  final int playerMana;
  final int playerLife;
  final int enemyLife;
  final int enemyMana;
  final TurnType turn;
  final List<GameCard> cardLibaryList;
  final List<GameCard> cardPlacedList;

  BattleState({
    required this.playerMana,
    required this.playerLife,
    required this.enemyLife,
    required this.turn,
    required this.cardLibaryList,
    required this.cardPlacedList,
    required this.enemyMana,
  });

  BattleState copyWith({
    int? playerMana,
    int? playerLife,
    int? enemyLife,
    TurnType? turn,
    List<GameCard>? cardLibaryList,
    List<GameCard>? cardPlacedList,
    int? enemyMana,
  }) {
    return BattleState(
      playerMana: playerMana ?? this.playerMana,
      playerLife: playerLife ?? this.playerLife,
      enemyLife: enemyLife ?? this.enemyLife,
      turn: turn ?? this.turn,
      cardLibaryList: cardLibaryList ?? this.cardLibaryList,
      cardPlacedList: cardPlacedList ?? this.cardPlacedList,
      enemyMana: enemyMana ?? this.enemyMana,
    );
  }
}

class BattleProvider extends StateNotifier<BattleState> {
  BattleProvider()
    : super(
        BattleState(
          playerMana: VALUE_PLAYER_MANA,
          playerLife: VALUE_PLAYER_HEALTH,
          enemyLife: VALUE_ENEMY_HEALTH,
          enemyMana: VALUE_ENEMY_MANA,
          turn: TurnType.player,
          cardLibaryList: [],
          cardPlacedList: [],
        ),
      );

  void endTurn() {
    if (state.turn == TurnType.player) {
      state = state.copyWith(turn: TurnType.enemy);
    } else {
      state = state.copyWith(
        turn: TurnType.player,
        playerMana: VALUE_PLAYER_MANA,
      );
    }
  }

  void usePlayerMana(int amount) {
    final mana = (state.playerMana - amount).clamp(0, VALUE_PLAYER_MANA);
    state = state.copyWith(playerMana: mana);
  }

  void generateLibary(GameProvider gameData) {
    if (state.cardLibaryList.isEmpty) {
      for (var i = 0; i < 3; i++) {
        addCardToLibary(gameData);
      }
    }
  }

  void addCardToLibary(GameProvider gameData) {
    List<GameCard> availableCards = gameData.playerDeck;
    GameCard randomCard =
        availableCards[Random().nextInt(availableCards.length)];
    state = state.copyWith(
      cardLibaryList: [...state.cardLibaryList, randomCard],
    );
  }

  void removeCardFromLibary(GameCard card) {
    List<GameCard> newLibary = [...state.cardLibaryList]..remove(card);
    state = state.copyWith(cardLibaryList: newLibary);
  }

  void damagePlayer(int amount) {
    final life = (state.playerLife - amount).clamp(0, VALUE_PLAYER_HEALTH);
    state = state.copyWith(playerLife: life);
  }

  void damageEnemy(int amount) {
    final life = (state.enemyLife - amount).clamp(0, VALUE_ENEMY_HEALTH);
    state = state.copyWith(enemyLife: life);
  }

  void resetBattle() {
    state = BattleState(
      playerMana: VALUE_PLAYER_MANA,
      playerLife: VALUE_PLAYER_HEALTH,
      enemyLife: VALUE_ENEMY_HEALTH,
      turn: TurnType.player,
      cardLibaryList: [],
      cardPlacedList: [],
      enemyMana: VALUE_ENEMY_MANA,
    );
  }
}

// Riverpod provider for screen-local BattleProvider state,
// autoDispose ensures re-initialization on screen open.
final battleProvider =
    StateNotifierProvider.autoDispose<BattleProvider, BattleState>(
      (ref) => BattleProvider(),
    );
