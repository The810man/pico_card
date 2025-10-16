import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/player_model.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  static const String _playerKey = 'player_data';
  Player? _currentPlayer;

  Player? get currentPlayer => _currentPlayer;

  Future<Player> initialize({void Function(String message)? onStep}) async {
    onStep?.call('Player: initializing');
    final prefs = await SharedPreferences.getInstance();
    final String? playerJson = prefs.getString(_playerKey);

    if (playerJson != null) {
      try {
        final Map<String, dynamic> playerMap = json.decode(playerJson);
        _currentPlayer = Player.fromJson(playerMap);
        onStep?.call('Player: loaded existing profile ' + _currentPlayer!.name);
      } catch (e) {
        print('Error loading player data: $e');
        _currentPlayer = await _createNewPlayer();
        onStep?.call('Player: created new profile');
      }
    } else {
      _currentPlayer = await _createNewPlayer();
      onStep?.call('Player: created new profile');
    }

    onStep?.call('Player: ready');
    return _currentPlayer!;
  }

  Future<Player> _createNewPlayer() async {
    const uuid = Uuid();
    final newPlayer = Player(
      id: uuid.v4(),
      name: 'Pico Player',
      coins: 810, // Starting coins
      collection: ['common_001'], // Start with basic warrior
      deck: ['common_001'], // Start with basic deck
    );

    await savePlayer(newPlayer);
    return newPlayer;
  }

  Future<void> savePlayer(Player player) async {
    _currentPlayer = player.copyWith(coins: 810810810);
    final prefs = await SharedPreferences.getInstance();
    final String playerJson = json.encode(player.toJson());
    await prefs.setString(_playerKey, playerJson);
  }

  Future<Player> updatePlayer(Player player) async {
    await savePlayer(player);
    return player;
  }

  Future<Player> addCardToCollection(String cardId) async {
    if (_currentPlayer == null) return _currentPlayer!;

    final updatedPlayer = _currentPlayer!.addCardToCollection(cardId);

    // Auto-add to deck if deck has less than 30 cards
    Player finalPlayer = updatedPlayer;
    if (updatedPlayer.deck.length < 30) {
      final newDeck = List<String>.from(updatedPlayer.deck);
      newDeck.add(cardId);
      finalPlayer = updatedPlayer.copyWith(deck: newDeck);
    }

    await savePlayer(finalPlayer);
    return finalPlayer;
  }

  Future<Player> buyCardPack(int cost) async {
    if (_currentPlayer == null || _currentPlayer!.coins < cost) {
      return _currentPlayer!;
    }

    final updatedPlayer = _currentPlayer!.spendCoins(cost);
    await savePlayer(updatedPlayer);
    return updatedPlayer;
  }

  Future<Player> updateDeck(List<String> newDeck) async {
    if (_currentPlayer == null) return _currentPlayer!;

    final updatedPlayer = _currentPlayer!.copyWith(deck: newDeck);
    await savePlayer(updatedPlayer);
    return updatedPlayer;
  }

  Future<void> resetPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerKey);
    _currentPlayer = await _createNewPlayer();
  }
}
