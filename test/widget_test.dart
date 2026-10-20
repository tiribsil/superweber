import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superweber/core/localization/app_localizations.dart';
import 'package:superweber/core/theme/theme_provider.dart';
import 'package:superweber/features/game/presentation/game_screen.dart';
import 'package:superweber/features/game/presentation/widgets/mind_view.dart';
import 'package:superweber/features/game/presentation/widgets/street_view.dart';

void main() {
  testWidgets('GameScreen renders StreetView (20%) and MindView (80%)',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'last_route': '/game',
      'app_locale': 'pt',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(StreetView), findsOneWidget);
    expect(find.byType(MindView), findsOneWidget);
  });
}
