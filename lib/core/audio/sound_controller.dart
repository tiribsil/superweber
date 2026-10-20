import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class SoundController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Sound starts disabled by default as required by usability specification
    return prefs?.getBool('sound_enabled') ?? false;
  }

  void toggle() {
    state = !state;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setBool('sound_enabled', state);
  }

  void setEnabled(bool enabled) {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setBool('sound_enabled', enabled);
  }
}

final soundControllerProvider =
    NotifierProvider<SoundController, bool>(SoundController.new);
