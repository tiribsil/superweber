import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

// Change 'void' to 'Future<void>' and add 'return'
Future<void> showHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.psychology, color: theme.colorScheme.primary, size: 28),
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
      content: SingleChildScrollView(
        child: Text(
          l10n.helpText,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}