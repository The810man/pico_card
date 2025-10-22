import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String? googlePlayAccountName;
  final bool isGooglePlayConnected;
  final bool soundEffectsEnabled;
  final bool musicEnabled;
  final bool uiSoundsEnabled;
  final double soundEffectsVolume;
  final double musicVolume;
  final double uiSoundsVolume;
  final String playerName;

  SettingsState({
    this.googlePlayAccountName,
    this.isGooglePlayConnected = false,
    this.soundEffectsEnabled = true,
    this.musicEnabled = true,
    this.uiSoundsEnabled = true,
    this.soundEffectsVolume = 1.0,
    this.musicVolume = 1.0,
    this.uiSoundsVolume = 1.0,
    this.playerName = 'Player',
  });

  SettingsState copyWith({
    String? googlePlayAccountName,
    bool? isGooglePlayConnected,
    bool? soundEffectsEnabled,
    bool? musicEnabled,
    bool? uiSoundsEnabled,
    double? soundEffectsVolume,
    double? musicVolume,
    double? uiSoundsVolume,
    String? playerName,
  }) {
    return SettingsState(
      googlePlayAccountName:
          googlePlayAccountName ?? this.googlePlayAccountName,
      isGooglePlayConnected:
          isGooglePlayConnected ?? this.isGooglePlayConnected,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      uiSoundsEnabled: uiSoundsEnabled ?? this.uiSoundsEnabled,
      soundEffectsVolume: soundEffectsVolume ?? this.soundEffectsVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      uiSoundsVolume: uiSoundsVolume ?? this.uiSoundsVolume,
      playerName: playerName ?? this.playerName,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  SettingsState _state = SettingsState();
  SharedPreferences? _prefs;

  SettingsState get state => _state;

  SettingsProvider() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _prefs = await SharedPreferences.getInstance();

    _state = SettingsState(
      googlePlayAccountName: _prefs?.getString('googlePlayAccountName'),
      isGooglePlayConnected: _prefs?.getBool('isGooglePlayConnected') ?? false,
      soundEffectsEnabled: _prefs?.getBool('soundEffectsEnabled') ?? true,
      musicEnabled: _prefs?.getBool('musicEnabled') ?? true,
      uiSoundsEnabled: _prefs?.getBool('uiSoundsEnabled') ?? true,
      soundEffectsVolume: _prefs?.getDouble('soundEffectsVolume') ?? 1.0,
      musicVolume: _prefs?.getDouble('musicVolume') ?? 1.0,
      uiSoundsVolume: _prefs?.getDouble('uiSoundsVolume') ?? 1.0,
      playerName: _prefs?.getString('playerName') ?? 'Player',
    );

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    if (_prefs == null) return;

    await _prefs!.setString(
      'googlePlayAccountName',
      _state.googlePlayAccountName ?? '',
    );
    await _prefs!.setBool(
      'isGooglePlayConnected',
      _state.isGooglePlayConnected,
    );
    await _prefs!.setBool('soundEffectsEnabled', _state.soundEffectsEnabled);
    await _prefs!.setBool('musicEnabled', _state.musicEnabled);
    await _prefs!.setBool('uiSoundsEnabled', _state.uiSoundsEnabled);
    await _prefs!.setDouble('soundEffectsVolume', _state.soundEffectsVolume);
    await _prefs!.setDouble('musicVolume', _state.musicVolume);
    await _prefs!.setDouble('uiSoundsVolume', _state.uiSoundsVolume);
    await _prefs!.setString('playerName', _state.playerName);
  }

  // Google Play Games integration
  Future<void> connectGooglePlayAccount() async {
    try {
      // TODO: Implement Google Play Games sign-in
      // For now, simulate connection
      _state = _state.copyWith(
        googlePlayAccountName: 'Gamer123',
        isGooglePlayConnected: true,
      );
      await _saveSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to connect Google Play account: $e');
    }
  }

  Future<void> disconnectGooglePlayAccount() async {
    _state = _state.copyWith(
      googlePlayAccountName: null,
      isGooglePlayConnected: false,
    );
    await _saveSettings();
    notifyListeners();
  }

  // Audio settings
  void setSoundEffectsEnabled(bool enabled) {
    _state = _state.copyWith(soundEffectsEnabled: enabled);
    _saveSettings();
    notifyListeners();
  }

  void setMusicEnabled(bool enabled) {
    _state = _state.copyWith(musicEnabled: enabled);
    _saveSettings();
    notifyListeners();
  }

  void setUISoundsEnabled(bool enabled) {
    _state = _state.copyWith(uiSoundsEnabled: enabled);
    _saveSettings();
    notifyListeners();
  }

  void setSoundEffectsVolume(double volume) {
    _state = _state.copyWith(soundEffectsVolume: volume);
    _saveSettings();
    notifyListeners();
  }

  void setMusicVolume(double volume) {
    _state = _state.copyWith(musicVolume: volume);
    _saveSettings();
    notifyListeners();
  }

  void setUISoundsVolume(double volume) {
    _state = _state.copyWith(uiSoundsVolume: volume);
    _saveSettings();
    notifyListeners();
  }

  void setPlayerName(String name) {
    _state = _state.copyWith(playerName: name);
    _saveSettings();
    notifyListeners();
  }
}

// Riverpod provider for settings
final settingsProvider = ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider();
});
