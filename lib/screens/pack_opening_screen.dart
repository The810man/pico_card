import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../services/game_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/pixel_theme.dart';
import '../screens/collection_screen.dart';

class PackOpeningScreen extends StatefulWidget {
  final CardPack pack;
  final List<GameCard> openedCards;

  const PackOpeningScreen({
    Key? key,
    required this.pack,
    required this.openedCards,
  }) : super(key: key);

  @override
  State<PackOpeningScreen> createState() => _PackOpeningScreenState();
}

class _PackOpeningScreenState extends State<PackOpeningScreen>
    with TickerProviderStateMixin {
  late AnimationController _smashController;
  late AnimationController _shakeController;
  late AnimationController _cardRevealController;
  late AnimationController _cardSwipeController;

  late Animation<double> _smashAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _cardRevealAnimation;
  late Animation<Offset> _cardSwipeAnimation;

  int _currentCardIndex = 0;
  int _smashCount = 0;
  bool _isSmashing = false;
  bool _packOpened = false;
  bool _showingCards = false;
  bool _showingAllCards = false;

  @override
  void initState() {
    super.initState();

    _smashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _cardRevealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardSwipeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _smashAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _smashController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );

    _cardRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardRevealController, curve: Curves.elasticOut),
    );

    _cardSwipeAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardSwipeController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _smashController.dispose();
    _shakeController.dispose();
    _cardRevealController.dispose();
    _cardSwipeController.dispose();
    super.dispose();
  }

  void _smashPack() async {
    if (_isSmashing || _packOpened) return;

    setState(() {
      _isSmashing = true;
      _smashCount++;
    });

    await _smashController.forward();
    await _smashController.reverse();

    await _shakeController.forward();
    await _shakeController.reverse();

    if (_smashCount >= 5) {
      setState(() {
        _packOpened = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _startCardReveal();
    } else {
      setState(() {
        _isSmashing = false;
      });
    }
  }

  void _startCardReveal() async {
    setState(() {
      _showingCards = true;
    });

    await _cardRevealController.forward();
    await _cardSwipeController.forward();
  }

  void _nextCard() async {
    if (_currentCardIndex < widget.openedCards.length - 1) {
      await _cardSwipeController.reverse();
      setState(() {
        _currentCardIndex++;
      });
      await _cardSwipeController.forward();
    } else {
      _showAllCards();
    }
  }

  void _previousCard() async {
    if (_currentCardIndex > 0) {
      await _cardSwipeController.reverse();
      setState(() {
        _currentCardIndex--;
      });
      await _cardSwipeController.forward();
    }
  }

  void _showAllCards() {
    setState(() {
      _showingAllCards = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelTheme.uiBoxBg,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PixelTheme.pixelBlack,
                PixelTheme.pixelGray,
                PixelTheme.pixelBlack,
              ],
            ),
          ),
          child: _showingAllCards
              ? _buildAllCardsView()
              : _showingCards
              ? _buildCardRevealView()
              : _buildPackView(),
        ),
      ),
    );
  }

  Widget _buildPackView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'OPENING ${widget.pack.name.toUpperCase()}',
            style: PixelTheme.pixelTextBold(
              color: PixelTheme.pixelYellow,
              fontSize: 20,
            ),
          ),
        ),

        // Instruction
        if (!_packOpened)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'TAP TO SMASH ${3 - _smashCount} MORE TIMES!',
              style: PixelTheme.pixelText(
                color: PixelTheme.pixelWhite,
                fontSize: 14,
              ),
            ),
          ),

        // Pack box
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _smashPack,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _smashController,
                  _shakeController,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Transform.scale(
                      scale: _smashAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: PixelTheme.pixelContainer(
                          color: _getCrackColor(),
                          borderColor: PixelTheme.pixelYellow,
                          borderWidth: 4,
                        ),
                        child: Stack(
                          children: [
                            // Pack contents
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Pixel.gift,
                                    size: 80,
                                    color: PixelTheme.pixelYellow,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.pack.name,
                                    style: PixelTheme.pixelTextBold(
                                      color: PixelTheme.pixelWhite,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Crack effects
                            if (_smashCount > 0) _buildCracks(),
                            // Explosion effect when opened
                            if (_packOpened) _buildExplosion(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 20,
                height: 20,
                decoration: PixelTheme.pixelContainer(
                  color: index < _smashCount
                      ? PixelTheme.pixelRed
                      : PixelTheme.pixelGray,
                  borderColor: PixelTheme.pixelWhite,
                ),
                child: index < _smashCount
                    ? const Icon(Pixel.close, size: 16, color: Colors.white)
                    : null,
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _getCrackColor() {
    switch (_smashCount) {
      case 0:
        return PixelTheme.pixelGray;
      case 1:
        return PixelTheme.pixelLightGray;
      case 2:
        return PixelTheme.pixelRed;
      default:
        return PixelTheme.pixelBlack;
    }
  }

  Widget _buildCracks() {
    switch (_smashCount) {
      case 0:
        return Image.asset("assets/images/box_anim/closed_box_0.gif");
      case 1:
        return Image.asset("assets/images/box_anim/closed_box_1.gif");
      case 2:
        return Image.asset("assets/images/box_anim/closed_box_2.gif");
      case 3:
        return Image.asset("assets/images/box_anim/closed_box_3.gif");
      case 4:
        return Image.asset("assets/images/box_anim/closed_box_4.gif");
      case 5:
        return Image.asset("assets/images/box_anim/opened_box.gif");
      default:
        return Image.asset("assets/images/box_anim/closed_box_0.gif");
    }
  }

  Widget _buildExplosion() {
    return Container(
      decoration: BoxDecoration(
        color: PixelTheme.pixelYellow.withOpacity(0.3),
        border: Border.all(color: PixelTheme.pixelYellow, width: 2),
      ),
    );
  }

  Widget _buildCardRevealView() {
    final currentCard = widget.openedCards[_currentCardIndex];

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'CARD ${_currentCardIndex + 1} OF ${widget.openedCards.length}',
            style: PixelTheme.pixelTextBold(
              color: PixelTheme.pixelYellow,
              fontSize: 20,
            ),
          ),
        ),

        // Card reveal
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _cardRevealController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardRevealAnimation.value,
                  child: SlideTransition(
                    position: _cardSwipeAnimation,
                    child: CardWidget(
                      card: currentCard,
                      width: 250,
                      height: 350,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Card navigation
        Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentCardIndex > 0)
                PixelButton(
                  text: 'PREVIOUS',
                  icon: Pixel.arrowleft,
                  color: PixelTheme.pixelBlue,
                  onPressed: _previousCard,
                ),

              if (_currentCardIndex < widget.openedCards.length - 1)
                PixelButton(
                  text: 'NEXT',
                  icon: Pixel.arrowright,
                  color: PixelTheme.pixelGreen,
                  onPressed: _nextCard,
                )
              else
                PixelButton(
                  text: 'VIEW ALL',
                  icon: Icons.grid_view,
                  color: PixelTheme.pixelPurple,
                  onPressed: _showAllCards,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCardsView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'YOUR NEW CARDS!',
            style: PixelTheme.pixelTextBold(
              color: PixelTheme.pixelYellow,
              fontSize: 24,
            ),
          ),
        ),

        // Cards grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.openedCards.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: CardWidget(
                        card: widget.openedCards[index],
                        width: 150,
                        height: 200,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Go to Collection button
        Padding(
          padding: const EdgeInsets.all(32),
          child: PixelButton(
            text: 'GO TO COLLECTION',
            icon: Pixel.imagemultiple,
            color: PixelTheme.pixelGreen,
            width: 250,
            height: 60,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CollectionScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CrackPainter extends CustomPainter {
  final int crackLevel;

  CrackPainter(this.crackLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PixelTheme.pixelRed
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Fixed seed for consistent cracks

    // Draw cracks based on level
    for (int i = 0; i < crackLevel * 2; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + (random.nextDouble() - 0.5) * 50;
      final endY = startY + (random.nextDouble() - 0.5) * 50;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX.clamp(0, size.width), endY.clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CrackPainter && oldDelegate.crackLevel != crackLevel;
  }
}
