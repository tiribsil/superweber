import 'package:flutter_test/flutter_test.dart';
import 'package:superweber/features/game/domain/engine/math_evaluator.dart';
import 'package:superweber/features/game/domain/models/operator_token.dart';

void main() {
  group('MathEvaluator Tests', () {
    test('Valid basic equality: 1 + 2 = 3 * 1', () {
      final slots = [
        <OperatorToken>[], // before 1
        [OperatorToken.plus], // 1 + 2
        [OperatorToken.equals], // 2 = 3
        [OperatorToken.multiply], // 3 * 1
        <OperatorToken>[], // after 1
      ];
      final digits = [1, 2, 3, 1];

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: false,
      );

      expect(result.isValid, isTrue);
      expect(result.isSolved, isTrue);
      expect(result.lhsValue, equals(3.0));
      expect(result.rhsValue, equals(3.0));
    });

    test('Complex operators: sqrt(8 + 1) = 3 ** 1', () {
      final slots = [
        [OperatorToken.sqrt, OperatorToken.parenOpen], // √(8...
        [OperatorToken.plus], // 8 + 1
        [OperatorToken.parenClose, OperatorToken.equals], // 1) = 3
        [OperatorToken.power], // 3 ** 1
        <OperatorToken>[],
      ];
      final digits = [8, 1, 3, 1];

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: false,
      );

      expect(result.isValid, isTrue);
      expect(result.isSolved, isTrue);
      expect(result.lhsValue, equals(3.0));
      expect(result.rhsValue, equals(3.0));
    });

    test('Factorial test: (5 - 2)! = 6 * 1', () {
      final slots = [
        [OperatorToken.parenOpen],
        [OperatorToken.minus],
        [OperatorToken.parenClose, OperatorToken.factorial, OperatorToken.equals],
        [OperatorToken.multiply],
        <OperatorToken>[],
      ];
      final digits = [5, 2, 6, 1];

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: false,
      );

      expect(result.isValid, isTrue);
      expect(result.isSolved, isTrue);
      expect(result.lhsValue, equals(6.0));
      expect(result.rhsValue, equals(6.0));
    });

    test('Hard cap: Values exceeding 10000 fail validation', () {
      final slots = [
        <OperatorToken>[],
        [OperatorToken.power],
        [OperatorToken.equals],
        [OperatorToken.plus],
        <OperatorToken>[],
      ];
      // 9 ** 9 = 9 + 9 -> 9^9 = 387,420,489 > 10,000
      final digits = [9, 9, 9, 9];

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: true,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('limite'));
    });

    test('Division by zero fails validation', () {
      final slots = [
        <OperatorToken>[],
        [OperatorToken.divide],
        [OperatorToken.equals],
        [OperatorToken.plus],
        <OperatorToken>[],
      ];
      final digits = [5, 0, 1, 2];

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: true,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Divisão por zero'));
    });

    test('Non-integer division rejected when allowFractionalDivision is false', () {
      final slots = [
        <OperatorToken>[],
        [OperatorToken.divide],
        [OperatorToken.equals],
        [OperatorToken.plus],
        <OperatorToken>[],
      ];
      final digits = [5, 2, 2, 0]; // 5 / 2 = 2 + 0 => 2.5 vs 2

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: false,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('não inteira'));
    });

    test('Non-integer division allowed when allowFractionalDivision is true (Fácil)', () {
      final slots = [
        <OperatorToken>[],
        [OperatorToken.divide],
        [OperatorToken.equals],
        [OperatorToken.minus],
        <OperatorToken>[],
      ];
      // 5 / 2 = 2.5 (if we could make 2.5 on right)
      final digits = [5, 2, 3, 1]; // 5 / 2 = 2.5, 3 - 1 = 2 (not equal, but valid math)

      final result = MathEvaluator.evaluate(
        slots: slots,
        digits: digits,
        allowFractionalDivision: true,
      );

      expect(result.isValid, isTrue);
      expect(result.isSolved, isFalse); // 2.5 != 2
      expect(result.lhsValue, equals(2.5));
    });

    test('Slot insertion: left (insertIndex 0) vs right (insertIndex 1)', () {
      final slots = [
        <OperatorToken>[],
        [OperatorToken.plus],
        <OperatorToken>[],
        <OperatorToken>[],
        <OperatorToken>[],
      ];

      // Insert sqrt to the left of plus (insertIndex 0)
      slots[1].insert(0, OperatorToken.sqrt);
      expect(slots[1].first, equals(OperatorToken.sqrt));
      expect(slots[1].last, equals(OperatorToken.plus));

      // Insert parenClose to the right of plus (insertIndex 2)
      slots[1].insert(2, OperatorToken.parenClose);
      expect(slots[1], equals([
        OperatorToken.sqrt,
        OperatorToken.plus,
        OperatorToken.parenClose,
      ]));
    });

    test('generateLatex auto-closes unclosed sqrt without parser error', () {
      final slots = [
        [OperatorToken.sqrt],
        <OperatorToken>[],
        <OperatorToken>[],
        <OperatorToken>[],
        <OperatorToken>[],
      ];
      final digits = [8, 1, 3, 1];

      final latex = MathEvaluator.generateLatex(slots: slots, digits: digits);
      expect(latex, contains(r'\sqrt{8}'));
      // No unclosed braces:
      final openCount = '{'.allMatches(latex).length;
      final closeCount = '}'.allMatches(latex).length;
      expect(openCount, equals(closeCount));
    });
  });
}
