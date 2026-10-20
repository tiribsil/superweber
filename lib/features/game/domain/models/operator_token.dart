enum OperatorType {
  plus,
  minus,
  multiply,
  divide,
  equals,
  power,
  sqrt,
  cbrt,
  factorial,
  absOpen,
  absClose,
  floorOpen,
  floorClose,
  ceilOpen,
  ceilClose,
  parenOpen,
  parenClose,
}

class OperatorToken {
  final OperatorType type;
  final String symbol;
  final String latex;
  final String label;

  const OperatorToken({
    required this.type,
    required this.symbol,
    required this.latex,
    required this.label,
  });

  static const plus = OperatorToken(
    type: OperatorType.plus,
    symbol: '+',
    latex: '+',
    label: '+',
  );

  static const minus = OperatorToken(
    type: OperatorType.minus,
    symbol: '-',
    latex: '-',
    label: '-',
  );

  static const multiply = OperatorToken(
    type: OperatorType.multiply,
    symbol: '*',
    latex: r'\times',
    label: '×',
  );

  static const divide = OperatorToken(
    type: OperatorType.divide,
    symbol: '/',
    latex: r'\div',
    label: '÷',
  );

  static const equals = OperatorToken(
    type: OperatorType.equals,
    symbol: '=',
    latex: '=',
    label: '=',
  );

  static const power = OperatorToken(
    type: OperatorType.power,
    symbol: '**',
    latex: '^',
    label: '^',
  );

  static const sqrt = OperatorToken(
    type: OperatorType.sqrt,
    symbol: '√',
    latex: r'\sqrt',
    label: '√',
  );

  static const cbrt = OperatorToken(
    type: OperatorType.cbrt,
    symbol: '∛',
    latex: r'\sqrt[3]',
    label: '∛',
  );

  static const factorial = OperatorToken(
    type: OperatorType.factorial,
    symbol: '!',
    latex: '!',
    label: '!',
  );

  static const absOpen = OperatorToken(
    type: OperatorType.absOpen,
    symbol: '|',
    latex: r'\left|',
    label: '|',
  );

  static const absClose = OperatorToken(
    type: OperatorType.absClose,
    symbol: '|',
    latex: r'\right|',
    label: '|',
  );

  static const floorOpen = OperatorToken(
    type: OperatorType.floorOpen,
    symbol: '⌊',
    latex: r'\left\lfloor',
    label: '⌊',
  );

  static const floorClose = OperatorToken(
    type: OperatorType.floorClose,
    symbol: '⌋',
    latex: r'\right\rfloor',
    label: '⌋',
  );

  static const ceilOpen = OperatorToken(
    type: OperatorType.ceilOpen,
    symbol: '⌈',
    latex: r'\left\lceil',
    label: '⌈',
  );

  static const ceilClose = OperatorToken(
    type: OperatorType.ceilClose,
    symbol: '⌉',
    latex: r'\right\rceil',
    label: '⌉',
  );

  static const parenOpen = OperatorToken(
    type: OperatorType.parenOpen,
    symbol: '(',
    latex: '(',
    label: '(',
  );

  static const parenClose = OperatorToken(
    type: OperatorType.parenClose,
    symbol: ')',
    latex: ')',
    label: ')',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatorToken &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}
