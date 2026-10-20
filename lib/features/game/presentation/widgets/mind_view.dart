import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/difficulty_level.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/operator_token.dart';
import '../controllers/game_controller.dart';

class MindView extends ConsumerStatefulWidget {
  const MindView({super.key});

  @override
  ConsumerState<MindView> createState() => _MindViewState();
}

class _MindViewState extends ConsumerState<MindView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final gameNotifier = ref.read(gameControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Brain Silhouette & Psychic Aura Painter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BrainSilhouettePainter(
                    pulse: _pulseController.value,
                    auraColor: theme.colorScheme.primary.withValues(alpha: 0.25),
                    brainColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  ),
                );
              },
            ),
          ),

          // 2. Active Brain Interactive Content Area
          SafeArea(
            child: Column(
              children: [
                // Top control bar: Difficulty selector & Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Difficulty Dropdown
                      DropdownButton<DifficultyLevel>(
                        value: gameState.difficulty,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        items: DifficultyLevel.values.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(
                              d.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (newDiff) {
                          if (newDiff != null) {
                            gameNotifier.setDifficulty(newDiff);
                          }
                        },
                      ),

                      // Clear & Skip buttons
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: l10n.translate('clear'),
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () => gameNotifier.clearSlots(),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.skip_next, size: 18),
                            label: Text(l10n.translate('skip')),
                            onPressed: () => gameNotifier.skipPlate(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Error / Status banner
                if (gameState.lastError != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Text(
                      gameState.lastError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(flex: 1),

                // License Plate with Slots & Digits
                _buildPlateWithSlots(context, gameState, gameNotifier),

                const SizedBox(height: 14),

                // LaTeX Formula Display (Mandatory requirement)
                _buildLatexDisplay(context, gameState),

                const Spacer(flex: 2),

                // Draggable Operators Palette Tray
                _buildOperatorsTray(context, gameState),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlateWithSlots(
    BuildContext context,
    GameState state,
    GameController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSlotTarget(0, state.slots[0], controller, isOptional: true),
            _buildDigitTile(state.digits[0]),
            _buildSlotTarget(1, state.slots[1], controller, isOptional: false),
            _buildDigitTile(state.digits[1]),
            _buildSlotTarget(2, state.slots[2], controller, isOptional: false),
            _buildDigitTile(state.digits[2]),
            _buildSlotTarget(3, state.slots[3], controller, isOptional: false),
            _buildDigitTile(state.digits[3]),
            _buildSlotTarget(4, state.slots[4], controller, isOptional: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitTile(int digit) {
    return Container(
      width: 44,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEEEEE), Color(0xFFBDBDBD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$digit',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          fontFamily: 'Courier',
        ),
      ),
    );
  }

  Widget _buildSlotTarget(
    int slotIndex,
    List<OperatorToken> tokens,
    GameController controller, {
    required bool isOptional,
  }) {
    return DragTarget<OperatorToken>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        controller.addOperatorToSlot(slotIndex, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final isEmpty = tokens.isEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 60),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.purple.withValues(alpha: 0.5)
                : (isEmpty
                    ? (isOptional ? Colors.grey.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.18))
                    : Colors.purple.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered
                  ? Colors.amberAccent
                  : (isEmpty ? (isOptional ? Colors.white24 : Colors.amberAccent.withValues(alpha: 0.6)) : Colors.purpleAccent),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tokens.isEmpty
                ? [
                    if (!isOptional)
                      const Text(
                        '•',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 16),
                      ),
                  ]
                : tokens.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tok = entry.value;
                    return InkWell(
                      onTap: () => controller.removeOperatorFromSlot(slotIndex, idx),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade700,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.purpleAccent, width: 1),
                        ),
                        child: Text(
                          tok.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLatexDisplay(BuildContext context, GameState state) {
    final theme = Theme.of(context);
    final latex = state.evaluation.latex;

    return Container(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 480),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: state.evaluation.isSolved ? Colors.greenAccent : theme.colorScheme.outlineVariant,
          width: state.evaluation.isSolved ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex.isEmpty ? r'\dots' : latex,
              textStyle: TextStyle(
                fontSize: 22,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              mathStyle: MathStyle.display,
            ),
          ),
          if (state.evaluation.errorMessage != null && !state.evaluation.isSolved)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                state.evaluation.errorMessage!,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOperatorsTray(BuildContext context, GameState state) {
    final theme = Theme.of(context);
    final available = state.difficulty.availableOperators;

    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: available.map((op) {
          return Draggable<OperatorToken>(
            data: op,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  op.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildOperatorChip(context, op),
            ),
            child: _buildOperatorChip(context, op),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorChip(BuildContext context, OperatorToken op) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: op.type == OperatorType.equals
            ? Colors.amber.shade700
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: op.type == OperatorType.equals
              ? Colors.amberAccent
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        op.label,
        style: TextStyle(
          color: op.type == OperatorType.equals
              ? Colors.white
              : theme.colorScheme.onPrimaryContainer,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BrainSilhouettePainter extends CustomPainter {
  final double pulse;
  final Color auraColor;
  final Color brainColor;

  _BrainSilhouettePainter({
    required this.pulse,
    required this.auraColor,
    required this.brainColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final brainRadius = size.width * 0.38;

    // Psychic glowing aura
    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.12 + (0.10 * pulse))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(center, brainRadius * (1.0 + 0.08 * pulse), auraPaint);

    // Brain cranial outline (Weber cat head profile / brain curves)
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Curved head contour
    path.moveTo(w * 0.15, h * 0.8);
    path.quadraticBezierTo(w * 0.08, h * 0.45, w * 0.25, h * 0.25);
    // Cat ears
    path.lineTo(w * 0.20, h * 0.12);
    path.lineTo(w * 0.38, h * 0.18);
    // Head top
    path.quadraticBezierTo(w * 0.5, h * 0.14, w * 0.62, h * 0.18);
    // Right cat ear
    path.lineTo(w * 0.80, h * 0.12);
    path.lineTo(w * 0.75, h * 0.25);
    // Right contour
    path.quadraticBezierTo(w * 0.92, h * 0.45, w * 0.85, h * 0.8);

    final strokePaint = Paint()
      ..color = brainColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_BrainSilhouettePainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.auraColor != auraColor ||
      oldDelegate.brainColor != brainColor;
}
