import 'operator_token.dart';

enum DifficultyLevel {
  easy,
  intermediate,
  advanced,
  hard;

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Fácil';
      case DifficultyLevel.intermediate:
        return 'Intermediário';
      case DifficultyLevel.advanced:
        return 'Avançado';
      case DifficultyLevel.hard:
        return 'Difícil';
    }
  }

  bool get allowFractionalDivision => this == DifficultyLevel.easy;

  List<OperatorToken> get availableOperators {
    switch (this) {
      case DifficultyLevel.easy:
        return [
          OperatorToken.plus,
          OperatorToken.minus,
          OperatorToken.multiply,
          OperatorToken.divide,
          OperatorToken.equals,
          OperatorToken.parenOpen,
          OperatorToken.parenClose,
          OperatorToken.power,
          OperatorToken.sqrt,
          OperatorToken.cbrt,
          OperatorToken.factorial,
          OperatorToken.absOpen,
          OperatorToken.absClose,
          OperatorToken.floorOpen,
          OperatorToken.floorClose,
          OperatorToken.ceilOpen,
          OperatorToken.ceilClose,
        ];
      case DifficultyLevel.intermediate:
        return [
          OperatorToken.plus,
          OperatorToken.minus,
          OperatorToken.multiply,
          OperatorToken.divide,
          OperatorToken.equals,
          OperatorToken.parenOpen,
          OperatorToken.parenClose,
          OperatorToken.power,
          OperatorToken.sqrt,
          OperatorToken.cbrt,
          OperatorToken.factorial,
          OperatorToken.absOpen,
          OperatorToken.absClose,
        ];
      case DifficultyLevel.advanced:
        return [
          OperatorToken.plus,
          OperatorToken.minus,
          OperatorToken.multiply,
          OperatorToken.divide,
          OperatorToken.equals,
          OperatorToken.parenOpen,
          OperatorToken.parenClose,
          OperatorToken.sqrt,
          OperatorToken.factorial,
          OperatorToken.absOpen,
          OperatorToken.absClose,
        ];
      case DifficultyLevel.hard:
        return [
          OperatorToken.plus,
          OperatorToken.minus,
          OperatorToken.multiply,
          OperatorToken.divide,
          OperatorToken.equals,
          OperatorToken.parenOpen,
          OperatorToken.parenClose,
          OperatorToken.absOpen,
          OperatorToken.absClose,
        ];
    }
  }
}
