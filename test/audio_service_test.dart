import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superweber/core/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('AudioService logic tests', () {
    test('AudioService initializes and safely disposes', () async {
      final audioService = AudioService();
      expect(audioService, isNotNull);

      // Verify safe invocation without audio hardware crash
      audioService.setSoundEnabled(false);
      audioService.updateGameAudioState(isMindDimmed: true, isGameOver: false);
      await audioService.playExplosion();
      await audioService.dispose();
    });

    test('AudioService handles enable/disable and slow-down transitions', () async {
      final audioService = AudioService();

      // Sound disabled
      audioService.setSoundEnabled(false);

      // Dimmed screen (rate should target 0.5)
      audioService.updateGameAudioState(isMindDimmed: true, isGameOver: false);

      // Normal screen (rate should target 1.0)
      audioService.updateGameAudioState(isMindDimmed: false, isGameOver: false);

      // Game over (rate should target 0.5)
      audioService.updateGameAudioState(isMindDimmed: false, isGameOver: true);

      // Restart run (rate should restore to 1.0)
      audioService.updateGameAudioState(isMindDimmed: false, isGameOver: false);

      await audioService.dispose();
    });
  });
}
