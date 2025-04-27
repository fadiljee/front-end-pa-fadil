import 'package:flutter/material.dart';

void main() {
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PuzzleGame(),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<int> availableNumbers = [4, 16, 3, 9, 1, 5, 15, 3, 9]; // Pilihan angka
  Map<String, String> answers = {
    'box1': '',
    'box2': '',
    'box3': '',
    'box4': '',
    'box5': '',
    'box6': '',
    'box7': '',
    'box8': '',
    'box9': '',
  };
  
  // Soal Matematika yang harus diselesaikan
  final Map<String, String> problems = {
    'box1': '3 + 1',
    'box2': '2 x 2',
    'box3': '5 + 10',
    'box4': '3 x 4',
    'box5': '3 x 12',
    'box6': '6 / 2',
    'box7': '8 + 5',
    'box8': '6 x 5',
    'box9': '5 x 3',
  };

  final Map<String, int> correctAnswers = {
    'box1': 4,  // 3 + 1 = 4
    'box2': 4,  // 2 x 2 = 4
    'box3': 15, // 5 + 10 = 15
    'box4': 12, // 3 x 4 = 12
    'box5': 36, // 3 x 12 = 36
    'box6': 3,  // 6 / 2 = 3
    'box7': 13, // 8 + 5 = 13
    'box8': 30, // 6 x 5 = 30
    'box9': 15, // 5 x 3 = 15
  };

  // Fungsi untuk memilih angka
  void selectNumber(String box, int number) {
    setState(() {
      answers[box] = number.toString();
    });
    checkAnswer(box);
  }

  // Fungsi untuk memeriksa jawaban
  void checkAnswer(String box) {
    if (answers[box] == correctAnswers[box].toString()) {
      // Jika jawaban benar, cek apakah semua kotak sudah terisi
      if (answers['box1'] != '' &&
          answers['box2'] != '' &&
          answers['box3'] != '' &&
          answers['box4'] != '' &&
          answers['box5'] != '' &&
          answers['box6'] != '' &&
          answers['box7'] != '' &&
          answers['box8'] != '' &&
          answers['box9'] != '') {
        showVictoryDialog();
      }
    } else {
      // Jika salah, reset kotak
      setState(() {
        answers[box] = '';
      });
    }
  }

  // Dialog kemenangan
  void showVictoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Victory'),
          content: Text('Congratulations, you solved all problems correctly!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  answers = {
                    'box1': '',
                    'box2': '',
                    'box3': '',
                    'box4': '',
                    'box5': '',
                    'box6': '',
                    'box7': '',
                    'box8': '',
                    'box9': ''
                  }; // Reset game
                });
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Math Puzzle Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Puzzle Grid 3x3 untuk soal
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                String boxKey = 'box${index + 1}';
                return GestureDetector(
                  onTap: () {
                    selectNumber(boxKey, availableNumbers[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        answers[boxKey] == '' ? 'x' : answers[boxKey]!,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Number Picker
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: availableNumbers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Assign number to the selected box
                    selectNumber('box1', availableNumbers[index]); // Example for box1
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      availableNumbers[index].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
