// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameCard _$GameCardFromJson(Map<String, dynamic> json) => GameCard(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  cost: (json['cost'] as num).toInt(),
  attack: (json['attack'] as num).toInt(),
  health: (json['health'] as num).toInt(),
  rarity: $enumDecode(_$CardRarityEnumMap, json['rarity']),
  type: $enumDecode(_$CardTypeEnumMap, json['type']),
  imagePlaceholder: json['imagePlaceholder'] as String,
  gifPath: json['gifPath'] as String,
  abilities:
      (json['abilities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$GameCardToJson(GameCard instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'cost': instance.cost,
  'attack': instance.attack,
  'health': instance.health,
  'rarity': _$CardRarityEnumMap[instance.rarity]!,
  'type': _$CardTypeEnumMap[instance.type]!,
  'imagePlaceholder': instance.imagePlaceholder,
  'gifPath': instance.gifPath,
  'abilities': instance.abilities,
};

const _$CardRarityEnumMap = {
  CardRarity.common: 'common',
  CardRarity.rare: 'rare',
  CardRarity.epic: 'epic',
  CardRarity.legendary: 'legendary',
  CardRarity.broken: 'broken',
};

const _$CardTypeEnumMap = {
  CardType.creature: 'creature',
  CardType.spell: 'spell',
  CardType.artifact: 'artifact',
};
