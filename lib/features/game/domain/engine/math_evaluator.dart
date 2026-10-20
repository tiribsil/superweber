import 'dart:math' as math;
import '../models/operator_token.dart';

class MathException implements Exception {
  final String code;
  final String message;
  const MathException(this.code, this.message);

  @override
  String toString() => message;
}

class EvaluationResult {
  final bool isValid;
  final bool isSolved;
  final double? lhsValue;
  final double? rhsValue;
  final String? errorMessage;
  final String latex;

  const EvaluationResult({
    required this.isValid,
    required this.isSolved,
    this.lhsValue,
    this.rhsValue,
    this.errorMessage,
    required this.latex,
  });
}

class MathEvaluator {
  static const double maxAllowedValue = 10000.0;
  static const double epsilon = 1e-7;

  /// Validates and evaluates the equation built from slots and digits.
  static EvaluationResult evaluate({
    required List<List<OperatorToken>> slots,
    required List<int> digits,
    required bool allowFractionalDivision,
  }) {
    final latex = generateLatex(slots: slots, digits: digits);

    // Basic structural checks:
    // Slots 1, 2, 3 must have at least one operator.
    if (slots.length < 5 || digits.length != 4) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'Estrutura inválida',
        latex: latex,
      );
    }

    if (slots[1].isEmpty || slots[2].isEmpty || slots[3].isEmpty) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'É necessário inserir ao menos um operador entre cada par de dígitos',
        latex: latex,
      );
    }

    // Build the complete token stream
    final tokens = <dynamic>[];
    tokens.addAll(slots[0]);
    tokens.add(digits[0]);
    tokens.addAll(slots[1]);
    tokens.add(digits[1]);
    tokens.addAll(slots[2]);
    tokens.add(digits[2]);
    tokens.addAll(slots[3]);
    tokens.add(digits[3]);
    tokens.addAll(slots[4]);

    // Check for equals sign
    final equalsIndices = <int>[];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == OperatorToken.equals) {
        equalsIndices.add(i);
      }
    }

    if (equalsIndices.isEmpty) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'Insira o símbolo de igual (=)',
        latex: latex,
      );
    }

    if (equalsIndices.length > 1) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'Apenas um sinal de igual (=) é permitido',
        latex: latex,
      );
    }

    final eqIndex = equalsIndices.first;
    final lhsTokens = tokens.sublist(0, eqIndex);
    final rhsTokens = tokens.sublist(eqIndex + 1);

    if (lhsTokens.isEmpty || rhsTokens.isEmpty) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'A equação deve ter elementos nos dois lados',
        latex: latex,
      );
    }

    try {
      final lhsVal = _Parser(lhsTokens, allowFractionalDivision).parseExpression();
      final rhsVal = _Parser(rhsTokens, allowFractionalDivision).parseExpression();

      final solved = (lhsVal - rhsVal).abs() < epsilon;
      return EvaluationResult(
        isValid: true,
        isSolved: solved,
        lhsValue: lhsVal,
        rhsValue: rhsVal,
        errorMessage: solved ? null : 'Os dois lados da equação são diferentes',
        latex: latex,
      );
    } on MathException catch (e) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: e.message,
        latex: latex,
      );
    } catch (_) {
      return EvaluationResult(
        isValid: false,
        isSolved: false,
        errorMessage: 'Expressão matemática inválida',
        latex: latex,
      );
    }
  }

  /// Quickly validates a sub-expression or test-placed operator without full equation completeness
  static bool canPlaceWithoutViolation({
    required List<List<OperatorToken>> slots,
    required List<int> digits,
    required bool allowFractionalDivision,
  }) {
    // If complete enough, evaluate it. If it throws overflow or div_zero, reject.
    try {
      final tokens = <dynamic>[];
      tokens.addAll(slots[0]);
      tokens.add(digits[0]);
      tokens.addAll(slots[1]);
      tokens.add(digits[1]);
      tokens.addAll(slots[2]);
      tokens.add(digits[2]);
      tokens.addAll(slots[3]);
      tokens.add(digits[3]);
      tokens.addAll(slots[4]);

      // Split by '=' if present and evaluate parts if syntactically complete
      final eqIndex = tokens.indexOf(OperatorToken.equals);
      if (eqIndex != -1) {
        final lhs = tokens.sublist(0, eqIndex);
        final rhs = tokens.sublist(eqIndex + 1);
        if (lhs.isNotEmpty) {
          try {
            _Parser(lhs, allowFractionalDivision).parseExpression();
          } on MathException catch (e) {
            if (e.code == 'overflow' || e.code == 'div_zero') return false;
          } catch (_) {}
        }
        if (rhs.isNotEmpty) {
          try {
            _Parser(rhs, allowFractionalDivision).parseExpression();
          } on MathException catch (e) {
            if (e.code == 'overflow' || e.code == 'div_zero') return false;
          } catch (_) {}
        }
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  static String generateLatex({
    required List<List<OperatorToken>> slots,
    required List<int> digits,
  }) {
    final buffer = StringBuffer();

    void appendSlot(List<OperatorToken> slot) {
      for (final t in slot) {
        switch (t.type) {
          case OperatorType.power:
            buffer.write('^');
            break;
          case OperatorType.sqrt:
            buffer.write(r'\sqrt{');
            break;
          case OperatorType.cbrt:
            buffer.write(r'\sqrt[3]{');
            break;
          case OperatorType.multiply:
            buffer.write(r' \times ');
            break;
          case OperatorType.divide:
            buffer.write(r' \div ');
            break;
          case OperatorType.equals:
            buffer.write(' = ');
            break;
          case OperatorType.absOpen:
            buffer.write(r'\left|');
            break;
          case OperatorType.absClose:
            buffer.write(r'\right|');
            break;
          case OperatorType.floorOpen:
            buffer.write(r'\left\lfloor ');
            break;
          case OperatorType.floorClose:
            buffer.write(r'\right\rfloor ');
            break;
          case OperatorType.ceilOpen:
            buffer.write(r'\left\lceil ');
            break;
          case OperatorType.ceilClose:
            buffer.write(r'\right\rceil ');
            break;
          default:
            buffer.write(t.latex);
        }
      }
    }

    if (slots.isNotEmpty) appendSlot(slots[0]);
    if (digits.isNotEmpty) buffer.write(digits[0]);
    if (slots.length > 1) appendSlot(slots[1]);
    if (digits.length > 1) buffer.write(digits[1]);
    if (slots.length > 2) appendSlot(slots[2]);
    if (digits.length > 2) buffer.write(digits[2]);
    if (slots.length > 3) appendSlot(slots[3]);
    if (digits.length > 3) buffer.write(digits[3]);
    if (slots.length > 4) appendSlot(slots[4]);

    return buffer.toString();
  }
}

class _Parser {
  final List<dynamic> tokens;
  final bool allowFractionalDivision;
  int _pos = 0;

  _Parser(this.tokens, this.allowFractionalDivision);

  dynamic get _current => _pos < tokens.length ? tokens[_pos] : null;

  void _consume() => _pos++;

  double parseExpression() {
    final result = _parseAdditionSubtraction();
    if (_pos < tokens.length) {
      throw const MathException('syntax', 'Tokens adicionais inesperados');
    }
    _checkLimit(result);
    return result;
  }

  double _parseAdditionSubtraction() {
    double left = _parseMultiplicationDivision();

    while (_current == OperatorToken.plus || _current == OperatorToken.minus) {
      final op = _current;
      _consume();
      final right = _parseMultiplicationDivision();
      if (op == OperatorToken.plus) {
        left = left + right;
      } else {
        left = left - right;
      }
      _checkLimit(left);
    }

    return left;
  }

  double _parseMultiplicationDivision() {
    double left = _parsePower();

    while (_current == OperatorToken.multiply || _current == OperatorToken.divide) {
      final op = _current;
      _consume();
      final right = _parsePower();

      if (op == OperatorToken.multiply) {
        left = left * right;
      } else {
        if (right.abs() < MathEvaluator.epsilon) {
          throw const MathException('div_zero', 'Divisão por zero');
        }
        final divResult = left / right;
        if (!allowFractionalDivision) {
          final isInteger = (divResult - divResult.round()).abs() < MathEvaluator.epsilon;
          if (!isInteger) {
            throw const MathException('non_integer_div', 'Divisão não inteira');
          }
        }
        left = divResult;
      }
      _checkLimit(left);
    }

    return left;
  }

  double _parsePower() {
    double base = _parseUnary();

    if (_current == OperatorToken.power) {
      _consume();
      final exponent = _parsePower(); // right-associative

      if (exponent > 100 || base.abs() > 1000) {
        throw const MathException('overflow', 'Exponenciação excede limites seguros');
      }
      final result = math.pow(base, exponent).toDouble();
      if (result.isNaN || result.isInfinite) {
        throw const MathException('overflow', 'Resultado de exponenciação inválido');
      }
      _checkLimit(result);
      return result;
    }

    return base;
  }

  double _parseUnary() {
    if (_current == OperatorToken.plus) {
      _consume();
      return _parseUnary();
    }
    if (_current == OperatorToken.minus) {
      _consume();
      final val = -_parseUnary();
      _checkLimit(val);
      return val;
    }
    if (_current == OperatorToken.sqrt) {
      _consume();
      final inner = _parseUnary();
      if (inner < 0) {
        throw const MathException('domain', 'Raiz quadrada de número negativo');
      }
      final result = math.sqrt(inner);
      _checkLimit(result);
      return result;
    }
    if (_current == OperatorToken.cbrt) {
      _consume();
      final inner = _parseUnary();
      final result = inner < 0
          ? -math.pow(-inner, 1.0 / 3.0).toDouble()
          : math.pow(inner, 1.0 / 3.0).toDouble();
      _checkLimit(result);
      return result;
    }

    // Now parse primary, then check postfix factorial
    double primary = _parsePrimary();

    while (_current == OperatorToken.factorial) {
      _consume();
      primary = _factorial(primary);
      _checkLimit(primary);
    }

    return primary;
  }

  double _parsePrimary() {
    final token = _current;

    if (token is int) {
      _consume();
      return token.toDouble();
    }

    if (token == OperatorToken.parenOpen) {
      _consume();
      final val = _parseAdditionSubtraction();
      if (_current != OperatorToken.parenClose) {
        throw const MathException('syntax', 'Parêntese aberto não fechado');
      }
      _consume();
      return val;
    }

    if (token == OperatorToken.absOpen) {
      _consume();
      final val = _parseAdditionSubtraction();
      if (_current != OperatorToken.absClose) {
        throw const MathException('syntax', 'Módulo aberto não fechado');
      }
      _consume();
      return val.abs();
    }

    if (token == OperatorToken.floorOpen) {
      _consume();
      final val = _parseAdditionSubtraction();
      if (_current != OperatorToken.floorClose) {
        throw const MathException('syntax', 'Base aberta não fechada');
      }
      _consume();
      return val.floorToDouble();
    }

    if (token == OperatorToken.ceilOpen) {
      _consume();
      final val = _parseAdditionSubtraction();
      if (_current != OperatorToken.ceilClose) {
        throw const MathException('syntax', 'Teto aberto não fechado');
      }
      _consume();
      return val.ceilToDouble();
    }

    throw const MathException('syntax', 'Símbolo inesperado');
  }

  double _factorial(double n) {
    if (n < 0 || (n - n.round()).abs() > MathEvaluator.epsilon) {
      throw const MathException('domain', 'Fatorial definido apenas para inteiros não negativos');
    }
    final intVal = n.round();
    if (intVal > 7) {
      // 8! = 40320 > 10000
      throw const MathException('overflow', 'Fatorial excede 10.000');
    }
    double res = 1.0;
    for (int i = 2; i <= intVal; i++) {
      res *= i;
    }
    return res;
  }

  void _checkLimit(double val) {
    if (val.abs() > MathEvaluator.maxAllowedValue) {
      throw const MathException('overflow', 'Valor excede o limite máximo de 10.000');
    }
  }
}
