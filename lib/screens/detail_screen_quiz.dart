import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  const QuizDetailScreen({super.key});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool quizFinished = false;

  List<Map<String, dynamic>> questions = [
    {
      'question': 'Berapa hasil dari 7 + 5?',
      'options': ['10', '12', '14', '15'],
      'answer': '12',
    },
    {
      'question': 'Berapakah hasil 9 x 3?',
      'options': ['27', '29', '26', '30'],
      'answer': '27',
    },
    {
      'question': 'Hasil dari 20 - 8 adalah?',
      'options': ['11', '10', '12', '13'],
      'answer': '12',
    },
  ];

  String? selectedOption;

  void checkAnswerAndNext() {
    if (selectedOption == questions[currentQuestionIndex]['answer']) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
      });
    } else {
      setState(() {
        quizFinished = true;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      score = 0;
      currentQuestionIndex = 0;
      quizFinished = false;
      selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Skor Kamu:',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '$score / ${questions.length}',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetQuiz,
                child: Text('Ulangi Kuis'),
              )
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soal ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 24),
            ...currentQuestion['options'].map<Widget>((option) {
              final isSelected = selectedOption == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[200] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.black26,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedOption == null ? null : checkAnswerAndNext,
              child: Text(
                currentQuestionIndex == questions.length - 1
                    ? 'Selesai'
                    : 'Selanjutnya',
              ),
            )
          ],
        ),
      ),
    );
  }
}
