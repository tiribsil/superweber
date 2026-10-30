import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/game_controller.dart';

class _WeberHopTransform {
  final double dy;
  final double scaleX;
  final double scaleY;

  const _WeberHopTransform({
    required this.dy,
    required this.scaleX,
    required this.scaleY,
  });
}

class StreetView extends ConsumerStatefulWidget {
  const StreetView({super.key});

  @override
  ConsumerState<StreetView> createState() => _StreetViewState();
}

class _StreetViewState extends ConsumerState<StreetView>
    with TickerProviderStateMixin {
  late final AnimationController _parallaxController;
  late final AnimationController _hopController;

  // Placeholder URLs as requested; user will host custom images later.
  static const String weberCatUrl =
      'https://raw.githubusercontent.com/tiribsil/weber/master/public/images/weber_idle.gif';
  static const String carSpriteUrl =
      'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=160&q=80';

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    _hopController.dispose();
    super.dispose();
  }

  _WeberHopTransform _calculateWeberHop(double t, double maxJump) {
    // 1. dy (vertical jump arc up and down)
    double dy;
    if (t >= 0.15 && t < 0.75) {
      final u = (t - 0.15) / 0.60;
      dy = -maxJump * 4.0 * u * (1.0 - u);
    } else {
      dy = 0.0;
    }

    // 2. Squish squash & stretch: s < 0 = squash (crouch/impact), s > 0 = stretch
    double s;
    if (t < 0.15) {
      // Anticipation squash before leaping
      final u = t / 0.15;
      s = -0.18 * math.sin(u * math.pi);
    } else if (t < 0.35) {
      // Takeoff stretch upwards
      final u = (t - 0.15) / 0.20;
      s = 0.20 * math.sin(u * math.pi);
    } else if (t < 0.75) {
      // Air flight to descent
      final u = (t - 0.35) / 0.40;
      s = 0.06 * math.sin(u * math.pi);
    } else {
      // Landing impact squash
      final u = (t - 0.75) / 0.25;
      s = -0.16 * math.sin(u * math.pi);
    }

    final scaleY = 1.0 + s;
    final scaleX = 1.0 - (s * 0.80);

    return _WeberHopTransform(
      dy: dy,
      scaleX: scaleX,
      scaleY: scaleY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final streetWidth = constraints.maxWidth;
        final streetHeight = constraints.maxHeight;
        final carStartX = (streetWidth - 90.0).clamp(100.0, 2000.0);

        // Car position: travels from streetWidth - 90 down to Weber at ~60
        final progress = gameState.carProgress;
        final weberMargin = 6.0;
        final weberSize = (streetHeight - (weberMargin * 2)).clamp(40.0, 160.0);
        final weberTop = (streetHeight - weberSize) / 2;
        final carEndX = 14.0 + weberSize + 8.0;
        final carCurrentX = carStartX - (progress * (carStartX - carEndX));

        return ClipRect(
          child: Stack(
            children: [
              // 1. Parallax Street Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _parallaxController,
                  builder: (context, child) {
                    final offset = _parallaxController.value;
                    return CustomPaint(
                      painter: _StreetParallaxPainter(
                        offset: offset,
                        roadColor: theme.brightness == Brightness.dark
                            ? const Color(0xFF212121)
                            : const Color(0xFF37474F),
                        lineColor: Colors.amberAccent,
                      ),
                    );
                  },
                ),
              ),

              // 2. Weber Cat Sprite (Animated GIF with vertical bounce and squish squash)
              AnimatedBuilder(
                animation: _hopController,
                builder: (context, child) {
                  final t = _hopController.value;
                  final maxJump = (weberSize * 0.18).clamp(8.0, 24.0);
                  final hop = _calculateWeberHop(t, maxJump);

                  return Positioned(
                    left: 14,
                    top: weberTop + hop.dy,
                    width: weberSize,
                    height: weberSize,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.diagonal3Values(hop.scaleX, hop.scaleY, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Image.network(
                  weberCatUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),

              // 3. Incoming Car or Explosion Effect
              if (gameState.isExploding)
                Positioned(
                  left: carCurrentX - 20,
                  bottom: 0,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.6, end: 1.4),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orangeAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange,
                                blurRadius: 25,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Positioned(
                  left: carCurrentX.clamp(carEndX, carStartX),
                  bottom: 12,
                  child: Container(
                    width: 70,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            carSpriteUrl,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          // Plate number badge on car
                          Positioned(
                            bottom: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                gameState.plateString,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Top Overlay HUD (Score badge on top-right)
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amberAccent, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Timer progress bar at the very top of street
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: (gameState.timeRemaining / gameState.totalTime).clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    gameState.timeRemaining < 5.0 ? Colors.redAccent : Colors.amberAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreetParallaxPainter extends CustomPainter {
  final double offset;
  final Color roadColor;
  final Color lineColor;

  _StreetParallaxPainter({
    required this.offset,
    required this.roadColor,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Road surface
    final roadPaint = Paint()..color = roadColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), roadPaint);

    // Curb borders
    final curbPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 2), Offset(size.width, 2), curbPaint);
    canvas.drawLine(Offset(0, size.height - 2), Offset(size.width, size.height - 2), curbPaint);

    // Dashed center markings with parallax scroll
    final dashPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = 3.0;

    const dashWidth = 24.0;
    const dashSpace = 20.0;
    const totalCycle = dashWidth + dashSpace;
    final startShift = -(offset * totalCycle);

    final midY = size.height * 0.55;
    double currentX = startShift;
    while (currentX < size.width) {
      if (currentX + dashWidth > 0) {
        canvas.drawLine(
          Offset(currentX, midY),
          Offset(currentX + dashWidth, midY),
          dashPaint,
        );
      }
      currentX += totalCycle;
    }
  }

  @override
  bool shouldRepaint(_StreetParallaxPainter oldDelegate) =>
      oldDelegate.offset != offset ||
      oldDelegate.roadColor != roadColor ||
      oldDelegate.lineColor != lineColor;
}
