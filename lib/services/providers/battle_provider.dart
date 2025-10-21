import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/game_provider.dart';
import 'package:pico_card/services/player_service.dart';
import 'package:pico_card/utils/consts/value_consts.dart';
import 'package:pico_card/utils/enums/game_enums.dart';

class BattleState {
  final int playerMana;
  final int playerLife;
  final int enemyLife;
  final int enemyMana;
  final TurnType turn;
  final List<GameCard> cardLibaryListPlayer;
  final List<GameCard> cardPlacedListPlayer;
  final List<GameCard> cardLibaryListEnemy;
  final List<GameCard> cardPlacedListEnemy;

  BattleState({
    required this.playerMana,
    required this.playerLife,
    required this.enemyLife,
    required this.turn,
    required this.cardLibaryListPlayer,
    required this.cardPlacedListPlayer,
    required this.cardLibaryListEnemy,
    required this.cardPlacedListEnemy,
    required this.enemyMana,
  });

  BattleState copyWith({
    int? playerMana,
    int? playerLife,
    int? enemyLife,
    TurnType? turn,
    List<GameCard>? cardLibaryListPlayer,
    List<GameCard>? cardPlacedListPlayer,
    List<GameCard>? cardLibaryListEnemy,
    List<GameCard>? cardPlacedListEnemy,
    int? enemyMana,
  }) {
    return BattleState(
      playerMana: playerMana ?? this.playerMana,
      playerLife: playerLife ?? this.playerLife,
      enemyLife: enemyLife ?? this.enemyLife,
      turn: turn ?? this.turn,
      cardLibaryListPlayer: cardLibaryListPlayer ?? this.cardLibaryListPlayer,
      cardPlacedListPlayer: cardPlacedListPlayer ?? this.cardPlacedListPlayer,
      cardLibaryListEnemy: cardLibaryListEnemy ?? this.cardLibaryListEnemy,
      cardPlacedListEnemy: cardPlacedListEnemy ?? this.cardPlacedListEnemy,
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
          cardLibaryListPlayer: [],
          cardPlacedListPlayer: [],
          cardLibaryListEnemy: [],
          cardPlacedListEnemy: [],
        ),
      );

  void endTurn(GameProvider gameData) {
    if (state.turn == TurnType.player) {
      state = state.copyWith(
        turn: TurnType.enemy,
        playerMana: state.playerMana + 1,
      );
      if (state.cardLibaryListPlayer.length < 3) {
        addCardToLibary(gameData);
      }
      unTapCards();
      botEnemyTurn(gameData);
    } else {
      state = state.copyWith(
        turn: TurnType.player,
        enemyMana: state.enemyMana + 1,
      );
      unTapCards();
      if (state.cardLibaryListEnemy.length < 3) {
        addCardToLibary(gameData);
      }
    }
  }

  void unTapCards() {
    if (state.turn == TurnType.enemy) {
      for (GameCard card in state.cardPlacedListPlayer) {
        card = card.copyWith(isTapped: false);
      }
    } else {
      for (GameCard card in state.cardPlacedListEnemy) {
        card = card.copyWith(isTapped: false);
      }
    }
  }

  void usePlayerMana(int amount) {
    final mana = (state.playerMana - amount).clamp(0, VALUE_PLAYER_MANA);
    state = state.copyWith(playerMana: mana);
  }

  void generateLibary(GameProvider gameData) {
    if (state.cardLibaryListPlayer.isEmpty) {
      for (var i = 0; i < 3; i++) {
        addCardToLibary(gameData);
      }
    }
  }

  void addCardToLibary(GameProvider gameData) {
    List<GameCard> availableCards = gameData.playerDeck;
    final TurnType turn = state.turn;
    GameCard randomCard =
        availableCards[Random().nextInt(availableCards.length)];
    if (turn == TurnType.player) {
      state = state.copyWith(
        cardLibaryListPlayer: [...state.cardLibaryListPlayer, randomCard],
      );
      return;
    }
    state = state.copyWith(
      cardLibaryListEnemy: [...state.cardLibaryListEnemy, randomCard],
    );
  }

  void removeCardFromLibary(GameCard card) {
    List<GameCard> newLibary = [...state.cardLibaryListPlayer]..remove(card);
    state = state.copyWith(cardLibaryListPlayer: newLibary);
  }

  void damagePlayer(int amount) {
    final life = (state.playerLife - amount).clamp(0, VALUE_PLAYER_HEALTH);
    state = state.copyWith(playerLife: life);
  }

  void damageEnemy(int amount) {
    final life = (state.enemyLife - amount).clamp(0, VALUE_ENEMY_HEALTH);
    state = state.copyWith(enemyLife: life);
  }

  void damageCard(GameCard card) {
    final int amount = card.attack;
    switch (state.turn) {
      case TurnType.player:
        card = card.copyWith(health: card.health - amount);
        if (card.health <= 0) {
          state = state.copyWith(
            cardPlacedListEnemy: state.cardPlacedListEnemy..remove(card),
          );
        }
      case TurnType.enemy:
        card = card.copyWith(health: card.health - amount);
        if (card.health <= 0) {
          state = state.copyWith(
            cardPlacedListPlayer: state.cardPlacedListPlayer..remove(card),
          );
        }
      default:
    }
  }

  void resetBattle() {
    state = BattleState(
      playerMana: VALUE_PLAYER_MANA,
      playerLife: VALUE_PLAYER_HEALTH,
      enemyLife: VALUE_ENEMY_HEALTH,
      turn: TurnType.player,
      cardLibaryListPlayer: [],
      cardPlacedListPlayer: [],
      cardLibaryListEnemy: [],
      cardPlacedListEnemy: [],
      enemyMana: VALUE_ENEMY_MANA,
    );
  }

  GameCard botGetRandomAffordableCard() {
    final List<GameCard> affordables = [];
    for (GameCard card in state.cardLibaryListEnemy) {
      if (card.cost <= state.enemyMana) affordables.add(card);
    }
    final int randomIndex = Random().nextInt(affordables.length);
    return affordables[randomIndex];
  }

  GameCard botGetAttackCard() {
    final List<GameCard> untappedCards = [];
    for (GameCard card in state.cardPlacedListEnemy) {
      if (!card.isTapped) untappedCards.add(card);
    }
    final int randomIndex = Random().nextInt(untappedCards.length);
    return untappedCards[randomIndex];
  }

  bool botCamAffordCards() {
    final List<GameCard> affordables = [];
    for (GameCard card in state.cardLibaryListEnemy) {
      if (card.cost <= state.enemyMana) affordables.add(card);
    }
    if (affordables.isEmpty) return false;
    return true;
  }

  BotActions botActionPlace() {
    final bool shouldPlace = Random().nextBool();

    if (state.cardPlacedListEnemy.length >= 3) return BotActions.pass;
    if (state.cardLibaryListEnemy.isEmpty) return BotActions.pass;
    if (botCamAffordCards()) return BotActions.pass;

    switch (shouldPlace) {
      case true:
        return BotActions.place;
      case false:
        return BotActions.pass;
    }
  }

  bool canAnyCardAttack() {
    final List<GameCard> untappedCards = [];
    for (GameCard card in state.cardPlacedListEnemy) {
      if (!card.isTapped) untappedCards.add(card);
    }
    if (untappedCards.isNotEmpty) return true;
    return false;
  }

  BotActions botActionAttack() {
    final bool shouldAttack = Random().nextBool();

    if (state.cardPlacedListEnemy.isEmpty) return BotActions.pass;
    if (!canAnyCardAttack()) return BotActions.pass;

    switch (shouldAttack) {
      case true:
        return BotActions.attack;
      case false:
        return BotActions.pass;
    }
  }

  void botPlaceSegment() {
    final BotActions placeDesicion = botActionPlace();
    switch (placeDesicion) {
      case BotActions.place:
        final GameCard card = botGetRandomAffordableCard();
        state.copyWith(
          cardPlacedListEnemy: [...state.cardPlacedListEnemy, card],
        );
      default:
        return;
    }
  }

  void botAttkWithCard(GameCard card) {
    if (state.cardPlacedListPlayer.isEmpty) {
      damagePlayer(card.attack);
      return;
    }
    final int plCardIndex = Random().nextInt(state.cardPlacedListPlayer.length);
    final GameCard toAttackCard = state.cardPlacedListPlayer[plCardIndex];
    damageCard(card);
  }

  void botAttackSegment() {
    final BotActions attackDesicion = botActionAttack();
    switch (attackDesicion) {
      case BotActions.attack:
        final GameCard card = botGetAttackCard();
        botAttkWithCard(card);
      default:
        return;
    }
  }

  void botEnemyTurn(GameProvider gameData) {
    botPlaceSegment();
    botAttackSegment();
    endTurn(gameData);
  }
}

// Riverpod provider for screen-local BattleProvider state,
// autoDispose ensures re-initialization on screen open.
final battleProvider =
    StateNotifierProvider.autoDispose<BattleProvider, BattleState>(
      (ref) => BattleProvider(),
    );
