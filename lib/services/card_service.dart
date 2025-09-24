import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';

class CardService {
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal();

  List<GameCard> _allCards = [];
  List<GameCard> get allCards => _allCards;

  Future<void> initialize() async {
    await _loadAllCards();
  }

  Future<void> _loadAllCards() async {
    _allCards = [];

    // Load common cards
    await _loadCard('lib/data/cards/common/pico_warrior.json');
    await _loadCard('lib/data/cards/common/toasty_toaster.json');

    // Load rare cards
    await _loadCard('lib/data/cards/rare/base_tower.json');

    // Load epic cards
    await _loadCard('lib/data/cards/epic/chunky_tank.json');

    // Load legendary cards
    await _loadCard('lib/data/cards/legendary/some_bus.json');

    // Load Broken cards
    await _loadCard('lib/data/cards/broken/unfinished_geometry.json');
  }

  Future<void> _loadCard(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final GameCard card = GameCard.fromJson(jsonMap);
      _allCards.add(card);
    } catch (e) {
      print('Error loading card from $path: $e');
    }
  }

  GameCard? getCardById(String id) {
    try {
      return _allCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GameCard> getCardsByRarity(CardRarity rarity) {
    return _allCards.where((card) => card.rarity == rarity).toList();
  }

  List<GameCard> getCardsByIds(List<String> ids) {
    return ids
        .map((id) => getCardById(id))
        .where((card) => card != null)
        .cast<GameCard>()
        .toList();
  }

  List<GameCard> openCardPack(CardPack pack) {
    final Random random = Random();
    final List<GameCard> openedCards = [];

    for (int i = 0; i < pack.cardCount; i++) {
      final CardRarity rarity = _getRandomRarity(random);
      final List<GameCard> cardsOfRarity = getCardsByRarity(rarity);

      if (cardsOfRarity.isNotEmpty) {
        final GameCard randomCard =
            cardsOfRarity[random.nextInt(cardsOfRarity.length)];
        openedCards.add(randomCard);
      }
    }

    return openedCards;
  }

  CardRarity _getRandomRarity(Random random) {
    final int roll = random.nextInt(100) + 1; // 1-100
    if (roll <= CardRarity.broken.packWeight) {
      return CardRarity.broken;
    } else if (roll <=
        CardRarity.broken.packWeight + CardRarity.legendary.packWeight) {
      return CardRarity.legendary;
    } else if (roll <=
        CardRarity.legendary.packWeight + CardRarity.epic.packWeight) {
      return CardRarity.epic;
    } else if (roll <=
        CardRarity.legendary.packWeight +
            CardRarity.epic.packWeight +
            CardRarity.rare.packWeight) {
      return CardRarity.rare;
    } else {
      return CardRarity.common;
    }
  }

  List<CardPack> getAvailablePacks() {
    return [
      const CardPack(
        id: 'basic_pack',
        name: 'Basic Pack',
        cost: 100,
        cardCount: 5,
        description: 'A pack containing 5 random cards',
      ),
      const CardPack(
        id: 'premium_pack',
        name: 'Premium Pack',
        cost: 200,
        cardCount: 8,
        description: 'A premium pack with guaranteed rare or better',
      ),
    ];
  }
}
