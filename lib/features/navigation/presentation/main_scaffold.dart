import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'help_dialog.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _calculateSelectedIndex(BuildContext context) {
    if (location.startsWith('/settings')) return 2;
    if (location.startsWith('/records')) return 1;
    return 0; // /game
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: selectedIndex,
        height: 60,
        backgroundColor: theme.scaffoldBackgroundColor,
        color: theme.colorScheme.surfaceContainerHighest,
        buttonBackgroundColor: theme.colorScheme.primary,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(
            Icons.psychology,
            size: 28,
            color: selectedIndex == 0 ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
          Icon(
            Icons.format_list_bulleted,
            size: 28,
            color: selectedIndex == 1 ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
          Icon(
            Icons.settings,
            size: 28,
            color: selectedIndex == 2 ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
          Icon(
            Icons.help_outline,
            size: 28,
            color: theme.colorScheme.onSurface,
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/game');
              break;
            case 1:
              context.go('/records');
              break;
            case 2:
              context.go('/settings');
              break;
            case 3:
              // Help button: opens showDialog as required by specification
              showHelpDialog(context);
              break;
          }
        },
      ),
    );
  }
}
