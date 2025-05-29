import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ayobitung/screens/home_screen.dart'; // Pastikan path ini benar

class SnakesLaddersQuiz extends StatelessWidget {
  final String userName; // <--- Tambahkan properti userName
  final String nisn;     // <--- Tambahkan properti nisn

  const SnakesLaddersQuiz({
    Key? key,
    required this.userName, // <--- Wajib diisi saat membuat SnakesLaddersQuiz
    required this.nisn,     // <--- Wajib diisi saat membuat SnakesLaddersQuiz
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ular Tangga + Quiz Matematika',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        cardTheme: const CardTheme(
          elevation: 8,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      // Teruskan userName dan nisn ke GamePage
      home: GamePage(userName: userName, nisn: nisn),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamePage extends StatefulWidget {
  final String userName; // <--- Tambahkan properti userName
  final String nisn;     // <--- Tambahkan properti nisn

  const GamePage({
    Key? key,
    required this.userName, // <--- Wajib diisi saat membuat GamePage
    required this.nisn,     // <--- Wajib diisi saat membuat GamePage
  }) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  int player1Position = 1;
  int player2Position = 1;
  int diceValue = 1;
  bool isWaitingAnswer = false;
  int throwCount = 0;
  int bestScore = 0;
  bool isDiceRolling = false;
  bool isTwoPlayer = false;
  int currentPlayer = 1;

  late AnimationController _diceController;
  late AnimationController _playerController;
  late Animation<double> _diceAnimation;
  late Animation<double> _playerAnimation;

  final int boardSize = 30;

  final Map<int, int> ladders = {
    3: 22,
    5: 8,
    11: 26,
    20: 29,
  };

  final Map<int, int> snakes = {
    27: 1,
    21: 9,
    17: 4,
    19: 7,
  };

  late final Map<int, Map<String, String>> questions = {
    for (int i = 1; i <= boardSize; i++) i: _generateQuestion(i)
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ular Tangga + Quiz Matematika'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Reset Game',
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildLeaderboard(),
            const SizedBox(height: 8),
            buildGameStatus(),
            const SizedBox(height: 16),
            buildBoard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isDiceRolling || isWaitingAnswer ? null : rollDice,
              icon: const Icon(Icons.casino),
              label: Text(isDiceRolling ? "Mengocok..." : "Lempar Dadu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol Kembali ke HomeScreen
            ElevatedButton(
              onPressed: () {
                // Menavigasi kembali ke HomeScreen
                // Menggunakan pushReplacement agar GamePage dihapus dari stack
                // dan HomeScreen menjadi root baru, dengan data yang benar.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      userName: widget.userName, // <--- Meneruskan userName dari GamePage
                      nisn: widget.nisn,         // <--- Meneruskan nisn dari GamePage
                    ),
                  ),
                );
              },
              child: const Text('Kembali ke Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _playerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _diceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.elasticOut),
    );
    _playerAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _playerController, curve: Curves.elasticInOut),
    );
    _loadBestScore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModeSelectionDialog();
    });
  }

  Map<String, String> _generateQuestion(int boxNumber) {
    int a = boxNumber;
    int b = boxNumber % 5 + 1;

    String question = "";
    String answer = "";

    switch (boxNumber % 4) {
      case 0:
        question = "$a + $b = ?";
        answer = (a + b).toString();
        break;
      case 1:
        question = "$a - $b = ?";
        answer = (a - b).toString();
        break;
      case 2:
        question = "$a × $b = ?";
        answer = (a * b).toString();
        break;
      case 3:
        int c = b == 0 ? 1 : b;
        int d = (a * c);
        question = "$d ÷ $c = ?";
        answer = (d ~/ c).toString();
        break;
    }
    return {"question": question, "answer": answer};
  }

  @override
  void dispose() {
    _diceController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (bestScore == 0 || score < bestScore) {
      await prefs.setInt('bestScore', score);
      setState(() {
        bestScore = score;
      });
    }
  }

  void rollDice() async {
    if (isWaitingAnswer || isDiceRolling) return;

    setState(() {
      isDiceRolling = true;
    });

    _diceController.forward();

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        diceValue = Random().nextInt(6) + 1;
      });
    }

    _diceController.reset();

    int currentPos = currentPlayer == 1 ? player1Position : player2Position;
    int tentativePos = currentPos + diceValue;

    if (tentativePos > boardSize) {
      _showCustomSnackBar("🚫 Tidak bisa maju, harus pas di kotak $boardSize", Colors.orange);
      setState(() {
        isDiceRolling = false;
      });
      return;
    }

    setState(() {
      throwCount++;
      isWaitingAnswer = true;
    });

    bool correct = await showQuestionDialog(questions[tentativePos]!);

    setState(() {
      isWaitingAnswer = false;
      isDiceRolling = false;
    });

    if (correct) {
      await movePlayer(tentativePos);
    } else {
      _showCustomSnackBar("❌ Jawaban salah, tetap di kotak sekarang.", Colors.red);
      _switchPlayer();
    }
  }

  Future<void> movePlayer(int pos) async {
    _playerController.forward().then((_) => _playerController.reverse());

    setState(() {
      if (currentPlayer == 1) {
        player1Position = pos;
      } else {
        player2Position = pos;
      }
    });
    _showCustomSnackBar("🎯 Player $currentPlayer maju ke kotak $pos", Colors.blue);

    await Future.delayed(const Duration(milliseconds: 800));

    if (ladders.containsKey(pos)) {
      // Tanya soal dulu sebelum naik tangga
      bool canClimb = await handleLadderQuestion(pos);
      if (canClimb) {
        int newPos = ladders[pos]!;
        setState(() {
          if (currentPlayer == 1) {
            player1Position = newPos;
          } else {
            player2Position = newPos;
          }
        });
        _showCustomSnackBar("🪜 Player $currentPlayer naik tangga ke kotak $newPos!", Colors.green);
        _playerController.forward().then((_) => _playerController.reverse());
        await Future.delayed(const Duration(milliseconds: 800));
        pos = newPos;
      } else {
        _showCustomSnackBar("❌ Jawaban salah, tetap di kotak tangga $pos.", Colors.red);
        // Tetap di kotak tangga, tidak naik
      }
    } else if (snakes.containsKey(pos)) {
      // Tanya soal di kotak ular sebelum turun
      bool stay = await handleSnakeQuestion(pos);
      if (!stay) {
        int newPos = snakes[pos]!;
        setState(() {
          if (currentPlayer == 1) {
            player1Position = newPos;
          } else {
            player2Position = newPos;
          }
        });
        _showCustomSnackBar("🐍 Player $currentPlayer terjatuh ular ke kotak $newPos", Colors.red);
        _playerController.forward().then((_) => _playerController.reverse());
        await Future.delayed(const Duration(milliseconds: 800));
        pos = newPos;
      } else {
        _showCustomSnackBar("✅ Player $currentPlayer berhasil menahan diri di kotak ular $pos!", Colors.green);
      }
    }

    if (pos == boardSize) {
      await showWinDialog(currentPlayer);
      resetGame();
    } else {
      _switchPlayer();
    }
  }

  Future<bool> handleLadderQuestion(int ladderPos) async {
    Map<String, String> qna = questions[ladderPos] ?? {"question": "1 + 1 = ?", "answer": "2"};
    bool correct = await showQuestionDialog(qna);
    return correct; // true = bisa naik, false = tetap di kotak tangga
  }

  Future<bool> handleSnakeQuestion(int snakePos) async {
    Map<String, String> qna = questions[snakePos] ?? {"question": "1 + 1 = ?", "answer": "2"};
    bool correct = await showQuestionDialog(qna);
    return correct; // true = tetap di kotak ular, false = turun ular
  }

  void _switchPlayer() {
    if (!isTwoPlayer) return;
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
    });
    _showCustomSnackBar("🔄 Giliran Player $currentPlayer", Colors.purple);
  }

  Future<bool> showQuestionDialog(Map<String, String> qna) async {
    TextEditingController answerCtrl = TextEditingController();
    bool isCorrect = false;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade200, Colors.orange.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz, size: 48, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      "🧮 Soal di kotak ${currentPlayer == 1 ? player1Position + diceValue : player2Position + diceValue}",
                      style: const TextStyle(
                        fontSize: 20,
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
                        qna["question"]!,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: answerCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Masukkan jawaban",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        String input = answerCtrl.text.trim();
                        if (input.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Jawaban tidak boleh kosong"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        if (input == qna["answer"]) {
                          isCorrect = true;
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Jawaban salah, giliran beralih."),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return isCorrect;
  }

  Future<void> showWinDialog(int player) async {
    await _saveBestScore(throwCount);
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                "🎉 Selamat Player $player! 🎉",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Kamu sudah mencapai kotak terakhir!\n\n🎲 Lemparan total: $throwCount\n🏆 Best Score: ${bestScore == 0 ? 'Belum ada' : bestScore}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Tutup"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetGame() {
    setState(() {
      player1Position = 1;
      player2Position = 1;
      diceValue = 1;
      isWaitingAnswer = false;
      throwCount = 0;
      isDiceRolling = false;
      currentPlayer = 1;
    });
    _showCustomSnackBar("🔄 Game di-reset", Colors.blue);
  }

  void _showCustomSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showModeSelectionDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pilih Mode Game"),
          content: const Text("Apakah kamu ingin bermain 1 pemain atau 2 pemain?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isTwoPlayer = false;
                });
                Navigator.pop(context);
              },
              child: const Text("1 Player"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isTwoPlayer = true;
                });
                Navigator.pop(context);
              },
              child: const Text("2 Player"),
            ),
          ],
        );
      },
    );
    _showCustomSnackBar("Mode ${isTwoPlayer ? "2 Player" : "1 Player"} dipilih", Colors.green);
  }

  Widget buildBoard() {
    int columns = 6;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: boardSize,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          int boxNumber = index + 1;

          bool hasPlayer1 = boxNumber == player1Position;
          bool hasPlayer2 = boxNumber == player2Position;
          bool hasLadder = ladders.containsKey(boxNumber);
          bool hasSnake = snakes.containsKey(boxNumber);

          Color borderColor = Colors.grey.shade300;
          List<Color> gradientColors = [Colors.white, Colors.grey.shade50];

          if (hasPlayer1 && hasPlayer2) {
            gradientColors = [Colors.purple.shade400, Colors.purple.shade600];
            borderColor = Colors.purple.shade900;
          } else if (hasPlayer1) {
            gradientColors = [Colors.blue.shade300, Colors.blue.shade500];
            borderColor = Colors.blue.shade700;
          } else if (hasPlayer2) {
            gradientColors = [Colors.red.shade300, Colors.red.shade500];
            borderColor = Colors.red.shade700;
          } else if (hasLadder) {
            gradientColors = [Colors.green.shade200, Colors.green.shade400];
            borderColor = Colors.green.shade600;
          } else if (hasSnake) {
            gradientColors = [Colors.red.shade200, Colors.red.shade400];
            borderColor = Colors.red.shade600;
          } else {
            gradientColors = [Colors.orange.shade200, Colors.orange.shade400];
            borderColor = Colors.orange.shade600;
          }

          return AnimatedBuilder(
            animation: _playerAnimation,
            builder: (context, child) {
              double scale = (hasPlayer1 || hasPlayer2) ? _playerAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          "$boxNumber",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: (hasPlayer1 || hasPlayer2) ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (hasPlayer1)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
                          ),
                        ),
                      if (hasPlayer2)
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
                          ),
                        ),
                      if (hasLadder)
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                          ),
                        ),
                      if (hasSnake)
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildLeaderboard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
        title: const Text(
          "🏆 Best Score",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          "Lemparan Minimal",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            bestScore == 0 ? "-" : bestScore.toString(),
            style: TextStyle(
              color: Colors.purple.shade600,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 24),
              const SizedBox(height: 4),
              const Text("Player 1 Pos", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$player1Position",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.person, color: Colors.red, size: 24),
              const SizedBox(height: 4),
              const Text("Player 2 Pos", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$player2Position",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              AnimatedBuilder(
                animation: _diceAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _diceAnimation.value * 2 * pi,
                    child: Icon(
                      Icons.casino,
                      color: Colors.white,
                      size: 24 + (_diceAnimation.value * 8),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text("Dadu", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$diceValue",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.sports_score, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              const Text("Lemparan", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$throwCount",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.account_circle, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              const Text("Giliran", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                "$currentPlayer",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}