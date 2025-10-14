import 'package:flutter_riverpod/flutter_riverpod.dart';

final delayProvider = Provider<DelayUtil>((ref) => DelayUtil());

class DelayUtil {
  Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }
}

// Usage example:
// final delay = ref.read(delayProvider);
// await delay.delay(Duration(seconds: 5));
