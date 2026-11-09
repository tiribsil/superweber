import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:superweber/core/localization/app_localizations.dart';
import 'package:superweber/features/game/presentation/screens/tutorial_screen.dart';
import 'package:superweber/features/navigation/presentation/help_dialog.dart';

void main() {
  testWidgets('tutorial shows all panels and continues to difficulty', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/tutorial',
      routes: [
        GoRoute(
          path: '/tutorial',
          builder: (context, state) => const TutorialScreen(),
        ),
        GoRoute(
          path: '/difficulty',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Difficulty destination')),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();

    expect(find.text('Make Equations'), findsOneWidget);
    expect(find.text('Drag Operators'), findsOneWidget);
    expect(find.text('Beat the Clock'), findsOneWidget);
    expect(find.text('Blast All Cars!'), findsOneWidget);

    await tester.tap(find.text('Got It!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Difficulty destination'), findsOneWidget);
  });

  testWidgets('help dialog displays the Portuguese tutorial grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showHelpDialog(context),
                child: const Text('Abrir ajuda'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir ajuda'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Crie Equações'), findsOneWidget);
    expect(find.text('Arraste Símbolos'), findsOneWidget);
    expect(find.text('Contra o Tempo'), findsOneWidget);
    expect(find.text('Destrua Tudo!'), findsOneWidget);
  });
}
