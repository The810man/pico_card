import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/game_provider.dart';
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
  final bool attackMode;
  final GameCard? selectedAttackingCard;
  final bool gameOver;
  final String? winner;
  final bool enemyAttacking;
  final GameCard? enemyAttackingCard;
  final GameCard? enemyTargetCard;
  // Stars per placed card id (0..5)
  final Map<String, int> starLevels;

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
    this.attackMode = false,
    this.selectedAttackingCard,
    this.gameOver = false,
    this.winner,
    this.enemyAttacking = false,
    this.enemyAttackingCard,
    this.enemyTargetCard,
    required this.starLevels,
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
    bool? attackMode,
    GameCard? selectedAttackingCard,
    bool? gameOver,
    String? winner,
    bool? enemyAttacking,
    GameCard? enemyAttackingCard,
    GameCard? enemyTargetCard,
    Map<String, int>? starLevels,
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
      attackMode: attackMode ?? this.attackMode,
      selectedAttackingCard:
          selectedAttackingCard ?? this.selectedAttackingCard,
      gameOver: gameOver ?? this.gameOver,
      winner: winner ?? this.winner,
      enemyAttacking: enemyAttacking ?? this.enemyAttacking,
      enemyAttackingCard: enemyAttackingCard ?? this.enemyAttackingCard,
      enemyTargetCard: enemyTargetCard ?? this.enemyTargetCard,
      starLevels: starLevels ?? this.starLevels,
    );
  }
}

class BattleProvider extends StateNotifier<BattleState> {
  bool _mounted = true;
  // Guard to ensure a single DragTarget processes a given library-card drop
  final Set<String> _processingDragIds = {};
  // Try to claim handling of a drop for a specific library card id.
  // Returns false if some other target already claimed it.
  bool claimDrag(String id) {
    if (_processingDragIds.contains(id)) return false;
    _processingDragIds.add(id);
    return true;
  }

  // Release claim for a library card id (safe to call multiple times).
  void releaseDrag(String id) {
    _processingDragIds.remove(id);
  }

  // Guard to prevent duplicate placement from the same library card id
  final Set<String> _placedFromLibIds = {};

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
          attackMode: false,
          selectedAttackingCard: null,
          gameOver: false,
          winner: null,
          enemyAttacking: false,
          enemyAttackingCard: null,
          starLevels: const {},
        ),
      );

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  void endTurn(GameProvider gameData) {
    if (state.turn == TurnType.player) {
      // Player ends turn: draw for player if needed, then pass turn to enemy
      if (state.cardLibaryListPlayer.length < 3) {
        addCardToLibary(gameData, forSide: TurnType.player);
      }
      state = state.copyWith(
        turn: TurnType.enemy,
        playerMana: state.playerMana + 1,
      );
      unTapCards();
      // Start bot turn asynchronously
      botEnemyTurn(gameData);
    } else {
      // Enemy ends turn: draw for enemy if needed, then pass turn to player
      if (state.cardLibaryListEnemy.length < 3) {
        addCardToLibary(gameData, forSide: TurnType.enemy);
      }
      state = state.copyWith(
        turn: TurnType.player,
        enemyMana: state.enemyMana + 1,
      );
      unTapCards();
    }
  }

  void unTapCards() {
    // Untap cards for the side whose turn it is starting now
    if (state.turn == TurnType.player) {
      // Player's turn: untap player cards
      final List<GameCard> updatedPlayerCards = state.cardPlacedListPlayer
          .map((card) => card.copyWith(isTapped: false))
          .toList();
      state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
    } else if (state.turn == TurnType.enemy) {
      // Enemy's turn: untap enemy cards
      final List<GameCard> updatedEnemyCards = state.cardPlacedListEnemy
          .map((card) => card.copyWith(isTapped: false))
          .toList();
      state = state.copyWith(cardPlacedListEnemy: updatedEnemyCards);
    }
  }

  void usePlayerMana(int amount) {
    final mana = (state.playerMana - amount).clamp(0, VALUE_PLAYER_MANA);
    state = state.copyWith(playerMana: mana);
  }

  void generateLibary(GameProvider gameData) {
    if (state.cardLibaryListPlayer.isEmpty) {
      for (var i = 0; i < 3; i++) {
        addCardToLibary(gameData, forSide: TurnType.player);
      }
    }
  }

  // Draw one card for the specified side (defaults to current state.turn)
  void addCardToLibary(GameProvider gameData, {TurnType? forSide}) {
    // Always add a UNIQUE instance into the library so removing by reference
    // removes exactly the dragged card even if duplicates of the same base id exist.
    final List<GameCard> availableCards = gameData.playerDeck;
    final TurnType side = forSide ?? state.turn;
    final GameCard base =
        availableCards[Random().nextInt(availableCards.length)];

    final String uniqueSuffix =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
    final GameCard libCard = base.copyWith(
      id: '${base.id}__lib__$uniqueSuffix',
    );

    if (side == TurnType.player) {
      state = state.copyWith(
        cardLibaryListPlayer: [...state.cardLibaryListPlayer, libCard],
      );
      return;
    }

    if (side == TurnType.enemy) {
      state = state.copyWith(
        cardLibaryListEnemy: [...state.cardLibaryListEnemy, libCard],
      );
      return;
    }
  }

  void removeCardFromLibary(GameCard card) {
    // Remove by id to avoid accidentally removing the wrong copy
    final List<GameCard> newLibary = [
      ...state.cardLibaryListPlayer.where((c) => c.id != card.id),
    ];
    state = state.copyWith(cardLibaryListPlayer: newLibary);

    // Also clear any pending drag-claim for this library id to avoid stale entries
  }

  void addCardToPlayerPlaced(GameCard card) {
    // Hard guard: do not place twice for the same library drag id
    if (_placedFromLibIds.contains(card.id)) {
      return;
    }
    _placedFromLibIds.add(card.id);
    // Cleanup guard shortly after to avoid stale memory
    // Place a fresh copy with a unique runtime id and start tapped (summoning sickness)
    final String uniqueSuffix =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
    final GameCard placed = card.copyWith(
      id: '${card.id}__$uniqueSuffix',
      isTapped: true,
    );

    // Safety: do not exceed 3 slots
    if (state.cardPlacedListPlayer.length >= 3) {
      return;
    }

    final List<GameCard> updatedPlayerCards = [
      ...state.cardPlacedListPlayer,
      placed,
    ];
    state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
  }

  void damagePlayer(int amount) {
    final life = (state.playerLife - amount).clamp(0, VALUE_PLAYER_HEALTH);
    state = state.copyWith(playerLife: life);
    checkGameOver();
  }

  void damageEnemy(int amount) {
    final life = (state.enemyLife - amount).clamp(0, VALUE_ENEMY_HEALTH);
    state = state.copyWith(enemyLife: life);
    checkGameOver();
  }

  void damageCard(GameCard attackingCard, GameCard targetCard) {
    final int damage = attackingCard.attack;
    final GameCard updatedTarget = targetCard.copyWith(
      health: targetCard.health - damage,
    );

    if (state.turn == TurnType.player) {
      // Player attacking enemy card
      if (updatedTarget.health <= 0) {
        final List<GameCard> updatedEnemyCards = state.cardPlacedListEnemy
            .where((card) => card.id != targetCard.id)
            .toList();
        state = state.copyWith(cardPlacedListEnemy: updatedEnemyCards);
      } else {
        final List<GameCard> updatedEnemyCards = state.cardPlacedListEnemy
            .map((card) => card.id == targetCard.id ? updatedTarget : card)
            .toList();
        state = state.copyWith(cardPlacedListEnemy: updatedEnemyCards);
      }

      // Mark attacking card as tapped
      final List<GameCard> updatedPlayerCards = state.cardPlacedListPlayer
          .map(
            (card) => card.id == attackingCard.id
                ? attackingCard.copyWith(isTapped: true)
                : card,
          )
          .toList();
      state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
    } else {
      // Enemy attacking player card
      if (updatedTarget.health <= 0) {
        final List<GameCard> updatedPlayerCards = state.cardPlacedListPlayer
            .where((card) => card.id != targetCard.id)
            .toList();
        state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
      } else {
        final List<GameCard> updatedPlayerCards = state.cardPlacedListPlayer
            .map((card) => card.id == targetCard.id ? updatedTarget : card)
            .toList();
        state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
      }

      // Mark attacking card as tapped
      final List<GameCard> updatedEnemyCards = state.cardPlacedListEnemy
          .map(
            (card) => card.id == attackingCard.id
                ? attackingCard.copyWith(isTapped: true)
                : card,
          )
          .toList();
      state = state.copyWith(cardPlacedListEnemy: updatedEnemyCards);
    }
  }

  void checkGameOver() {
    if (state.playerLife <= 0) {
      state = state.copyWith(gameOver: true, winner: 'enemy');
    } else if (state.enemyLife <= 0) {
      state = state.copyWith(gameOver: true, winner: 'player');
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
      attackMode: false,
      selectedAttackingCard: null,
      gameOver: false,
      winner: null,
      enemyAttacking: false,
      enemyAttackingCard: null,
      enemyTargetCard: null,
      starLevels: const {},
    );
  }

  GameCard botGetRandomAffordableCard() {
    final List<GameCard> affordables = [];
    for (GameCard card in state.cardLibaryListEnemy) {
      if (card.cost <= state.enemyMana) affordables.add(card);
    }
    if (affordables.isEmpty) {
      // If no affordable cards, return the first card anyway (for testing)
      return state.cardLibaryListEnemy.first;
    }
    final int randomIndex = Random().nextInt(affordables.length);
    return affordables[randomIndex];
  }

  GameCard botGetAttackCard() {
    final List<GameCard> untappedCards = [];
    for (GameCard card in state.cardPlacedListEnemy) {
      if (!card.isTapped) untappedCards.add(card);
    }
    if (untappedCards.isEmpty) {
      // If no untapped cards, return null or handle gracefully
      if (state.cardPlacedListEnemy.isNotEmpty) {
        return state.cardPlacedListEnemy.first;
      }
      // This shouldn't happen, but safety check
      throw Exception("No enemy cards available for attack");
    }
    final int randomIndex = Random().nextInt(untappedCards.length);
    return untappedCards[randomIndex];
  }

  bool botCanAffordCards() {
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
    if (!botCanAffordCards()) return BotActions.pass;

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
        if (state.cardLibaryListEnemy.isNotEmpty) {
          final GameCard card = botGetRandomAffordableCard();
          // Ensure placed enemy copies have unique ids and start tapped (summoning sickness)
          final String uniqueSuffix =
              '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
          final GameCard placed = card.copyWith(
            id: '${card.id}__$uniqueSuffix',
            isTapped: true,
          );
          final List<GameCard> updatedEnemyCards = [
            ...state.cardPlacedListEnemy,
            placed,
          ];
          final List<GameCard> updatedLibrary = state.cardLibaryListEnemy
              .where((c) => c.id != card.id)
              .toList();
          state = state.copyWith(
            cardPlacedListEnemy: updatedEnemyCards,
            cardLibaryListEnemy: updatedLibrary,
            enemyMana: state.enemyMana - card.cost,
          );
        }
      default:
        return;
    }
  }

  void botAttkWithCard(GameCard card) {
    if (state.cardPlacedListPlayer.isEmpty) {
      // Mark which enemy card is attacking (direct attack)
      state = state.copyWith(
        enemyAttacking: true,
        enemyAttackingCard: card,
        enemyTargetCard: null,
      );
      damagePlayer(card.attack);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          state = state.copyWith(
            enemyAttacking: false,
            enemyAttackingCard: null,
            enemyTargetCard: null,
          );
        }
      });
      return;
    }

    // Mark which enemy card is attacking a player card
    final int plCardIndex = Random().nextInt(state.cardPlacedListPlayer.length);
    final GameCard toAttackCard = state.cardPlacedListPlayer[plCardIndex];

    state = state.copyWith(
      enemyAttacking: true,
      enemyAttackingCard: card,
      enemyTargetCard: toAttackCard,
    );

    damageCard(card, toAttackCard);

    // Clear indicator shortly after
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        state = state.copyWith(
          enemyAttacking: false,
          enemyAttackingCard: null,
          enemyTargetCard: null,
        );
      }
    });
  }

  void botAttackSegment() {
    final BotActions attackDesicion = botActionAttack();
    switch (attackDesicion) {
      case BotActions.attack:
        try {
          final GameCard card = botGetAttackCard();
          botAttkWithCard(card);
        } catch (e) {
          // If no cards available, skip attack
          return;
        }
      default:
        return;
    }
  }

  void playerAttackCard(GameCard attackingCard, GameCard targetCard) {
    if (state.turn != TurnType.player) return;
    if (attackingCard.isTapped) return;

    damageCard(attackingCard, targetCard);
  }

  void playerAttackEnemy(GameCard attackingCard) {
    if (state.turn != TurnType.player) return;
    if (attackingCard.isTapped) return;

    damageEnemy(attackingCard.attack);

    // Mark attacking card as tapped
    final List<GameCard> updatedPlayerCards = state.cardPlacedListPlayer
        .map(
          (card) => card.id == attackingCard.id
              ? attackingCard.copyWith(isTapped: true)
              : card,
        )
        .toList();
    state = state.copyWith(cardPlacedListPlayer: updatedPlayerCards);
  }

  void startAttackMode(GameCard attackingCard) {
    if (state.turn != TurnType.player) return;
    if (attackingCard.isTapped) return;

    state = state.copyWith(
      attackMode: true,
      selectedAttackingCard: attackingCard,
    );
  }

  void cancelAttackMode() {
    state = state.copyWith(attackMode: false, selectedAttackingCard: null);
  }

  void attackCard(GameCard targetCard) {
    if (!state.attackMode || state.selectedAttackingCard == null) return;
    if (state.turn != TurnType.player) return;

    // Show attack animation
    // Note: Animation will be handled by the widget that calls this

    damageCard(state.selectedAttackingCard!, targetCard);

    // Exit attack mode
    cancelAttackMode();
  }

  void attackEnemyDirectly() {
    if (!state.attackMode || state.selectedAttackingCard == null) return;
    if (state.turn != TurnType.player) return;

    playerAttackEnemy(state.selectedAttackingCard!);

    // Exit attack mode
    cancelAttackMode();
  }

  void botEnemyTurn(GameProvider gameData) {
    // Use a timer to add delays without blocking the UI
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        botPlaceSegment();

        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            botAttackSegment();

            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                endTurn(gameData);
              }
            });
          }
        });
      }
    });
  }

  // Helpers for upgrades
  String baseIdOf(String id) {
    final idx = id.indexOf('__');
    return idx == -1 ? id : id.substring(0, idx);
  }

  int starsFor(String placedCardId) {
    return state.starLevels[placedCardId] ?? 0;
  }

  bool canUpgrade(GameCard placed, GameCard incoming) {
    return baseIdOf(placed.id) == baseIdOf(incoming.id) &&
        starsFor(placed.id) < 5;
  }

  // Upgrade logic: drag matching card from library onto placed card to add a star
  // Cost formula: incoming.cost + currentStars + 1
  void upgradeCard(GameCard placedCard, GameCard incomingFromLib) {
    if (!canUpgrade(placedCard, incomingFromLib)) return;

    final currentStars = starsFor(placedCard.id);
    final int upgradeCost = incomingFromLib.cost + currentStars + 1;
    if (state.playerMana < upgradeCost) return;

    // Deduct mana
    state = state.copyWith(playerMana: state.playerMana - upgradeCost);

    // Apply stat increases (+1 attack, +1 health per upgrade)
    final GameCard upgraded = placedCard.copyWith(
      attack: placedCard.attack + 1,
      health: placedCard.health + 1,
    );

    // Replace placed card instance
    final List<GameCard> updatedPlaced = state.cardPlacedListPlayer
        .map((c) => c.id == placedCard.id ? upgraded : c)
        .toList();

    // Update starLevels
    final Map<String, int> updatedStars = Map<String, int>.from(
      state.starLevels,
    )..update(placedCard.id, (v) => v + 1, ifAbsent: () => 1);

    state = state.copyWith(
      cardPlacedListPlayer: updatedPlaced,
      starLevels: updatedStars,
    );
  }

  // Replace a placed card with a new one from the library.
  // Refund the cost of the recycled card, and pay the cost of the incoming card.
  // New placed card starts tapped and resets stars for that slot.
  void replaceCard(GameCard slotCard, GameCard incomingFromLib) {
    // Compute mana after replacement: pay incoming, refund old
    final int newMana =
        (state.playerMana - incomingFromLib.cost + slotCard.cost).clamp(
          0,
          VALUE_MAX_MANA,
        );

    // Create a fresh placed copy with unique id, start tapped (summoning sickness)
    final String uniqueSuffix =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
    final GameCard placed = incomingFromLib.copyWith(
      id: '${incomingFromLib.id}__$uniqueSuffix',
      isTapped: true,
    );

    // Replace the card in the placed list
    final List<GameCard> updatedPlaced = state.cardPlacedListPlayer
        .map((c) => c.id == slotCard.id ? placed : c)
        .toList();

    // Clear stars for the replaced slot id; new card starts at 0 stars
    final Map<String, int> updatedStars = Map<String, int>.from(
      state.starLevels,
    )..remove(slotCard.id);

    state = state.copyWith(
      cardPlacedListPlayer: updatedPlaced,
      playerMana: newMana,
      starLevels: updatedStars,
    );
  }

  // Method to show enemy attack animation
  void showEnemyAttackAnimation(GameCard attackingCard, GameCard? targetCard) {
    // This will be called from the widget to show animation
    // For now, just a placeholder
  }
}

// Riverpod provider for screen-local BattleProvider state,
// autoDispose ensures re-initialization on screen open.
final battleProvider =
    StateNotifierProvider.autoDispose<BattleProvider, BattleState>(
      (ref) => BattleProvider(),
    );
