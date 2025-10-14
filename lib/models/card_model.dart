import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

enum CardRarity { common, rare, epic, legendary, broken, none }

enum CardType { creature, spell, artifact }

@JsonSerializable()
class GameCard {
  final String id;
  final String name;
  final String description;
  final int cost;
  final int attack;
  final int health;
  final CardRarity rarity;
  final CardType type;
  final String imagePlaceholder;
  final String gifPath; // For future GIF implementation
  final List<String> abilities;

  const GameCard({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.attack,
    required this.health,
    required this.rarity,
    required this.type,
    required this.imagePlaceholder,
    required this.gifPath,
    this.abilities = const [],
  });

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);
  Map<String, dynamic> toJson() => _$GameCardToJson(this);

  GameCard copyWith({
    String? id,
    String? name,
    String? description,
    int? cost,
    int? attack,
    int? health,
    CardRarity? rarity,
    CardType? type,
    String? imagePlaceholder,
    String? gifPath,
    List<String>? abilities,
  }) {
    return GameCard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      attack: attack ?? this.attack,
      health: health ?? this.health,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
      gifPath: gifPath ?? this.gifPath,
      abilities: abilities ?? this.abilities,
    );
  }
}

extension CardRarityExtension on CardRarity {
  String get displayName {
    switch (this) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.epic:
        return 'Epic';
      case CardRarity.legendary:
        return 'Legendary';
      case CardRarity.broken:
        return 'Broken';
      default:
        return "none";
    }
  }

  double get packWeight {
    switch (this) {
      case CardRarity.common:
        return 70; // 70% chance
      case CardRarity.rare:
        return 15; // 25% chance
      case CardRarity.epic:
        return 1; // 4% chance
      case CardRarity.legendary:
        return 0.01; // 1% chance
      case CardRarity.broken:
        return 0.00001;
      case CardRarity.none:
        return 0;
    }
  }
}
