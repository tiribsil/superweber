import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../game/presentation/widgets/gameplay_tutorial_widget.dart';

// Change 'void' to 'Future<void>' and add 'return'
Future<void> showHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.85;
      return Dialog(
        constraints: BoxConstraints(maxWidth: 580, maxHeight: maxHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.helpTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Flexible(
                child: SingleChildScrollView(
                  child: GameplayTutorialWidget(isDialog: true),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
