import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../domain/models/difficulty_level.dart';
import 'controllers/game_controller.dart';
import 'widgets/mind_view.dart';
import 'widgets/street_view.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final gameNotifier = ref.read(gameControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: const [
                // Top 20% of vertical space: Street parallax view with Weber & incoming car
                Expanded(
                  flex: 2,
                  child: StreetView(),
                ),

                // Bottom 80% of vertical space: Mind of Weber with brain silhouette & plate slots
                Expanded(
                  flex: 8,
                  child: MindView(),
                ),
              ],
            ),

            // Game Over Modal Overlay
            if (gameState.isGameOver)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sentiment_very_dissatisfied, size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate('game_over'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.translate('game_over_desc'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.translate('score')}: ${gameState.score}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.translate('difficulty'),
                                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.replay),
                            label: Text(l10n.translate('restart')),
                            onPressed: () => gameNotifier.restartRun(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
