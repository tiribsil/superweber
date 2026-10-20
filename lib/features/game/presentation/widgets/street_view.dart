import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_state.dart';
import '../controllers/game_controller.dart';

class StreetView extends ConsumerStatefulWidget {
  const StreetView({super.key});

  @override
  ConsumerState<StreetView> createState() => _StreetViewState();
}

class _StreetViewState extends ConsumerState<StreetView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _parallaxController;

  // Placeholder URLs as requested; user will host custom images later.
  static const String weberCatUrl =
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=160&q=80';
  static const String carSpriteUrl =
      'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=160&q=80';

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final streetWidth = constraints.maxWidth;

        // Car position: travels from streetWidth - 90 down to Weber at ~60
        final progress = gameState.carProgress;
        final carStartX = streetWidth - 90;
        const carEndX = 70.0;
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

              // 2. Weber Cat (Left side of road)
              Positioned(
                left: 12,
                bottom: 8,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purpleAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      weberCatUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
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

              // 4. Top Overlay HUD (Hearts + Timer bar + Score)
              Positioned(
                top: 6,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lives (up to 9 hearts)
                    Row(
                      children: List.generate(GameState.maxHp, (index) {
                        final isFilled = index < gameState.hp;
                        return Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: Icon(
                            isFilled ? Icons.favorite : Icons.favorite_border,
                            color: isFilled ? Colors.redAccent : Colors.grey,
                            size: 16,
                          ),
                        );
                      }),
                    ),

                    // Cars destroyed (score)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amberAccent, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.amberAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${gameState.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
