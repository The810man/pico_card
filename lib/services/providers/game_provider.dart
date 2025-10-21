import 'package:flutter/foundation.dart';
import '../../models/card_model.dart';
import '../../models/player_model.dart';
import '../card_service.dart';
import '../player_service.dart';

class GameProvider extends ChangeNotifier {
  final CardService _cardService = CardService();
  final PlayerService _playerService = PlayerService();

  Player? _player;
  List<GameCard> _availableCards = [];
  bool _isLoading = true;

  Player? get player => _player;
  List<GameCard> get availableCards => _availableCards;
  bool get isLoading => _isLoading;
  final List<String> _bootLogs = [];
  List<String> get bootLogs => List.unmodifiable(_bootLogs);

  void _log(String message) {
    _bootLogs.add(message);
    notifyListeners();
  }

  List<GameCard> get playerCollection {
    if (_player == null) return [];
    return _cardService.getCardsByIds(_player!.collection);
  }

  List<GameCard> get playerDeck {
    if (_player == null) return [];
    return _cardService.getCardsByIds(_player!.deck);
  }

  Future<void> initialize({void Function(String message)? onStep}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize services
      void Function(String) reporter = (msg) {
        _log(msg);
        if (onStep != null) onStep(msg);
      };

      reporter('Boot: starting');
      await _cardService.initialize(onStep: reporter);
      _player = await _playerService.initialize(onStep: reporter);
      _availableCards = _cardService.allCards;
      reporter(
        'Boot: assets/cards loaded = ' + _availableCards.length.toString(),
      );
    } catch (e) {
      print('Error initializing game: $e');
      _log('Error: ' + e.toString());
    }

    _isLoading = false;
    _log('Boot: done');
    notifyListeners();
  }

  List<GameCard> previewPackContents(CardPack pack) {
    return _cardService.openCardPack(pack);
  }

  Future<void> buyCardPack(CardPack pack) async {
    if (_player == null || _player!.coins < pack.cost) return;

    try {
      // Deduct coins
      _player = await _playerService.buyCardPack(pack.cost);

      // Open pack and add cards to collection
      final List<GameCard> newCards = _cardService.openCardPack(pack);

      for (final card in newCards) {
        _player = await _playerService.addCardToCollection(card.id);
      }

      notifyListeners();
    } catch (e) {
      print('Error buying card pack: $e');
    }
  }

  Future<List<GameCard>> buyAndOpenCardPack(CardPack pack) async {
    if (_player == null || _player!.coins < pack.cost) return [];

    try {
      // Get the cards that will be opened BEFORE buying
      final List<GameCard> newCards = _cardService.openCardPack(pack);

      // Deduct coins
      _player = await _playerService.buyCardPack(pack.cost);

      // Add cards to collection
      for (final card in newCards) {
        _player = await _playerService.addCardToCollection(card.id);
      }

      notifyListeners();
      return newCards;
    } catch (e) {
      print('Error buying card pack: $e');
      return [];
    }
  }

  Future<void> updateDeck(List<String> newDeck) async {
    if (_player == null) return;

    try {
      _player = await _playerService.updateDeck(newDeck);
      notifyListeners();
    } catch (e) {
      print('Error updating deck: $e');
    }
  }

  List<CardPack> getAvailablePacks() {
    return _cardService.getAvailablePacks();
  }

  GameCard? getCardById(String id) {
    return _cardService.getCardById(id);
  }

  Future<void> resetPlayer() async {
    try {
      await _playerService.resetPlayer();
      _player = _playerService.currentPlayer;
      notifyListeners();
    } catch (e) {
      print('Error resetting player: $e');
    }
  }

  // Battle related methods (placeholder for future implementation)
  Future<void> startBattle() async {
    // TODO: Implement battle system
    print('Battle system not yet implemented');
  }
}
