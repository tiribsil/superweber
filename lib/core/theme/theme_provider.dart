import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  final double fontSizeScale;
  final String fontFamily;
  final Color seedColor;
  final Locale locale;

  const ThemeState({
    required this.themeMode,
    required this.fontSizeScale,
    required this.fontFamily,
    required this.seedColor,
    required this.locale,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    double? fontSizeScale,
    String? fontFamily,
    Color? seedColor,
    Locale? locale,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      fontFamily: fontFamily ?? this.fontFamily,
      seedColor: seedColor ?? this.seedColor,
      locale: locale ?? this.locale,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ThemeState(
      themeMode: _loadThemeMode(prefs),
      fontSizeScale: prefs?.getDouble('font_size_scale') ?? 1.0,
      fontFamily: prefs?.getString('font_family') ?? 'Roboto',
      seedColor: Color(
        prefs?.getInt('seed_color') ?? Colors.deepPurple.toARGB32(),
      ),
      locale: Locale(
        prefs?.getString('app_locale') ?? 'pt',
        prefs?.getString('app_country') ?? 'BR',
      ),
    );
  }

  static ThemeMode _loadThemeMode(SharedPreferences? prefs) {
    final mode = prefs?.getString('theme_mode');
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setString('theme_mode', mode.name);
  }

  void setFontSizeScale(double scale) {
    state = state.copyWith(fontSizeScale: scale);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setDouble('font_size_scale', scale);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setString('font_family', family);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setInt('seed_color', color.toARGB32());
  }

  void setLocale(Locale loc) {
    state = state.copyWith(locale: loc);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs?.setString('app_locale', loc.languageCode);
    if (loc.countryCode != null) {
      prefs?.setString('app_country', loc.countryCode!);
    }
  }

  /// Returns a [TextTheme] styled with the selected Google Font.
  /// Font size scaling is handled separately via [MediaQuery.textScaler] in main.dart.
  TextTheme _buildTextTheme(TextTheme base) {
    try {
      final resolvedFamily = GoogleFonts.getFont(state.fontFamily).fontFamily;
      if (resolvedFamily != null) {
        return base.apply(fontFamily: resolvedFamily);
      }
    } catch (_) {
      // Unknown font name — fall back to base theme.
    }
    return base;
  }

  ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: state.seedColor,
      brightness: Brightness.light,
    );
    return base.copyWith(textTheme: _buildTextTheme(base.textTheme));
  }

  ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: state.seedColor,
      brightness: Brightness.dark,
    );
    return base.copyWith(textTheme: _buildTextTheme(base.textTheme));
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
