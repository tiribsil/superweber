import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_localizations.dart';

/// A 2x2 grid tutorial widget that visually explains SuperWeber's gameplay mechanics:
/// 1. Turn numbers into a correct equation to destroy the car.
/// 2. Drag operators between numbers to change the equation.
/// 3. Solve the equation before the car hits Weber.
/// 4. Destroy as many cars as possible to achieve a high score!
class GameplayTutorialWidget extends StatelessWidget {
  final bool isDialog;

  const GameplayTutorialWidget({
    super.key,
    this.isDialog = false,
  });

  static const String carAsset = 'assets/car_red.png';
  static const String weberAsset = 'assets/weber_idle.png';
  static const String explosionAsset = 'assets/explosion.gif';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isCompact = availableWidth < 380;
        final spacing = isCompact ? 8.0 : 12.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TutorialPanelCard(
                    title: l10n.tutorialPanel1Title,
                    description: l10n.tutorialPanel1Desc,
                    graphic: _buildPanel1Graphic(theme, isCompact),
                    badgeNumber: 1,
                    isCompact: isCompact,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _TutorialPanelCard(
                    title: l10n.tutorialPanel2Title,
                    description: l10n.tutorialPanel2Desc,
                    graphic: _buildPanel2Graphic(theme, isCompact),
                    badgeNumber: 2,
                    isCompact: isCompact,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TutorialPanelCard(
                    title: l10n.tutorialPanel3Title,
                    description: l10n.tutorialPanel3Desc,
                    graphic: _buildPanel3Graphic(theme, isCompact),
                    badgeNumber: 3,
                    isCompact: isCompact,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: _TutorialPanelCard(
                    title: l10n.tutorialPanel4Title,
                    description: l10n.tutorialPanel4Desc,
                    graphic: _buildPanel4Graphic(theme, isCompact),
                    badgeNumber: 4,
                    isCompact: isCompact,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // --- Panel 1: Turn numbers into a correct equation to destroy the car ---
  Widget _buildPanel1Graphic(ThemeData theme, bool isCompact) {
    final graphicH = isCompact ? 60.0 : 76.0;

    return SizedBox(
      height: graphicH,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mini Brazilian Mercosul plate with valid equation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black87, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blue header bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'BRASIL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 6.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Plate equation
                  const Text(
                    '1+2=3',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.bolt_rounded,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            // Mini Car
            Image.asset(
              carAsset,
              height: isCompact ? 32 : 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  // --- Panel 2: Change equation by dragging operators between numbers ---
  Widget _buildPanel2Graphic(ThemeData theme, bool isCompact) {
    final graphicH = isCompact ? 60.0 : 76.0;

    return SizedBox(
      height: graphicH,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Digit 1
            _buildMiniDigitTile('2', isCompact),
            const SizedBox(width: 4),
            // Dropped operator with drag indicator
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: isCompact ? 14 : 16,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purpleAccent, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            // Digit 2
            _buildMiniDigitTile('3', isCompact),
            const SizedBox(width: 4),
            // Equal sign badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amberAccent, width: 1),
              ),
              child: const Text(
                '=',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDigitTile(String digit, bool isCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D7B8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC4A87C)),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          color: Colors.black87,
          fontFamily: 'Courier',
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // --- Panel 3: Do it before the car hits you! ---
  Widget _buildPanel3Graphic(ThemeData theme, bool isCompact) {
    final graphicH = isCompact ? 60.0 : 76.0;

    return SizedBox(
      height: graphicH,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hearts & Timer Header
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 2),
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 2),
                const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.timer_outlined, size: 10, color: Colors.redAccent),
                      SizedBox(width: 2),
                      Text(
                        '0:05',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Weber and speeding car
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  weberAsset,
                  height: isCompact ? 30 : 38,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.fast_forward_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Image.asset(
                  carAsset,
                  height: isCompact ? 28 : 34,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Panel 4: Destroy as many cars as possible! ---
  Widget _buildPanel4Graphic(ThemeData theme, bool isCompact) {
    final graphicH = isCompact ? 60.0 : 76.0;

    return SizedBox(
      height: graphicH,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Explosion
            Image.asset(
              explosionAsset,
              height: isCompact ? 36 : 46,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            // High score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amberAccent, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🚗💥', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Text(
                    '99',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPanelCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget graphic;
  final int badgeNumber;
  final bool isCompact;
  final bool isDark;

  const _TutorialPanelCard({
    required this.title,
    required this.description,
    required this.graphic,
    required this.badgeNumber,
    required this.isCompact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardPadding = isCompact ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: step badge and title
          Row(
            children: [
              Container(
                width: isCompact ? 18 : 22,
                height: isCompact ? 18 : 22,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 146, 209),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 11 : 13,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gaegu(
                    fontSize: isCompact ? 17 : 21,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Graphic container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : const Color.fromARGB(255, 240, 243, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: graphic,
          ),
          const SizedBox(height: 6),
          // Description text
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12.5,
              height: 1.25,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color.fromARGB(255, 55, 50, 75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
