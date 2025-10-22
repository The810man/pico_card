import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';

class AttackAnimationWidget extends StatefulWidget {
  final GameCard attackingCard;
  final GameCard? targetCard;
  final Offset startPosition;
  final Offset targetPosition;
  final VoidCallback? onComplete;
  final bool isEnemyAttack;

  const AttackAnimationWidget({
    super.key,
    required this.attackingCard,
    this.targetCard,
    required this.startPosition,
    required this.targetPosition,
    this.onComplete,
    this.isEnemyAttack = false,
  });

  @override
  State<AttackAnimationWidget> createState() => _AttackAnimationWidgetState();
}

class _AttackAnimationWidgetState extends State<AttackAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Position animation - card moves to target and back
    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: widget.startPosition,
          end: widget.targetPosition,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: widget.targetPosition,
          end: widget.startPosition,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Scale animation - card grows when attacking
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(_controller);

    // Rotation animation - slight rotation for effect
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 0.0), weight: 50),
    ]).animate(_controller);

    // Small shake at impact moment to add feedback
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 35),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(4, -2)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(4, -2),
          end: const Offset(-4, 2),
        ),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-4, 2), end: Offset.zero),
        weight: 45,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
      if (mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.translate(
            offset: _shakeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: CardWidget(
                    card: widget.attackingCard,
                    showBack: ValueNotifier(false),
                    showHealth: false,
                    showStats: false,
                    isPlaced: true,
                    isEnemy: widget.isEnemyAttack,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
