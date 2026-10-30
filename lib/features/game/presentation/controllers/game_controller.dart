import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engine/math_evaluator.dart';
import '../../domain/models/difficulty_level.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/operator_token.dart';
import '../../../records/data/firestore_service.dart';

class GameController extends Notifier<GameState> {
  Timer? _timer;
  final math.Random _random = math.Random();

  @override
  GameState build() {
    _startTimer();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return GameState.initial();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (state.isGameOver || state.isExploding) return;

      final newTime = state.timeRemaining - 1;
      if (newTime <= 0) {
        _handleCarHitWeber();
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }

  void _handleCarHitWeber() {
    final newHp = state.hp - 1;
    if (newHp <= 0) {
      state = state.copyWith(
        hp: 0,
        isGameOver: true,
        timeRemaining: 0,
      );
      _timer?.cancel();
      _saveScoreToCloud();
    } else {
      // Lose 1 HP and spawn next car
      state = state.copyWith(hp: newHp);
      _spawnNextCar();
    }
  }

  List<int> _generateUnsolvedDigits() {
    // Generate 4 random digits not yet in state.solvedPlates
    for (int attempts = 0; attempts < 100; attempts++) {
      final digits = List.generate(4, (_) => _random.nextInt(10));
      final plateStr = digits.join();
      if (!state.solvedPlates.contains(plateStr)) {
        return digits;
      }
    }
    // Fallback if 100 attempts collide
    return List.generate(4, (_) => _random.nextInt(10));
  }

  void _spawnNextCar() {
    final nextDigits = _generateUnsolvedDigits();
    final freshSlots = List.generate(5, (_) => <OperatorToken>[]);

    state = state.copyWith(
      digits: nextDigits,
      slots: freshSlots,
      timeRemaining: GameState.defaultCarDuration,
      totalTime: GameState.defaultCarDuration,
      isExploding: false,
      clearError: true,
      evaluation: MathEvaluator.evaluate(
        slots: freshSlots,
        digits: nextDigits,
        allowFractionalDivision: state.difficulty.allowFractionalDivision,
      ),
    );
  }

  /// Attempts to insert an operator into a given slot.
  /// If [insertIndex] is provided, inserts at that position; otherwise appends.
  /// Returns false if rejected due to overflow (> 10000) or division by zero.
  bool addOperatorToSlot(int slotIndex, OperatorToken token, {int? insertIndex}) {
    if (slotIndex < 0 || slotIndex >= 5) return false;
    if (state.isGameOver || state.isExploding) return false;

    // Build speculative slots
    final newSlots = state.slots.map((s) => List<OperatorToken>.from(s)).toList();
    if (insertIndex != null && insertIndex >= 0 && insertIndex <= newSlots[slotIndex].length) {
      newSlots[slotIndex].insert(insertIndex, token);
    } else {
      newSlots[slotIndex].add(token);
    }

    // Validate if it violates hard constraints
    final isAllowed = MathEvaluator.canPlaceWithoutViolation(
      slots: newSlots,
      digits: state.digits,
      allowFractionalDivision: state.difficulty.allowFractionalDivision,
    );

    if (!isAllowed) {
      state = state.copyWith(
        lastError: 'Ação rejeitada: excede 10.000 ou gera divisão por zero',
      );
      return false;
    }

    final evaluation = MathEvaluator.evaluate(
      slots: newSlots,
      digits: state.digits,
      allowFractionalDivision: state.difficulty.allowFractionalDivision,
    );

    state = state.copyWith(
      slots: newSlots,
      evaluation: evaluation,
      clearError: true,
    );

    if (evaluation.isSolved) {
      _handleWinCondition();
    }

    return true;
  }

  void removeOperatorFromSlot(int slotIndex, int tokenIndex) {
    if (slotIndex < 0 || slotIndex >= 5) return;
    if (tokenIndex < 0 || tokenIndex >= state.slots[slotIndex].length) return;
    if (state.isGameOver || state.isExploding) return;

    final newSlots = state.slots.map((s) => List<OperatorToken>.from(s)).toList();
    newSlots[slotIndex].removeAt(tokenIndex);

    final evaluation = MathEvaluator.evaluate(
      slots: newSlots,
      digits: state.digits,
      allowFractionalDivision: state.difficulty.allowFractionalDivision,
    );

    state = state.copyWith(
      slots: newSlots,
      evaluation: evaluation,
      clearError: true,
    );
  }

  void clearSlots() {
    final freshSlots = List.generate(5, (_) => <OperatorToken>[]);
    state = state.copyWith(
      slots: freshSlots,
      clearError: true,
      evaluation: MathEvaluator.evaluate(
        slots: freshSlots,
        digits: state.digits,
        allowFractionalDivision: state.difficulty.allowFractionalDivision,
      ),
    );
  }

  void skipPlate() {
    if (state.isGameOver || state.isExploding) return;
    _spawnNextCar();
  }

  void surrender() {
    if (state.isGameOver) return;
    state = state.copyWith(
      hp: 0,
      isGameOver: true,
      timeRemaining: 0,
    );
    _timer?.cancel();
    _saveScoreToCloud();
  }

  void restartRun() {
    state = GameState.initial(difficulty: state.difficulty).copyWith(
      solvedPlates: state.solvedPlates,
    );
    _startTimer();
  }

  void setDifficulty(DifficultyLevel difficulty) {
    final freshSlots = List.generate(5, (_) => <OperatorToken>[]);
    state = state.copyWith(
      difficulty: difficulty,
      slots: freshSlots,
      clearError: true,
      evaluation: MathEvaluator.evaluate(
        slots: freshSlots,
        digits: state.digits,
        allowFractionalDivision: difficulty.allowFractionalDivision,
      ),
    );
  }

  void _handleWinCondition() {
    final solvedPlate = state.plateString;
    final updatedSolved = Set<String>.from(state.solvedPlates)..add(solvedPlate);

    state = state.copyWith(
      score: state.score + 1,
      isExploding: true,
      solvedPlates: updatedSolved,
    );

    _saveSolvedPlateToCloud(solvedPlate);

    // Car explosion animation delay before spawning next car
    Timer(const Duration(milliseconds: 900), () {
      _spawnNextCar();
    });
  }

  void _saveSolvedPlateToCloud(String plate) {
    final service = ref.read(firestoreServiceProvider);
    service.recordSolvedPlate(plate, state.score);
  }

  void _saveScoreToCloud() {
    final service = ref.read(firestoreServiceProvider);
    service.recordFinalScore(state.score);
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
