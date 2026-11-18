import 'package:flutter/material.dart';
import '../widgets/game_snackbar.dart';

/// Menampilkan dialog soal matematika dan mengembalikan `true` jika jawaban benar.
Future<bool> showQuestionDialog(
  BuildContext context, {
  required int targetPos,
  required Map<String, String> qna,
  bool isBonus = false,
}) async {
  final result = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder:
        (_) => _QuestionDialog(
          targetPos: targetPos,
          qna: qna,
          isBonus: isBonus,
        ),
  );
  return result ?? false;
}

class _QuestionDialog extends StatefulWidget {
  final int targetPos;
  final Map<String, String> qna;
  final bool isBonus;

  const _QuestionDialog({
    required this.targetPos,
    required this.qna,
    required this.isBonus,
  });

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  final TextEditingController _answerCtrl = TextEditingController();

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final input = _answerCtrl.text.trim();
    if (input.isEmpty) {
      showGameSnackBar(context, "Jawaban tidak boleh kosong!", Colors.orange);
      return;
    }
    Navigator.pop(context, input == widget.qna["answer"]);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [primaryColor.withValues(alpha: 0.8), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isBonus ? Icons.star : Icons.quiz,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isBonus
                  ? "Soal Bonus!"
                  : "Soal di Kotak ${widget.targetPos}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.qna["question"]!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Jawabanmu...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.edit, color: primaryColor),
              ),
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              onSubmitted: (_) => _submitAnswer(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitAnswer,
              icon: const Icon(Icons.check_circle),
              label: const Text("Kirim Jawaban"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
