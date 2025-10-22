import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pico_card/models/card_model.dart';
import 'package:pico_card/services/providers/battle_provider.dart';
import 'package:pico_card/services/battle_animation_controller.dart';
import 'package:pico_card/widgets/cards/card_stats_widget.dart';
import 'package:pico_card/widgets/cards/card_widget.dart';

class HoverableCardHolder extends HookConsumerWidget {
  final GameCard? initialCard;
  // Optional slot index this holder represents (0..2). When provided and the
  // slot is empty, drops will place the card specifically into this slot.
  final int? slotIndex;
  const HoverableCardHolder({super.key, this.initialCard, this.slotIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> isHovering = useState(false);
    final ValueNotifier<GameCard?> selectedCard = useState(initialCard);
    final ValueNotifier<bool> showBack = useState(false);
    final ValueNotifier<bool> canUpgradeHover = useState(false);
    final ValueNotifier<bool> canReplaceHover = useState(false);

    // Pulse animation when card is selected for attack
    final AnimationController pulseCtrl = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final Animation<double> pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut));

    // Get the current battle state to check for card updates
    final battle = ref.watch(battleProvider);
    final battleController = ref.watch(battleProvider.notifier);

    // No longer syncing with battle state here, as initialCard is passed in
    // and onAcceptWithDetails updates selectedCard.

    // Drive pulse animation only while in attack mode for this selected card
    useEffect(
      () {
        final bool shouldPulse =
            battle.attackMode &&
            selectedCard.value != null &&
            !selectedCard.value!.isTapped;
        if (shouldPulse) {
          pulseCtrl.repeat(reverse: true);
        } else {
          pulseCtrl.stop();
          pulseCtrl.reset();
        }
        return null;
      },
      [battle.attackMode, selectedCard.value?.id, selectedCard.value?.isTapped],
    );

    useEffect(
      () {
        final card = selectedCard.value;

        if (card == null) return null;
        showBack.value = card.isTapped;
        // Runs when the selected card itself changes or when its `health` changes.
        // Replace this body with whatever side-effect you need.
        if (card.health <= 0) {
          // example action: clear the selection when card dies
          selectedCard.value = null;
          showBack.value = false;
        } else {
          // example action: log the new health
          debugPrint('Selected card ${card.id} health: ${card.health}');
        }
        return null;
      },
      [
        selectedCard.value?.id,
        selectedCard.value?.health,
        selectedCard.value?.isTapped,
      ],
    );

    // Keep the locally selected placed-card in sync with provider updates
    // (e.g., untap at start of turn, stat changes, etc.)
    useEffect(() {
      final sel = selectedCard.value;
      if (sel == null) return null;

      final placedList = ref.read(battleProvider).cardPlacedListPlayer;
      final idx = placedList.indexWhere((c) => c.id == sel.id);
      if (idx == -1) {
        // Card was removed (died/replaced)
        selectedCard.value = null;
        showBack.value = false;
      } else {
        final latest = placedList[idx];
        if (!identical(latest, sel)) {
          selectedCard.value = latest;
        }
        showBack.value = latest.isTapped;
      }
      return null;
    }, [battle.cardPlacedListPlayer, selectedCard.value?.id]);

    // Slot-based sync: ensure this holder shows the card that currently belongs to its slot
    useEffect(() {
      if (slotIndex == null) return null;

      final placedList = ref.read(battleProvider).cardPlacedListPlayer;
      final mapping = ref.read(battleProvider).playerSlotIndex;

      GameCard? atSlot;
      for (final c in placedList) {
        final idx = mapping[c.id];
        if (idx == slotIndex) {
          atSlot = c;
          break;
        }
      }

      final current = selectedCard.value;
      if (atSlot?.id != current?.id) {
        selectedCard.value = atSlot;
        showBack.value = atSlot?.isTapped ?? false;
      } else if (atSlot != null) {
        // keep flip state in sync with tap state
        showBack.value = atSlot.isTapped;
      }
      return null;
    }, [battle.cardPlacedListPlayer, battle.playerSlotIndex, slotIndex]);

    return DragTarget<GameCard>(
      onWillAcceptWithDetails: (details) {
        isHovering.value = true;

        final incoming = details.data;
        final battleState = ref.read(battleProvider);
        final placed = selectedCard.value;

        // Slot empty: accept if we can place (basic cost check)
        if (placed == null) {
          final canPlace =
              battleState.playerMana >= incoming.cost &&
              battleState.cardPlacedListPlayer.length < 3;
          canUpgradeHover.value = false;
          return canPlace;
        }

        // Slot occupied: check for upgrade or replace
        final currentStars = battleState.starLevels[placed.id] ?? 0;
        final upgradeCost = incoming.cost + currentStars + 1;

        final base = ref.read(battleProvider.notifier);
        final bool baseMatch =
            base.baseIdOf(placed.id) == base.baseIdOf(incoming.id);
        final bool canUpg =
            baseMatch &&
            currentStars < 5 &&
            battleState.playerMana >= upgradeCost;

        // Can replace if it's a different card and player can afford it
        final bool canReplace =
            !baseMatch && battleState.playerMana >= incoming.cost;

        canUpgradeHover.value = canUpg;
        canReplaceHover.value = canReplace; // Set this for visual feedback
        return canUpg || canReplace;
      },
      onLeave: (data) {
        isHovering.value = false;
        canUpgradeHover.value = false;
      },
      onAcceptWithDetails: (details) {
        final incoming = details.data;
        final placed = selectedCard.value;

        // Claim this drop to prevent double-processing by multiple DragTargets
        if (!battleController.claimDrag(incoming.id)) {
          return;
        }

        isHovering.value = false;
        canUpgradeHover.value = false; // Clear hover state
        canReplaceHover.value = false; // Clear hover state

        if (placed != null) {
          // Check if it's an upgrade or a replacement
          final base = ref.read(battleProvider.notifier);
          final bool baseMatch =
              base.baseIdOf(placed.id) == base.baseIdOf(incoming.id);

          if (baseMatch) {
            // Attempt upgrade path (already validated in onWillAccept)
            battleController.upgradeCard(placed, incoming);
            // Slot-based sync effect will refresh the shown card/states.
          } else {
            // Attempt replace path (already validated in onWillAccept)
            battleController.replaceCard(placed, incoming);
            // Slot-based sync effect will pick up the new placed id for this slot.
          }
          // Release drag claim now that handling is complete for upgrade/replace
          battleController.releaseDrag(incoming.id);
          return;
        }

        // Placement path for empty slot
        // Remove the dragged library card now (id-based, safe if already removed)
        battleController.removeCardFromLibary(incoming);
        battleController.usePlayerMana(incoming.cost);

        // If this holder represents a concrete slot, place exactly there.
        // Otherwise fall back to default append placement.
        if (slotIndex != null) {
          battleController.placeCardAtSlot(incoming, slotIndex!);
        } else {
          battleController.addCardToPlayerPlaced(incoming);
        }

        // Release drag claim after successful placement
        battleController.releaseDrag(incoming.id);

        // Do not set local selectedCard here.
        // Let the parent row rebuild and supply the placed card for this slot
        // to avoid rendering the same card twice (local + parent-driven).
      },
      builder:
          (
            BuildContext context,
            List<dynamic> accepted,
            List<dynamic> rejected,
          ) {
            return Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: 105,
                  child: selectedCard.value == null
                      ? Image.asset(
                          isHovering.value
                              ? "assets/UI/CardHoverFrame.gif"
                              : "assets/UI/CardHoverFrame.png",
                          filterQuality: FilterQuality.none,
                          fit: BoxFit.contain,
                        )
                      : AnimatedBuilder(
                          animation: pulseCtrl,
                          builder: (context, child) {
                            final bool pulsing =
                                battle.attackMode &&
                                selectedCard.value != null &&
                                !selectedCard.value!.isTapped;
                            final double scale = pulsing
                                ? pulseScale.value
                                : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: CardWidget(
                                card: selectedCard.value!,
                                showBack: showBack,
                                showHealth: true,
                                isPlaced: true,
                                showStats: true,
                                stars:
                                    (battle.starLevels[selectedCard
                                        .value!
                                        .id] ??
                                    0),
                                onAttack: () {
                                  // Handle attack logic with animation
                                  final card = selectedCard.value!;
                                  if (card.isTapped) return;

                                  // Start attack mode instead of direct attack
                                  battleController.startAttackMode(card);
                                },
                              ),
                            );
                          },
                        ),
                ),
                if (isHovering.value &&
                    selectedCard.value != null &&
                    canUpgradeHover.value)
                  Center(
                    child: NesPulser(
                      child: Icon(
                        Icons.star,
                        color: Colors.greenAccent,
                        size: 28,
                      ),
                    ),
                  ),
                if (isHovering.value &&
                    selectedCard.value != null &&
                    canReplaceHover.value)
                  Center(
                    child: NesPulser(
                      child: Icon(
                        Icons.swap_horiz, // Icon for replacement
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            );
          },
    );
  }
}
