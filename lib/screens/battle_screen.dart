import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../services/game_provider.dart';
import '../widgets/card_widget.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({Key? key}) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  int playerHealth = 20;
  int enemyHealth = 20;
  int playerMana = 1;
  int maxMana = 1;
  int enemyMana = 1;
  int enemyMaxMana = 1;
  int turnCount = 1;
  List<GameCard> playerHand = [];
  List<GameCard> enemyBoard = [];
  List<GameCard> playerBoard = [];
  bool isPlayerTurn = true;
  String battleLog = 'Battle begins! Your turn.';

  // Drag and drop state
  GlobalKey _battlefieldKey = GlobalKey();
  bool _isDragging = false;
  int? _draggedCardIndex;
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBattle();
    });
  }

  void _initializeBattle() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final deck = gameProvider.playerDeck;

    // Check if player has a valid deck
    if (deck.isEmpty) {
      setState(() {
        battleLog = 'No cards in deck! Visit the shop to get cards first.';
      });
      _showNoDeckDialog();
      return;
    }

    // Draw initial hand (3 cards or all if less than 3)
    playerHand = deck.take(3).toList();

    // Add smarter enemy creatures
    final enemyCards = [
      GameCard(
        id: 'enemy_001',
        name: 'Shadow Minion',
        description: 'A dark creature summoned to battle.',
        cost: 2,
        attack: 2,
        health: 2,
        rarity: CardRarity.common,
        type: CardType.creature,
        imagePlaceholder: 'assets/images/cards/shadow_minion.png',
        gifPath: '',
        abilities: const [],
      ),
      GameCard(
        id: 'enemy_002',
        name: 'Dark Wizard',
        description: 'Evil magic user with powerful spells.',
        cost: 3,
        attack: 3,
        health: 2,
        rarity: CardRarity.rare,
        type: CardType.creature,
        imagePlaceholder: 'assets/images/cards/dark_wizard.png',
        gifPath: '',
        abilities: const ['Spell Damage +1'],
      ),
    ];

    // Randomly add 1-2 enemy creatures
    final random = Random();
    final enemyCount = random.nextInt(2) + 1;
    for (int i = 0; i < enemyCount; i++) {
      enemyBoard.add(enemyCards[random.nextInt(enemyCards.length)]);
    }

    setState(() {
      battleLog =
          'Battle begins! You have ${playerHand.length} cards. Enemy has ${enemyBoard.length} creatures!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text(
          'BATTLE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Pixel.zap, color: Colors.blue),
                Text(
                  '$playerMana/$maxMana',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enemy area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.red.withOpacity(0.1),
              child: Column(
                children: [
                  // Enemy health
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Pixel.bookmark, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Enemy: $enemyHealth HP',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enemy board
                  Expanded(
                    child: enemyBoard.isEmpty
                        ? const Center(
                            child: Text(
                              'No enemy creatures',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: enemyBoard.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CardWidget(
                                  card: enemyBoard[index],
                                  width: 80,
                                  height: 120,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Battle log
          Container(
            height: 60,
            color: Colors.grey[900],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  battleLog,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),

          // Player area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.blue.withOpacity(0.1),
              child: Column(
                children: [
                  // Player board (drag target area)
                  Expanded(
                    key: _battlefieldKey,
                    child: DragTarget<int>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: candidateData.isNotEmpty
                                ? Border.all(color: Colors.yellow, width: 2)
                                : null,
                            color: candidateData.isNotEmpty
                                ? Colors.yellow.withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: playerBoard.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Drag cards here to play them',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: playerBoard.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CardWidget(
                                        card: playerBoard[index],
                                        width: 80,
                                        height: 120,
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                      onWillAcceptWithDetails: (details) {
                        final cardIndex = details.data;
                        if (cardIndex != null &&
                            cardIndex < playerHand.length) {
                          final card = playerHand[cardIndex];
                          return isPlayerTurn && card.cost <= playerMana;
                        }
                        return false;
                      },
                      onAcceptWithDetails: (details) {
                        final cardIndex = details.data;
                        if (cardIndex != null &&
                            cardIndex < playerHand.length) {
                          final card = playerHand[cardIndex];
                          _playCard(card, cardIndex);
                        }
                      },
                    ),
                  ),

                  // Player health
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Pixel.bookmark, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'You: $playerHealth HP',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isPlayerTurn)
                          ElevatedButton(
                            onPressed: _endTurn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                            ),
                            child: const Text('End Turn'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Player hand
          Container(
            height: 140,
            color: Colors.grey[800],
            child: playerHand.isEmpty
                ? const Center(
                    child: Text(
                      'No cards in hand',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: playerHand.length,
                    itemBuilder: (context, index) {
                      final card = playerHand[index];
                      final canPlay = card.cost <= playerMana && isPlayerTurn;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: canPlay
                            ? Draggable<int>(
                                data: index,
                                feedback: Material(
                                  elevation: 6,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: CardWidget(
                                      card: card,
                                      width: 90,
                                      height: 125,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: CardWidget(
                                    card: card,
                                    width: 90,
                                    height: 125,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => _playCard(card, index),
                                  child: CardWidget(
                                    card: card,
                                    width: 90,
                                    height: 125,
                                  ),
                                ),
                              )
                            : Opacity(
                                opacity: 0.5,
                                child: GestureDetector(
                                  onTap: () {
                                    // Show why card can't be played
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          card.cost > playerMana
                                              ? 'Not enough mana! (${card.cost} required)'
                                              : 'Not your turn!',
                                        ),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  child: CardWidget(
                                    card: card,
                                    width: 90,
                                    height: 125,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _playCard(GameCard card, int handIndex) {
    if (!isPlayerTurn || card.cost > playerMana) return;

    setState(() {
      playerMana -= card.cost;
      playerHand.removeAt(handIndex);

      if (card.type == CardType.creature) {
        playerBoard.add(card);
        battleLog = 'Played ${card.name} (${card.attack}/${card.health})';
      } else {
        // Handle spells differently
        battleLog = 'Cast ${card.name}!';
        _castSpell(card);
      }
    });
  }

  void _castSpell(GameCard spell) {
    // Simple spell effects
    if (spell.name.contains('damage')) {
      enemyHealth -= 2;
      battleLog = '${spell.name} deals 2 damage to enemy!';
    } else {
      battleLog = '${spell.name} effect applied!';
    }

    _checkGameEnd();
  }

  void _endTurn() {
    setState(() {
      isPlayerTurn = false;
      battleLog = 'Enemy turn...';
    });

    // Enemy turn with AI
    Future.delayed(const Duration(seconds: 1), () {
      _enemyTurn();
    });
  }

  void _startNewTurn() {
    setState(() {
      turnCount++;

      // Increase max mana each turn (up to 10)
      if (maxMana < 10) {
        maxMana++;
      }
      if (enemyMaxMana < 10) {
        enemyMaxMana++;
      }

      // Restore mana to maximum
      playerMana = maxMana;
      enemyMana = enemyMaxMana;

      isPlayerTurn = true;

      // Draw a card if deck isn't empty
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final deck = gameProvider.playerDeck;
      if (playerHand.length < 7) {
        // Hand size limit
        final remainingCards = deck
            .skip(playerHand.length + playerBoard.length)
            .toList();
        if (remainingCards.isNotEmpty) {
          playerHand.add(remainingCards.first);
        }
      }

      battleLog = 'Turn $turnCount - Your turn! Mana: $playerMana/$maxMana';
    });
  }

  void _enemyTurn() {
    // Smarter enemy AI
    final random = Random();
    int totalDamage = 0;

    for (final enemyCreature in enemyBoard) {
      if (playerBoard.isNotEmpty) {
        // 70% chance to attack player creatures, 30% to go face
        if (random.nextInt(100) < 70) {
          final targetIndex = random.nextInt(playerBoard.length);
          final target = playerBoard[targetIndex];
          battleLog = '${enemyCreature.name} attacks ${target.name}!';

          // Remove player creature if destroyed
          if (target.health <= enemyCreature.attack) {
            playerBoard.removeAt(targetIndex);
            battleLog += ' ${target.name} is destroyed!';
          }
        } else {
          // Attack player directly
          totalDamage += enemyCreature.attack;
        }
      } else {
        // No player creatures, attack directly
        totalDamage += enemyCreature.attack;
      }
    }

    if (totalDamage > 0) {
      playerHealth -= totalDamage;
      battleLog += ' Enemy deals $totalDamage damage to you!';
    }

    _checkGameEnd();

    // Start new turn if game hasn't ended
    if (playerHealth > 0 && enemyHealth > 0) {
      _startNewTurn();
    }
  }

  void _checkGameEnd() {
    if (playerHealth <= 0) {
      _showGameEndDialog(
        'Defeat!',
        'You have been defeated. Better luck next time!',
      );
    } else if (enemyHealth <= 0) {
      _showGameEndDialog('Victory!', 'Congratulations! You won the battle!');
    }
  }

  void _showNoDeckDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'No Cards!',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You need cards to battle! Visit the shop to buy card packs first.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to main menu
            },
            child: const Text('Go to Shop'),
          ),
        ],
      ),
    );
  }

  void _showGameEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: TextStyle(
            color: title == 'Victory!' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
