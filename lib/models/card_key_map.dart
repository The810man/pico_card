import 'package:flutter/widgets.dart';
import 'package:pico_card/models/card_model.dart';

/// A simple map-like wrapper that associates a [GameCard] with a [GlobalKey].
class CardKeyMap {
  final Map<GameCard, GlobalKey<State<StatefulWidget>>> _map;

  CardKeyMap([Map<GameCard, GlobalKey<State<StatefulWidget>>>? initial])
    : _map = Map.from(initial ?? {});

  /// Returns the key for [card], or null if none exists.
  GlobalKey<State<StatefulWidget>>? get(GameCard card) => _map[card];

  /// Returns the existing key for [card], or creates and returns a new one.
  GlobalKey<State<StatefulWidget>> getOrCreate(GameCard card) {
    return _map.putIfAbsent(card, () => GlobalKey<State<StatefulWidget>>());
  }

  /// Associates [key] with [card].
  void put(GameCard card, GlobalKey<State<StatefulWidget>> key) {
    _map[card] = key;
  }

  /// Removes the key associated with [card].
  GlobalKey<State<StatefulWidget>>? remove(GameCard card) => _map.remove(card);

  /// Whether a key for [card] exists.
  bool contains(GameCard card) => _map.containsKey(card);

  /// Number of entries.
  int get length => _map.length;

  /// Whether the map is empty.
  bool get isEmpty => _map.isEmpty;

  /// Whether the map is not empty.
  bool get isNotEmpty => _map.isNotEmpty;

  /// Clears all entries.
  void clear() => _map.clear();

  /// Exposes an unmodifiable view of the internal map.
  Map<GameCard, GlobalKey<State<StatefulWidget>>> toMap() =>
      Map.unmodifiable(_map);
}
