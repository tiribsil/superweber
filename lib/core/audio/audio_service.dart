import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sound_controller.dart';

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isBgmLoaded = false;
  bool _isDisposed = false;
  bool _soundEnabled = false;
  bool _isMindDimmed = false;
  bool _isGameOver = false;
  double _currentRate = 1.0;
  Timer? _rateAnimationTimer;

  static const String explosionAsset = 'snd_badexplosion.wav';
  static const String bgmAsset = 'vs_susie.mp3';

  AudioService() {
    _init();
  }

  void _init() {
    try {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _sfxPlayer.setSource(AssetSource(explosionAsset));
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  Future<void> playExplosion() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.resume();
    } catch (e) {
      await _sfxPlayer.play(AssetSource(explosionAsset));
    }
  }

  void setSoundEnabled(bool enabled) {
    if (_isDisposed) return;
    _soundEnabled = enabled;
    _syncBgm();
  }

  void updateGameAudioState({
    required bool isMindDimmed,
    required bool isGameOver,
  }) {
    if (_isDisposed) return;
    _isMindDimmed = isMindDimmed;
    _isGameOver = isGameOver;
    _syncBgm();
  }

  Future<void> _syncBgm() async {
    if (_isDisposed) return;

    if (!_soundEnabled) {
      _rateAnimationTimer?.cancel();
      _rateAnimationTimer = null;
      if (_bgmPlayer.state == PlayerState.playing) {
        try {
          await _bgmPlayer.pause();
        } catch (_) {}
      }
      return;
    }

    final targetRate = (_isMindDimmed || _isGameOver) ? 0.4 : 1.0;

    try {
      if (!_isBgmLoaded) {
        _isBgmLoaded = true;
        await _bgmPlayer.setSource(AssetSource(bgmAsset));
      }

      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.resume();
      }

      if (_currentRate != targetRate) {
        _animateRate(targetRate);
      }
    } catch (e) {
      debugPrint('Error syncing BGM state: $e');
    }
  }

  void _animateRate(
    double targetRate, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    _rateAnimationTimer?.cancel();
    final startRate = _currentRate;
    final startTime = DateTime.now();
    const interval = Duration(milliseconds: 20);

    _rateAnimationTimer = Timer.periodic(interval, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final progress = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
      final newRate = startRate + (targetRate - startRate) * progress;
      _currentRate = newRate;

      try {
        _bgmPlayer.setPlaybackRate(newRate);
      } catch (e) {
        debugPrint('setPlaybackRate error during transition: $e');
      }

      if (progress >= 1.0) {
        timer.cancel();
        _rateAnimationTimer = null;
      }
    });
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _rateAnimationTimer?.cancel();
    _rateAnimationTimer = null;
    try {
      await _bgmPlayer.dispose();
      await _sfxPlayer.dispose();
    } catch (_) {}
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final audioCoordinatorProvider = Provider<void>((ref) {
  final soundEnabled = ref.watch(soundControllerProvider);
  final audioService = ref.watch(audioServiceProvider);

  audioService.setSoundEnabled(soundEnabled);
});
