import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/storage/session_store.dart';
import '../game_question_generator.dart';

/// Mengelola state permainan ular tangga, aturan papan, dan skor terbaik.
class GameController extends ChangeNotifier {
  final SessionStore _sessionStore;
  final Random _random = Random();

  GameController({SessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SessionStore();

  final int boardSize = 30;
  final int boardColumns = 6;

  final Map<int, int> ladders = const {3: 22, 5: 8, 11: 26, 20: 29};
  final Map<int, int> snakes = const {27: 1, 21: 9, 17: 4, 19: 7};

  late final Map<int, Map<String, String>> questions = {
    for (int i = 1; i <= boardSize; i++)
      i: GameQuestionGenerator.generateForBox(i),
  };

  int player1Position = 1;
  int player2Position = 1;
  int diceValue = 1;
  bool isWaitingAnswer = false;
  int throwCount = 0;
  int bestScore = 0;
  bool isDiceRolling = false;
  bool isTwoPlayer = false;
  int currentPlayer = 1;

  int get currentPlayerPosition =>
      currentPlayer == 1 ? player1Position : player2Position;

  Future<void> loadBestScore(String nisn) async {
    bestScore = await _sessionStore.getBestScore(nisn);
    notifyListeners();
  }

  Future<void> saveBestScore(String nisn, int score) async {
    bestScore = await _sessionStore.saveBestScoreIfBetter(nisn, score);
    notifyListeners();
  }

  void setTwoPlayer(bool value) {
    isTwoPlayer = value;
    notifyListeners();
  }

  void setDiceRolling(bool value) {
    isDiceRolling = value;
    notifyListeners();
  }

  void randomizeDiceValue() {
    diceValue = _random.nextInt(6) + 1;
    notifyListeners();
  }

  void startTurnWaitingAnswer() {
    throwCount++;
    isWaitingAnswer = true;
    notifyListeners();
  }

  void finishTurn() {
    isWaitingAnswer = false;
    isDiceRolling = false;
    notifyListeners();
  }

  void setCurrentPlayerPosition(int pos) {
    if (currentPlayer == 1) {
      player1Position = pos;
    } else {
      player2Position = pos;
    }
    notifyListeners();
  }

  /// Mengganti giliran pada mode 2 pemain. Mengembalikan `true` jika giliran berubah.
  bool switchPlayer() {
    if (!isTwoPlayer) return false;
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    notifyListeners();
    return true;
  }

  void resetGame() {
    player1Position = 1;
    player2Position = 1;
    diceValue = 1;
    isWaitingAnswer = false;
    throwCount = 0;
    isDiceRolling = false;
    currentPlayer = 1;
    notifyListeners();
  }
}
