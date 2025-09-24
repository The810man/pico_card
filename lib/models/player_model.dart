import 'package:json_annotation/json_annotation.dart';
import 'card_model.dart';

part 'player_model.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final int coins;
  final List<String> collection; // Card IDs
  final List<String> deck; // Card IDs (max 30)
  final int level;
  final int experience;

  const Player({
    required this.id,
    required this.name,
    required this.coins,
    required this.collection,
    required this.deck,
    this.level = 1,
    this.experience = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player copyWith({
    String? id,
    String? name,
    int? coins,
    List<String>? collection,
    List<String>? deck,
    int? level,
    int? experience,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      coins: coins ?? this.coins,
      collection: collection ?? this.collection,
      deck: deck ?? this.deck,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }

  Player addCardToCollection(String cardId) {
    final newCollection = List<String>.from(collection);
    newCollection.add(cardId);
    return copyWith(collection: newCollection);
  }

  Player addCardToDeck(String cardId) {
    if (deck.length >= 30) return this;
    final newDeck = List<String>.from(deck);
    newDeck.add(cardId);
    return copyWith(deck: newDeck);
  }

  Player removeCardFromDeck(String cardId) {
    final newDeck = List<String>.from(deck);
    newDeck.remove(cardId);
    return copyWith(deck: newDeck);
  }

  Player spendCoins(int amount) {
    return copyWith(coins: coins - amount);
  }

  Player addCoins(int amount) {
    return copyWith(coins: coins + amount);
  }
}

@JsonSerializable()
class CardPack {
  final String id;
  final String name;
  final int cost;
  final int cardCount;
  final String description;

  const CardPack({
    required this.id,
    required this.name,
    required this.cost,
    required this.cardCount,
    required this.description,
  });

  factory CardPack.fromJson(Map<String, dynamic> json) => _$CardPackFromJson(json);
  Map<String, dynamic> toJson() => _$CardPackToJson(this);
}
