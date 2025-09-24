// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  coins: (json['coins'] as num).toInt(),
  collection: (json['collection'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  deck: (json['deck'] as List<dynamic>).map((e) => e as String).toList(),
  level: (json['level'] as num?)?.toInt() ?? 1,
  experience: (json['experience'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'coins': instance.coins,
  'collection': instance.collection,
  'deck': instance.deck,
  'level': instance.level,
  'experience': instance.experience,
};

CardPack _$CardPackFromJson(Map<String, dynamic> json) => CardPack(
  id: json['id'] as String,
  name: json['name'] as String,
  cost: (json['cost'] as num).toInt(),
  cardCount: (json['cardCount'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$CardPackToJson(CardPack instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cost': instance.cost,
  'cardCount': instance.cardCount,
  'description': instance.description,
};
