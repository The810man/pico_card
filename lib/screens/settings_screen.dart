import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/services/providers/settings_provider.dart';
import 'package:pico_card/services/audio_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider).state;
    final settingsController = ref.watch(settingsProvider.notifier);
    final audioRepo = AudioRepository();

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: NesContainer(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 8),
              NesContainer(
                backgroundColor: const Color(0xFF1D2B53),
                child: Column(
                  children: [
                    // Player Name Setting
                    _buildSettingRow(
                      title: 'Player Name',
                      child: SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF1D2B53),
                          ),
                          style: const TextStyle(color: Colors.white),
                          controller: TextEditingController(
                            text: settingsState.playerName,
                          ),
                          onChanged: (value) =>
                              settingsController.setPlayerName(value),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white30),

                    // Google Play Games Connection
                    _buildSettingRow(
                      title: 'Google Play Games',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            child: Text(
                              settingsState.isGooglePlayConnected
                                  ? (settingsState.googlePlayAccountName ??
                                        'Connected')
                                  : 'Not Connected',
                              style: const TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          NesButton.text(
                            type: settingsState.isGooglePlayConnected
                                ? NesButtonType.warning
                                : NesButtonType.success,
                            text: settingsState.isGooglePlayConnected
                                ? 'Disconnect'
                                : 'Connect',
                            onPressed: () async {
                              if (settingsState.isGooglePlayConnected) {
                                await settingsController
                                    .disconnectGooglePlayAccount();
                              } else {
                                await settingsController
                                    .connectGooglePlayAccount();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Audio Section
              _buildSectionTitle('Audio'),
              const SizedBox(height: 8),
              NesContainer(
                backgroundColor: const Color(0xFF1D2B53),
                child: Column(
                  children: [
                    // Sound Effects
                    _buildSettingRow(
                      title: 'Sound Effects',
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Switch(
                            value: settingsState.soundEffectsEnabled,
                            onChanged: (value) {
                              settingsController.setSoundEffectsEnabled(value);
                              audioRepo.setMute(AudioType.fx, !value);
                            },
                            activeColor: Colors.greenAccent,
                          ),
                          SizedBox(
                            width: 160,
                            child: Slider(
                              value: settingsState.soundEffectsVolume,
                              onChanged: (value) {
                                settingsController.setSoundEffectsVolume(value);
                                audioRepo.setVolume(AudioType.fx, value);
                              },
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.greenAccent,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white30),

                    // Music
                    _buildSettingRow(
                      title: 'Music',
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Switch(
                            value: settingsState.musicEnabled,
                            onChanged: (value) {
                              settingsController.setMusicEnabled(value);
                              audioRepo.setMute(AudioType.music, !value);
                            },
                            activeColor: Colors.greenAccent,
                          ),
                          SizedBox(
                            width: 160,
                            child: Slider(
                              value: settingsState.musicVolume,
                              onChanged: (value) {
                                settingsController.setMusicVolume(value);
                                audioRepo.setVolume(AudioType.music, value);
                              },
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.greenAccent,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white30),

                    // UI Sounds
                    _buildSettingRow(
                      title: 'UI Sounds',
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Switch(
                            value: settingsState.uiSoundsEnabled,
                            onChanged: (value) {
                              settingsController.setUISoundsEnabled(value);
                              audioRepo.setMute(AudioType.ui, !value);
                            },
                            activeColor: Colors.greenAccent,
                          ),
                          SizedBox(
                            width: 160,
                            child: Slider(
                              value: settingsState.uiSoundsVolume,
                              onChanged: (value) {
                                settingsController.setUISoundsVolume(value);
                                audioRepo.setVolume(AudioType.ui, value);
                              },
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.greenAccent,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Game Section
              _buildSectionTitle('Game'),
              const SizedBox(height: 8),
              NesContainer(
                backgroundColor: const Color(0xFF1D2B53),
                child: Column(
                  children: [
                    _buildSettingRow(
                      title: 'Reset Progress',
                      child: NesButton.text(
                        type: NesButtonType.error,
                        text: 'Reset All Data',
                        onPressed: () {
                          _showResetConfirmationDialog(
                            context,
                            settingsController,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Version Info
              Center(
                child: Text(
                  'Pico Card TCG v0.0.1',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingRow({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(
    BuildContext context,
    SettingsProvider settingsController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to reset all progress? This will delete all cards, coins, and progress.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement reset functionality
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reset functionality not yet implemented',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
