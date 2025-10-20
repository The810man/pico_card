import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;
import 'package:pico_card/services/game_provider.dart';
import 'package:provider/provider.dart' show Consumer;

class RewardedAdButton extends HookConsumerWidget {
  const RewardedAdButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = useState(0);
    final isLoading = useState(false);
    final rewardedAd = useState<RewardedAd?>(null);

    void loadAd() {
      isLoading.value = true;
      RewardedAd.load(
        adUnitId: 'ca-app-pub-3245865506682845/1308330976', // Test-ID
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            rewardedAd.value = ad;
            isLoading.value = false;
          },
          onAdFailedToLoad: (err) {
            rewardedAd.value = null;
            isLoading.value = false;
            debugPrint('Failed to load ad: $err');
          },
        ),
      );
    }

    useEffect(() {
      MobileAds.instance.initialize();
      loadAd();
      return null;
    }, []);

    void showAd() {
      final ad = rewardedAd.value;
      if (ad == null) {
        loadAd();
        return;
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadAd();
        },
      );

      ad.show(
        onUserEarnedReward: (ad, reward) {
          coins.value += 50;
        },
      );

      rewardedAd.value = null;
      isLoading.value = true;
    }

    return Consumer<GameProvider>(
      builder: (context, game, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You have ${coins.value} coins',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading.value ? null : showAd,
                child: Text(
                  isLoading.value ? 'Loading Ad...' : 'Watch Ad for 50 Coins',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
