import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/theme_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const String weberIdleAsset = 'assets/weber_idle.gif';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _displayedText = '';
  bool _isFinished = false;
  Timer? _typingTimer;
  int _charIndex = 0;
  String _fullText = '';
  final ScrollController _textScrollController = ScrollController();

  // Configuration timings
  static const Duration _startDelay = Duration(seconds: 1); // 1-second pause before starting
  static const Duration _charDelay = Duration(milliseconds: 50); // Speed per character
  static const Duration _lineBreakDelay = Duration(milliseconds: 650); // Pause on \n

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fullText.isEmpty) {
      _fullText = AppLocalizations.of(context)!.historyIntro;
      _startTyping();
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _typingTimer = Timer(_startDelay, _typeNextCharacter);
  }

  void _typeNextCharacter() {
    if (!mounted) return;

    if (_charIndex < _fullText.length) {
      final currentChar = _fullText[_charIndex];
      _charIndex++;

      setState(() {
        _displayedText = _fullText.substring(0, _charIndex);
      });

      _scrollToBottomIfNeeded();

      final delay = (currentChar == '\n') ? _lineBreakDelay : _charDelay;
      _typingTimer = Timer(delay, _typeNextCharacter);
    } else {
      setState(() {
        _isFinished = true;
      });
      _scrollToBottomIfNeeded();
    }
  }

  void _scrollToBottomIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textScrollController.hasClients) {
        _textScrollController.jumpTo(
          _textScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _handleScreenTap() {
    if (!_isFinished) {
      _typingTimer?.cancel();
      setState(() {
        _displayedText = _fullText;
        _charIndex = _fullText.length;
        _isFinished = true;
      });
      _scrollToBottomIfNeeded();
    } else {
      _goToNext();
    }
  }

  void _goToNext() {
    _typingTimer?.cancel();
    context.go('/difficulty');
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);

    // Responsive scaling
    final isMobile =
        screenSize.width < 900 || screenSize.width < screenSize.height;
    final scale = isMobile
        ? 1.0
        : math
            .min(screenSize.height / 1080.0, screenSize.width / 1920.0)
            .clamp(0.5, 1.2);

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : const Color.fromARGB(255, 156, 170, 250),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleScreenTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxH = constraints.maxHeight;
                  final maxW = constraints.maxWidth;

                  // 1/4 area: space from the top of the screen down to Weber
                  final topSpace = isMobile ? maxH * 0.22 : maxH * 0.16;

                  // 2/4 area: Weber sitting in the second quarter of the screen
                  final imageSize = isMobile
                      ? (maxH * 0.24).clamp(160.0, 220.0)
                      : (maxH * 0.26).clamp(220.0, 320.0);

                  final middleGap = isMobile ? 14.0 : 22.0 * scale;
                  final promptHeight = isMobile ? 26.0 : 32.0 * scale;
                  final bottomMargin = isMobile ? 8.0 : 16.0 * scale;

                  // 3/4 & 4/4 area: Text box takes all the remaining space to the bottom
                  final textBoxHeight = (maxH -
                          topSpace -
                          imageSize -
                          middleGap -
                          promptHeight -
                          bottomMargin)
                      .clamp(200.0, maxH * 0.55);

                  // Comfortable side margins
                  final horizontalMargin = isMobile ? 28.0 : 40.0;
                  final textBoxWidth = isMobile
                      ? (maxW - (horizontalMargin * 2)).clamp(0.0, 500.0)
                      : maxW * 0.55;

                  final fontSize = isMobile ? 18.0 : 25.0 * scale;
                  const fontLineHeight = 1.35;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1/4: Top spacing
                        SizedBox(height: topSpace),

                        // 2/4: Weber in the second quarter
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: Image.asset(
                            HistoryScreen.weberIdleAsset,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: middleGap),

                        // 3/4 & 4/4: Text taking the remaining space down to the bottom
                        Container(
                          width: textBoxWidth,
                          height: textBoxHeight,
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            controller: _textScrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              '$_displayedText${!_isFinished ? '|' : ''}',
                              textAlign: TextAlign.start,
                              strutStyle: StrutStyle(
                                fontFamily:
                                    GoogleFonts.courierPrime().fontFamily,
                                fontSize: fontSize,
                                height: fontLineHeight,
                                forceStrutHeight: true,
                              ),
                              style: GoogleFonts.courierPrime(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w700,
                                height: fontLineHeight,
                                color: isDark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 48, 44, 77),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1, 2),
                                    blurRadius: 4,
                                    color:
                                        Colors.black.withValues(alpha: 0.15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Continue prompt at the bottom
                        SizedBox(
                          height: promptHeight,
                          child: AnimatedOpacity(
                            opacity: _isFinished ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.touch_app_rounded,
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.35),
                              size: 20,
                            ),
                          ),
                        ),

                        SizedBox(height: bottomMargin),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Top-Right Skip Button
            Positioned(
              top: isMobile ? 12 : 24 * scale,
              right: isMobile ? 16 : 28 * scale,
              child: SafeArea(
                child: _CuteSkipButton(
                  scale: scale,
                  label: l10n.skip,
                  onPressed: _goToNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Cute Skip Button Matching Login Aesthetic ---

class _CuteSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double scale;

  const _CuteSkipButton({
    required this.onPressed,
    required this.label,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 900 ||
        MediaQuery.sizeOf(context).width < MediaQuery.sizeOf(context).height;
    final borderRadius = BorderRadius.circular(30);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 146, 209),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
              horizontal: isMobile ? 16 : 22 * scale,
              vertical: isMobile ? 8 : 12 * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.gaegu(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 28 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Icon(
                  Icons.fast_forward_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 24 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}