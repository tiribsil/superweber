import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superweber/core/localization/app_localizations.dart';
import 'package:superweber/core/theme/theme_provider.dart';
import 'package:superweber/features/game/domain/models/operator_token.dart';
import 'package:superweber/features/game/presentation/controllers/game_controller.dart';
import 'package:superweber/features/game/presentation/widgets/mind_view.dart';

void main() {
  testWidgets('MindView plate fits within narrow screen and center Y remains fixed as it shrinks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MindView()),
        ),
      ),
    );

    await tester.pump();

    final dragTargetFinder = find.byType(DragTarget<OperatorToken>);
    final dtBox = tester.renderObject(dragTargetFinder) as RenderBox;
    final clearFinder = find.byIcon(Icons.cleaning_services_rounded);
    final clearBox = tester.renderObject(clearFinder) as RenderBox;

    final initialWidth = dtBox.size.width;
    final initialHeight = dtBox.size.height;
    final initialCenterY = dtBox.localToGlobal(Offset(0, initialHeight / 2)).dy;
    print('Initial plate: size=(${initialWidth}, ${initialHeight}), centerY=$initialCenterY');

    // Add many operators to slots to cause shrinkage
    final controller = container.read(gameControllerProvider.notifier);
    controller.addOperatorToSlot(0, OperatorToken.parenOpen);
    controller.addOperatorToSlot(1, OperatorToken.plus);
    controller.addOperatorToSlot(2, OperatorToken.parenClose);
    controller.addOperatorToSlot(2, OperatorToken.multiply);
    controller.addOperatorToSlot(3, OperatorToken.equals);

    await tester.pump();
    final dtBoxAfter = tester.renderObject(dragTargetFinder) as RenderBox;
    final widthWithOps = dtBoxAfter.size.width;
    final heightWithOps = dtBoxAfter.size.height;
    final centerYWithOps = dtBoxAfter.localToGlobal(Offset(0, heightWithOps / 2)).dy;
    print('Plate with 5 ops: size=(${widthWithOps}, ${heightWithOps}), centerY=$centerYWithOps');

    // Plate width should remain constant (clamped to maxWidth)
    expect(widthWithOps, equals(initialWidth));

    // Height should have shrunk
    expect(heightWithOps, lessThan(initialHeight));

    // Center Y must remain fixed (within floating point rounding)
    expect(centerYWithOps, closeTo(initialCenterY, 0.001));

    // Both plate and clear button should be within screen bounds [0, 400]
    final dtRect = dtBoxAfter.localToGlobal(Offset.zero) & dtBoxAfter.size;
    final clearRect = clearBox.localToGlobal(Offset.zero) & clearBox.size;
    expect(dtRect.left, greaterThanOrEqualTo(0.0));
    expect(dtRect.right, lessThanOrEqualTo(400.0));
    expect(clearRect.left, greaterThanOrEqualTo(0.0));
    expect(clearRect.right, lessThanOrEqualTo(400.0));

    container.dispose();
  });

  testWidgets('MindView plate behaves normally when smaller than total width on wide screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MindView()),
        ),
      ),
    );

    await tester.pump();

    final dragTargetFinder = find.byType(DragTarget<OperatorToken>);
    final dtBox = tester.renderObject(dragTargetFinder) as RenderBox;
    final initialWidth = dtBox.size.width;

    // Add 1 operator - on wide screen, plate width is smaller than total width,
    // so it should grow naturally without scaling down!
    final controller = container.read(gameControllerProvider.notifier);
    controller.addOperatorToSlot(1, OperatorToken.plus);

    await tester.pump();
    final widthWith1Op = dtBox.size.width;
    expect(widthWith1Op, greaterThan(initialWidth));

    container.dispose();
  });

  testWidgets('Drag and drop operator onto scaled plate works properly with fixed center', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MindView()),
        ),
      ),
    );

    await tester.pump();

    // Find the "+" chip draggable in the tray
    final plusFinder = find.widgetWithText(Draggable<OperatorToken>, '+');
    expect(plusFinder, findsOneWidget);

    final dragTargetFinder = find.byType(DragTarget<OperatorToken>);
    expect(dragTargetFinder, findsOneWidget);

    // Drag '+' to the center of the plate
    final dragLocation = tester.getCenter(dragTargetFinder);
    final gesture = await tester.startGesture(tester.getCenter(plusFinder));
    await tester.pump();

    await gesture.moveTo(dragLocation);
    await tester.pump();

    await gesture.up();
    await tester.pump();

    // Verify operator was accepted into one of the slots
    final state = container.read(gameControllerProvider);
    final totalOps = state.slots.fold<int>(0, (sum, slot) => sum + slot.length);
    expect(totalOps, equals(1));

    container.dispose();
  });
}
