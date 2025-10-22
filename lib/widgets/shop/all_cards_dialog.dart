import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' hide Consumer;
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/game_provider.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';

class AllCardsDialog extends HookConsumerWidget {
  const AllCardsDialog({
    Key? key,
    required this.gameProvider,
    required this.showBack,
  }) : super(key: key);

  final GameProvider gameProvider;
  final ValueNotifier<bool> showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'All Available Cards',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          controller: scrollController,
          children: CardRarity.values.map((rarity) {
            final cardsOfRarity = gameProvider.availableCards
                .where((card) => card.rarity == rarity)
                .toList();

            if (cardsOfRarity.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    rarity.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0, // horizontal spacing
                  runSpacing: 8.0, // vertical spacing
                  children: cardsOfRarity.map((card) {
                    return CardWidget(
                      card: card,
                      width: 100,
                      height: 220,
                      showBack: showBack,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
