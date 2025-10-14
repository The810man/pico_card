import 'package:flutter/material.dart';

class InfiniteStripedBackground extends StatefulWidget {
  final bool isRed;
  const InfiniteStripedBackground({super.key, this.isRed = false});

  @override
  _InfiniteStripedBackgroundState createState() =>
      _InfiniteStripedBackgroundState();
}

class _InfiniteStripedBackgroundState extends State<InfiniteStripedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double tileWidth = 810;
  final double tileHeight = 810;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRed = widget.isRed;

    final screenSize = MediaQuery.of(context).size;

    final horizontalTiles = (screenSize.width / tileWidth).ceil() + 1;
    final verticalTiles = (screenSize.height / tileHeight).ceil() + 1;

    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      body: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double offsetX = (_controller.value * tileWidth) % tileWidth;
            double offsetY = (_controller.value * tileHeight) % tileHeight;

            return SizedBox(
              width: horizontalTiles * tileWidth,
              height: verticalTiles * tileHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Transform.translate(
                    offset: Offset(-offsetX, -offsetY),
                    child: Column(
                      children: List.generate(verticalTiles, (row) {
                        return Row(
                          children: List.generate(horizontalTiles, (col) {
                            return SizedBox(
                              width: tileWidth,
                              height: tileHeight,
                              child: Image.asset(
                                filterQuality: FilterQuality.none,
                                isRed
                                    ? 'assets/images/stripedBgPink.png'
                                    : 'assets/images/stripedBgBlack.png',
                                fit: BoxFit.cover,
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
