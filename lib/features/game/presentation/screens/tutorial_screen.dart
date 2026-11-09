import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_localizations.dart';
import '../widgets/gameplay_tutorial_widget.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  void _goToDifficulty(BuildContext context) {
    context.go('/difficulty');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);

    final isMobile =
        screenSize.width < 900 || screenSize.width < screenSize.height;
    final scale = isMobile
        ? 1.0
        : math
              .min(screenSize.height / 1080.0, screenSize.width / 1920.0)
              .clamp(0.7, 1.2);

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : const Color.fromARGB(255, 156, 170, 250),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final contentWidth = isMobile
                ? maxW.clamp(0.0, 560.0)
                : (maxW * 0.65).clamp(480.0, 720.0);
            final horizontalPadding = isMobile ? 16.0 : 32.0 * scale;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12.0 * scale,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          l10n.tutorialTitle,
                          style: GoogleFonts.gaegu(
                            fontSize: isMobile ? 36 : 46 * scale,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color.fromARGB(255, 48, 44, 77),
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 2),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.15),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2x2 Tutorial Grid inside scroll view to prevent overflow on small screens
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: GameplayTutorialWidget(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // "Got It!" Continue Button
                      _CuteContinueButton(
                        label: l10n.tutorialContinue,
                        onPressed: () => _goToDifficulty(context),
                        scale: scale,
                      ),
                      const SizedBox(height: 8),
                    ],
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

class _CuteContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double scale;

  const _CuteContinueButton({
    required this.onPressed,
    required this.label,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 146, 209),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 36 * scale,
              vertical: 12 * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.gaegu(
                    color: Colors.white,
                    fontSize: 28 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
