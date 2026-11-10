import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class SoundController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Sound is always set to off on page open/reload to comply with browser autoplay policies
    // and ensure sound works cleanly without requiring manual toggle off/on cycles.
    prefs?.setBool('sound_enabled', false);
    return false;
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
