import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/game_controller.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/audio/sound_controller.dart';

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
  late final AnimationController _animController;
  late final AnimationController _roadController;
  late final AnimationController _carController;
  late String _currentPlate;

  static const String weberCatAsset = 'assets/weber_idle.png';
  static const String carSpriteAsset = 'assets/car_red.png';
  static const String explosionSpriteAsset = 'assets/explosion.gif';
  static const String roadTileAsset = 'assets/rua.png';

  @override
  void initState() {
    super.initState();
    final initialGameState = ref.read(gameControllerProvider);
    _currentPlate = initialGameState.plateString;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();

    _carController = AnimationController(
      vsync: this,
      duration: _carDuration(initialGameState.totalTime),
    )..forward();

    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _carController.dispose();
    _roadController.dispose();
    super.dispose();
  }

  Duration _carDuration(double seconds) =>
      Duration(milliseconds: (seconds * 1000).round());

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

    return _WeberHopTransform(dy: dy, scaleX: scaleX, scaleY: scaleY);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
      if (next.isExploding && !(previous?.isExploding ?? false)) {
        if (ref.read(soundControllerProvider)) {
          ref.read(audioServiceProvider).playExplosion();
        }
      }

      final isNewCar =
          next.plateString != _currentPlate ||
          (next.timeRemaining == next.totalTime &&
              previous?.timeRemaining != next.timeRemaining) ||
          (previous?.isGameOver == true && !next.isGameOver);
      if (isNewCar) {
        _currentPlate = next.plateString;
        _carController.duration = _carDuration(next.totalTime);
        _carController.forward(from: 0);

        // Resume animations for the next car
        if (!_animController.isAnimating) _animController.repeat();
        if (!_roadController.isAnimating) _roadController.repeat();
      } else if (next.isMindDimmed && !(previous?.isMindDimmed ?? false)) {
        // Freeze all animations
        _carController.stop();
        _animController.stop();
        _roadController.stop();

        const AssetImage(explosionSpriteAsset).evict();
      }
    });

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final streetWidth = constraints.maxWidth;
          final streetHeight = constraints.maxHeight;

          final weberMargin = streetHeight * 0.05;
          final weberSize = streetHeight * 0.75;
          final carMargin = streetHeight * 0.08;
          final carSize = streetHeight * 0.7;
          final carEndX = weberSize / 2;
          final carStartX = streetWidth - carSize;

          return ClipRect(
            child: Stack(
              children: [
                // 1. Parallax Street Background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _roadController,
                    builder: (context, _) {
                      final offset = _roadController.value;

                      const double imgOriginalWidth = 1920;
                      const double imgOriginalHeight = 216;

                      final tileWidth =
                          streetHeight * (imgOriginalWidth / imgOriginalHeight);
                      final shift = -(offset * tileWidth);

                      return ClipRect(
                        child: Stack(
                          children: [
                            for (
                              double x = shift;
                              x < streetWidth + tileWidth;
                              x += tileWidth
                            )
                              Positioned(
                                left: x,
                                top: 0,
                                bottom: 0,
                                width: tileWidth,
                                child: Image.asset(
                                  roadTileAsset,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. Weber Cat Sprite
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final t = _animController.value;
                    final maxJump = (weberSize * 0.18).clamp(8.0, 24.0);
                    final hop = _calculateWeberHop(t, maxJump);

                    return Positioned(
                      left: 14,
                      bottom: weberMargin,
                      width: weberSize,
                      height: weberSize,
                      child: Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..translateByDouble(0.0, hop.dy, 0.0, 1.0)
                          ..scaleByDouble(hop.scaleX, hop.scaleY, 1.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(weberCatAsset, fit: BoxFit.contain),
                ),

                // 3. Incoming Car or Explosion Effect
                if (gameState.isExploding)
                  Positioned(
                    left:
                        carStartX +
                        ((carEndX - carStartX) * _carController.value),
                    bottom: carMargin - (carSize * 0.8),
                    child: Image.asset(
                      explosionSpriteAsset,
                      key: ValueKey(gameState.score),
                      height: carSize * 2.5,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _carController,
                    builder: (context, _) {
                      final carCurrentX =
                          carStartX +
                          ((carEndX - carStartX) * _carController.value);
                      return Positioned(
                        left: carCurrentX,
                        bottom: carMargin,
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            final t = _animController.value;
                            final slant = 0.1 * math.sin(t * 2 * math.pi);
                            final squish = 0.2 * math.sin(t * 4 * math.pi);

                            final transform = Matrix4.identity()
                              ..multiply(Matrix4.skewX(slant))
                              ..multiply(
                                Matrix4.diagonal3Values(
                                  1.0 + squish,
                                  1.0 - squish,
                                  1.0,
                                ),
                              );

                            return Transform(
                              alignment: Alignment.bottomCenter,
                              transform: transform,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            carSpriteAsset,
                            fit: BoxFit.contain,
                            height: carSize,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
