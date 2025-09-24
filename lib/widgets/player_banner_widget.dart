import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico_card/widgets/pixel_theme.dart';
import 'package:pixelarticons/pixel.dart';

class PlayerBannerWidget extends ConsumerWidget {
  final double width;
  final double height;
  final String name;
  final int money;

  const PlayerBannerWidget({
    super.key,
    this.width = 100.0,
    this.height = 50.0,
    required this.name,
    required this.money,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            child: Image.asset(
              "assets/images/player_name_banner.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Pixel.user, size: 45, color: PixelTheme.brokenColor),
                Text(name, style: PixelTheme.pixelText(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
