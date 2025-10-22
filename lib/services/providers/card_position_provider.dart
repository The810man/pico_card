import 'dart:ui' show Rect, Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardPositionNotifier extends StateNotifier<Map<String, Rect>> {
  CardPositionNotifier() : super(const {});

  void updateCardRect(String cardId, Rect rect) {
    // Only update if significantly changed to avoid rebuild churn
    final prev = state[cardId];
    if (prev != null) {
      final dx = (prev.left - rect.left).abs();
      final dy = (prev.top - rect.top).abs();
      final dw = (prev.width - rect.width).abs();
      final dh = (prev.height - rect.height).abs();
      if (dx < 0.5 && dy < 0.5 && dw < 0.5 && dh < 0.5) {
        return;
      }
    }
    state = {...state, cardId: rect};
  }

  void removeCard(String cardId) {
    if (!state.containsKey(cardId)) return;
    final next = {...state}..remove(cardId);
    state = next;
  }

  Rect? rectOf(String cardId) => state[cardId];

  Offset? centerOf(String cardId) {
    final r = state[cardId];
    return r?.center;
  }

  bool has(String cardId) => state.containsKey(cardId);
}

final cardPositionProvider =
    StateNotifierProvider<CardPositionNotifier, Map<String, Rect>>(
      (ref) => CardPositionNotifier(),
    );
