import 'difficulty_level.dart';
import 'operator_token.dart';
import '../engine/math_evaluator.dart';

class GameState {
  final int hp;
  final int score;
  final DifficultyLevel difficulty;
  final List<int> digits;
  final List<List<OperatorToken>> slots;
  final double timeRemaining;
  final double totalTime;
  final bool isGameOver;
  final bool isExploding;
  final EvaluationResult evaluation;
  final Set<String> solvedPlates;
  final String? lastError;

  const GameState({
    required this.hp,
    required this.score,
    required this.difficulty,
    required this.digits,
    required this.slots,
    required this.timeRemaining,
    required this.totalTime,
    required this.isGameOver,
    required this.isExploding,
    required this.evaluation,
    required this.solvedPlates,
    this.lastError,
  });

  static const int maxHp = 9;
  static const double defaultCarDuration = 100.0;

  factory GameState.initial({DifficultyLevel difficulty = DifficultyLevel.easy}) {
    final initialDigits = [8, 1, 3, 1];
    final initialSlots = [
      <OperatorToken>[],
      <OperatorToken>[],
      <OperatorToken>[],
      <OperatorToken>[],
      <OperatorToken>[],
    ];

    return GameState(
      hp: maxHp,
      score: 0,
      difficulty: difficulty,
      digits: initialDigits,
      slots: initialSlots,
      timeRemaining: defaultCarDuration,
      totalTime: defaultCarDuration,
      isGameOver: false,
      isExploding: false,
      evaluation: MathEvaluator.evaluate(
        slots: initialSlots,
        digits: initialDigits,
        allowFractionalDivision: difficulty.allowFractionalDivision,
      ),
      solvedPlates: {},
    );
  }

  double get carProgress {
    if (totalTime <= 0) return 1.0;
    final progress = 1.0 - (timeRemaining / totalTime);
    return progress.clamp(0.0, 1.0);
  }

  String get plateString => digits.join();

  GameState copyWith({
    int? hp,
    int? score,
    DifficultyLevel? difficulty,
    List<int>? digits,
    List<List<OperatorToken>>? slots,
    double? timeRemaining,
    double? totalTime,
    bool? isGameOver,
    bool? isExploding,
    EvaluationResult? evaluation,
    Set<String>? solvedPlates,
    String? lastError,
    bool clearError = false,
  }) {
    return GameState(
      hp: hp ?? this.hp,
      score: score ?? this.score,
      difficulty: difficulty ?? this.difficulty,
      digits: digits ?? this.digits,
      slots: slots ?? this.slots,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalTime: totalTime ?? this.totalTime,
      isGameOver: isGameOver ?? this.isGameOver,
      isExploding: isExploding ?? this.isExploding,
      evaluation: evaluation ?? this.evaluation,
      solvedPlates: solvedPlates ?? this.solvedPlates,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
