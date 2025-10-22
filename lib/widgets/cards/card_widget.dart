import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/utils/painters/pixel_pattern_painter.dart';
import 'package:pico_card/widgets/cards/card_content_widget.dart';
import 'package:pico_card/widgets/cards/card_dialog_info_widget.dart';
import 'package:pico_card/widgets/cards/flip_card_widget.dart';
import 'package:pixelarticons/pixel.dart';
import '../../models/card_model.dart';
import '../../utils/consts/pixel_theme.dart';
import 'dart:ui' show Rect, Offset;
import 'package:pico_card/services/providers/card_position_provider.dart';

class CardWidget extends HookConsumerWidget {
  final GameCard card;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showDetails;
  final ValueNotifier<bool> showBack;

  final bool showStats;
  final bool canAfford;
  final bool showHealth;
  final bool isTapped;
  final bool isPlaced;
  final bool isEnemy;
  final int stars;
  final VoidCallback? onAttack;

  CardWidget({
    super.key,
    required this.card,
    required this.showBack,
    this.isSelected = false,
    this.onTap,
    this.width,
    this.height,
    this.showDetails = true,
    this.showStats = false,
    this.canAfford = false,
    this.showHealth = false,
    this.isTapped = true,
    this.isPlaced = false,
    this.isEnemy = false,
    this.stars = 0,
    this.onAttack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnimationController controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final ValueNotifier<bool> isHovered = useState(false);

    // Track this card's on-screen rect for precise attack animations
    final globalKey = useMemoized(() => GlobalKey());
    void _updateRect() {
      final ctx = globalKey.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;

      // Compute coordinates relative to the app's overlay so that
      // Positioned(left/top) inside the dialog Stack aligns exactly.
      final overlay = Navigator.of(ctx).overlay;
      final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
      if (overlayBox == null) return;

      final topLeftGlobal = box.localToGlobal(Offset.zero);
      final topLeft = overlayBox.globalToLocal(topLeftGlobal);
      final size = box.size;
      final rect = Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        size.width,
        size.height,
      );

      if (isPlaced || isEnemy) {
        ref.read(cardPositionProvider.notifier).updateCardRect(card.id, rect);
      } else {
        ref.read(cardPositionProvider.notifier).removeCard(card.id);
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
      return () {
        // Clean up when this card leaves the tree
        ref.read(cardPositionProvider.notifier).removeCard(card.id);
      };
    }, [card.id, isPlaced, isEnemy]);

    // Overlay dialog handling
    final overlayEntry = useRef<OverlayEntry?>(null);

    void showOverlayDialog() {
      if (overlayEntry.value == null) {
        overlayEntry.value = OverlayEntry(
          builder: (context) => Center(
            child: Positioned(
              child: Material(
                color: Colors.transparent,
                child: NesDialog(
                  showCloseButton: false,
                  child: CardDialogInfoWidget(card: card),
                ),
              ),
            ),
          ),
        );
        Overlay.of(context).insert(overlayEntry.value!);
      }
    }

    void removeOverlayDialog() {
      overlayEntry.value?.remove();
      overlayEntry.value = null;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        key: globalKey,
        color: const Color.fromARGB(0, 112, 112, 112),
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTap,
          onLongPressStart: (_) {
            // Disable long-press details/flip for enemy cards
            if (isEnemy) return;

            if (isPlaced && isTapped) {
              showBack.value = false;
            }
            isHovered.value = true;
            controller.forward();

            showOverlayDialog();
          },
          onLongPressEnd: (_) {
            // Disable long-press details/flip for enemy cards
            if (isEnemy) return;

            if (isPlaced && isTapped) {
              showBack.value = true;
            }
            isHovered.value = false;
            controller.reverse();

            removeOverlayDialog();
          },
          onLongPressCancel: () {
            // Disable long-press details/flip for enemy cards
            if (isEnemy) return;

            if (isPlaced && isTapped) {
              showBack.value = true;
            }
            isHovered.value = false;
            controller.reverse();

            removeOverlayDialog();
          },
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              // Defer provider updates to post-frame to avoid modifying providers during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateRect();
              });
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: CardContentWidget(
                  card: card,
                  showBack: showBack,
                  showHealth: showHealth,
                  showStats: showStats,
                  canAfford: canAfford,
                  isEnemy: isEnemy,
                  stars: stars,
                  onAttack: onAttack,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
