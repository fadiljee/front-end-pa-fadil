import 'dart:math';

/// Generator soal aritmatika dinamis untuk papan Ular Tangga Matematika.
class GameQuestionGenerator {
  GameQuestionGenerator._();

  static final Random _random = Random();

  static int _randomBetween(int min, int max) =>
      _random.nextInt(max - min + 1) + min;

  /// Menghasilkan pasangan `{"question": ..., "answer": ...}` sesuai nomor kotak.
  static Map<String, String> generateForBox(int boxNumber) {
    int a;
    int b;
    String question;
    String answer;

    if (boxNumber >= 1 && boxNumber <= 6) {
      a = _randomBetween(1, 20);
      b = _randomBetween(1, 20);
      question = '$a + $b = ?';
      answer = (a + b).toString();
    } else if (boxNumber >= 7 && boxNumber <= 12) {
      a = _randomBetween(10, 40);
      b = _randomBetween(1, a);
      question = '$a - $b = ?';
      answer = (a - b).toString();
    } else if (boxNumber >= 13 && boxNumber <= 18) {
      a = _randomBetween(2, 12);
      b = _randomBetween(2, 12);
      question = '$a × $b = ?';
      answer = (a * b).toString();
    } else if (boxNumber >= 19 && boxNumber <= 24) {
      b = _randomBetween(2, 12);
      a = b * _randomBetween(2, 12);
      question = '$a ÷ $b = ?';
      answer = (a ~/ b).toString();
    } else {
      final op = _randomBetween(1, 4);
      switch (op) {
        case 1:
          a = _randomBetween(1, 50);
          b = _randomBetween(1, 50);
          question = '$a + $b = ?';
          answer = (a + b).toString();
        case 2:
          a = _randomBetween(20, 60);
          b = _randomBetween(1, a);
          question = '$a - $b = ?';
          answer = (a - b).toString();
        case 3:
          a = _randomBetween(2, 15);
          b = _randomBetween(2, 15);
          question = '$a × $b = ?';
          answer = (a * b).toString();
        case 4:
          b = _randomBetween(2, 15);
          a = b * _randomBetween(2, 15);
          question = '$a ÷ $b = ?';
          answer = (a ~/ b).toString();
        default:
          a = _randomBetween(1, 20);
          b = _randomBetween(1, 20);
          question = '$a + $b = ?';
          answer = (a + b).toString();
      }
    }

    return {'question': question, 'answer': answer};
  }
}
