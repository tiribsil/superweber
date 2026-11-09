import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import 'help_dialog.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  int _calculateSelectedIndex() {
    if (widget.location.startsWith('/settings')) return 2;
    if (widget.location.startsWith('/records')) return 1;
    if (widget.location.startsWith('/game')) return 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _calculateSelectedIndex();
  }

  @override
  void didUpdateWidget(covariant MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      final newIndex = _calculateSelectedIndex();
      if (_currentIndex != newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    const barHeight = 50.0;
    const iconSize = 22.0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // Responsive purely by width — allows small browser windows to adapt properly
            final isLargeScreen = availableWidth > 600;

            // Large screen: floating centered pill (500px to 650px)
            // Small screen: adapts to the available width naturally
            final targetWidth = isLargeScreen
                ? (availableWidth * 0.70).clamp(500.0, 650.0).clamp(0.0, availableWidth)
                : availableWidth;

            return Padding(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 12.0 : 4.0),
              child: Center(
                heightFactor: 1.0,
                child: SizedBox(
                  width: targetWidth,
                  child: MediaQuery(
                    data: mediaQuery.copyWith(
                      // Pass exact targetWidth so SnakeNavigationBar calculates
                      // indicator coordinates matching the actual rendered item positions
                      size: Size(targetWidth, mediaQuery.size.height),
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: IconTheme(
                      data: const IconThemeData(size: iconSize),
                      child: SnakeNavigationBar.color(
                        behaviour: SnakeBarBehaviour.floating,
                        snakeShape: SnakeShape.circle,
                        height: barHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(barHeight / 2),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.12),
                        backgroundColor: colors.surfaceContainerHighest,
                        snakeViewColor: colors.primary,
                        selectedItemColor: colors.onPrimary,
                        unselectedItemColor: colors.onSurfaceVariant,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        currentIndex: _currentIndex,
                        onTap: (index) async {
                          if (index == 3) {
                            if (_currentIndex == 3) return;

                            setState(() {
                              _currentIndex = 3;
                            });

                            await showHelpDialog(context);

                            if (mounted) {
                              setState(() {
                                _currentIndex = _calculateSelectedIndex();
                              });
                            }
                          } else {
                            setState(() {
                              _currentIndex = index;
                            });

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
                            }
                          }
                        },
                        items: [
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.psychology, size: iconSize),
                            label: l10n.play,
                            tooltip: l10n.play,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.format_list_bulleted, size: iconSize),
                            label: l10n.recordsTitle,
                            tooltip: l10n.recordsTitle,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.settings, size: iconSize),
                            label: l10n.settings,
                            tooltip: l10n.settings,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.help_outline, size: iconSize),
                            label: l10n.help,
                            tooltip: l10n.help,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}