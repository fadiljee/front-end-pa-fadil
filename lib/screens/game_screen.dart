import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ayobitung/screens/home_screen.dart';
import 'package:audioplayers/audioplayers.dart'; // Import package audioplayers

// Kelas utama aplikasi, menginisialisasi tema dan halaman utama
class SnakesLaddersQuiz extends StatelessWidget {
  final String userName;
  final String nisn;

  const SnakesLaddersQuiz({
    Key? key,
    required this.userName,
    required this.nisn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ular Tangga Matematika Keren',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily:
            'Poppins', // Gunakan font yang lebih modern (tambahkan di pubspec.yaml)
        scaffoldBackgroundColor: const Color(
          0xFFF0F8FF,
        ), // Warna latar belakang yang lembut
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // Warna dasar tema
          brightness: Brightness.light,
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFFFFA000),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: GamePage(userName: userName, nisn: nisn),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Halaman utama permainan
class GamePage extends StatefulWidget {
  final String userName;
  final String nisn;

  const GamePage({Key? key, required this.userName, required this.nisn})
    : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  // State utama permainan
  int player1Position = 1;
  int player2Position = 1;
  int diceValue = 1;
  bool isWaitingAnswer = false;
  int throwCount = 0;
  int bestScore = 0;
  bool isDiceRolling = false;
  bool isTwoPlayer = false;
  int currentPlayer = 1;

  // Controller untuk animasi
  late AnimationController _diceController;
  late AnimationController _playerController;
  late Animation<double> _diceAnimation;
  late Animation<double> _playerAnimation;

  final int boardSize = 30;
  final int boardColumns = 6;

  // Definisi tangga
  final Map<int, int> ladders = {3: 22, 5: 8, 11: 26, 20: 29};

  // Definisi ular
  final Map<int, int> snakes = {27: 1, 21: 9, 17: 4, 19: 7};

  // Generate pertanyaan untuk setiap kotak
  late final Map<int, Map<String, String>> questions = {
    for (int i = 1; i <= boardSize; i++) i: _generateQuestion(i),
  };

  late AudioPlayer _audioPlayer; // Deklarasi AudioPlayer
  bool _isMusicPlaying = true; // State untuk mengontrol status musik



  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _playerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _diceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.elasticOut),
    );
    _playerAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _playerController, curve: Curves.easeInOut),
    );

    _loadBestScore();

    // Inisialisasi dan mulai musik
    _audioPlayer = AudioPlayer();
    _playBackgroundMusic();

    // Tampilkan dialog pemilihan mode setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModeSelectionDialog();
    });
  }

  // Fungsi untuk generate pertanyaan matematika berdasarkan nomor kotak
  Map<String, String> _generateQuestion(int boxNumber) {
    int a, b;
    String question;
    String answer;

    // Fungsi bantu untuk generate angka random antara min dan max
    int randomBetween(int min, int max) =>
        Random().nextInt(max - min + 1) + min;

    if (boxNumber >= 1 && boxNumber <= 6) {
      // Penjumlahan
      a = randomBetween(1, 20);
      b = randomBetween(1, 20);
      question = "$a + $b = ?";
      answer = (a + b).toString();
    } else if (boxNumber >= 7 && boxNumber <= 12) {
      // Pengurangan, pastikan hasil >= 0
      a = randomBetween(10, 40);
      b = randomBetween(1, a);
      question = "$a - $b = ?";
      answer = (a - b).toString();
    } else if (boxNumber >= 13 && boxNumber <= 18) {
      // Perkalian
      a = randomBetween(2, 12);
      b = randomBetween(2, 12);
      question = "$a × $b = ?";
      answer = (a * b).toString();
    } else if (boxNumber >= 19 && boxNumber <= 24) {
      // Pembagian, pastikan hasil bulat
      b = randomBetween(2, 12);
      int product = b * randomBetween(2, 12);
      a = product;
      question = "$a ÷ $b = ?";
      answer = (a ~/ b).toString();
    } else {
      // Campuran operasi untuk kotak 25 ke atas
      int op = randomBetween(1, 4);
      switch (op) {
        case 1:
          a = randomBetween(1, 50);
          b = randomBetween(1, 50);
          question = "$a + $b = ?";
          answer = (a + b).toString();
          break;
        case 2:
          a = randomBetween(20, 60);
          b = randomBetween(1, a);
          question = "$a - $b = ?";
          answer = (a - b).toString();
          break;
        case 3:
          a = randomBetween(2, 15);
          b = randomBetween(2, 15);
          question = "$a × $b = ?";
          answer = (a * b).toString();
          break;
        case 4:
          b = randomBetween(2, 15);
          int product = b * randomBetween(2, 15);
          a = product;
          question = "$a ÷ $b = ?";
          answer = (a ~/ b).toString();
          break;
        default:
          // fallback ke penjumlahan
          a = randomBetween(1, 20);
          b = randomBetween(1, 20);
          question = "$a + $b = ?";
          answer = (a + b).toString();
      }
    }

    return {"question": question, "answer": answer};
  }

  // Fungsi untuk memutar musik latar
  void _playBackgroundMusic() async {
    // Pastikan path ke file musik benar dan terdaftar di pubspec.yaml
    await _audioPlayer.setReleaseMode(
      ReleaseMode.loop,
    ); // Mengulang musik terus-menerus
    await _audioPlayer.setVolume(0.5); // Atur volume (0.0 - 1.0)
    await _audioPlayer.play(
      AssetSource('music/song.mp3'),
    ); // Pastikan nama file dan path benar
  }

  // Fungsi untuk menghentikan musik (opsional, jika ingin menghentikan secara eksplisit)
  void _stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  // Fungsi untuk menjeda/melanjutkan musik
  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
      if (_isMusicPlaying) {
        _audioPlayer.resume(); // Melanjutkan pemutaran
      } else {
        _audioPlayer.pause(); // Menjeda pemutaran
      }
    });
  }

  @override
  void dispose() {
    _diceController.dispose();
    _playerController.dispose();
    _audioPlayer.dispose(); // Sangat penting untuk membuang audio player
    super.dispose();
  }

  // Memuat skor terbaik dari SharedPreferences
  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  // Menyimpan skor terbaik ke SharedPreferences
  Future<void> _saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    if (bestScore == 0 || score < bestScore) {
      await prefs.setInt('bestScore', score);
      setState(() {
        bestScore = score;
      });
    }
  }

  // Logika utama saat tombol "Lempar Dadu" ditekan
  void rollDice() async {
    if (isWaitingAnswer || isDiceRolling) return;

    setState(() {
      isDiceRolling = true;
    });
    _diceController.forward(from: 0);

    // Animasi kocok dadu
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      setState(() {
        diceValue = Random().nextInt(6) + 1;
      });
    }

    int currentPos = currentPlayer == 1 ? player1Position : player2Position;
    int tentativePos = currentPos + diceValue;

    if (tentativePos > boardSize) {
      _showCustomSnackBar(
        "🚫 Langkah terlalu besar, harus pas di kotak $boardSize!",
        Colors.orange,
      );
      setState(() {
        isDiceRolling = false;
      });
      _switchPlayer(); // Ganti giliran jika langkah terlalu besar
      return;
    }

    setState(() {
      throwCount++;
      isWaitingAnswer = true;
    });

    // Tampilkan dialog pertanyaan
    bool correct = await showQuestionDialog(tentativePos);

    setState(() {
      isWaitingAnswer = false;
      isDiceRolling = false;
    });

    if (correct) {
      await movePlayer(tentativePos);
    } else {
      _showCustomSnackBar(
        "❌ Jawaban salah! Tetap di tempat.",
        Colors.redAccent,
      );
      _switchPlayer();
    }
  }

  // Logika pergerakan pemain di papan
  Future<void> movePlayer(int newPos) async {
    setState(() {
      if (currentPlayer == 1) {
        player1Position = newPos;
      } else {
        player2Position = newPos;
      }
    });
    _playerController.forward(from: 0);
    _showCustomSnackBar(
      "👍 Player $currentPlayer maju ke kotak $newPos",
      Colors.green,
    );
    await Future.delayed(const Duration(milliseconds: 600));

    // Cek apakah ada tangga
    if (ladders.containsKey(newPos)) {
      _showCustomSnackBar(
        "✨ Wow, dapat tangga! Jawab soal untuk naik.",
        Colors.cyan,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      bool canClimb = await showQuestionDialog(newPos, isBonus: true);
      if (canClimb) {
        int finalPos = ladders[newPos]!;
        setState(() {
          if (currentPlayer == 1)
            player1Position = finalPos;
          else
            player2Position = finalPos;
        });
        _playerController.forward(from: 0);
        _showCustomSnackBar(
          "🪜 Berhasil! Naik ke kotak $finalPos!",
          Colors.green,
        );
      } else {
        _showCustomSnackBar(
          "😥 Gagal naik tangga, jawaban salah.",
          Colors.orange,
        );
      }
    }
    // Cek apakah ada ular
    else if (snakes.containsKey(newPos)) {
      _showCustomSnackBar(
        "😱 Awas, ada ular! Jawab soal agar tidak turun.",
        Colors.orangeAccent,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      bool canAvoid = await showQuestionDialog(newPos, isBonus: true);
      if (canAvoid) {
        _showCustomSnackBar("✅ Fiuhh! Selamat dari ular!", Colors.green);
      } else {
        int finalPos = snakes[newPos]!;
        setState(() {
          if (currentPlayer == 1)
            player1Position = finalPos;
          else
            player2Position = finalPos;
        });
        _playerController.forward(from: 0);
        _showCustomSnackBar(
          "🐍 Yah, turun ke kotak $finalPos!",
          Colors.redAccent,
        );
      }
    }

    // Cek kemenangan
    int finalPosition = currentPlayer == 1 ? player1Position : player2Position;
    if (finalPosition == boardSize) {
      await showWinDialog(currentPlayer);
      resetGame();
    } else {
      _switchPlayer();
    }
  }

  // Ganti giliran pemain
  void _switchPlayer() {
    if (!isTwoPlayer) return;
    setState(() {
      currentPlayer = (currentPlayer == 1) ? 2 : 1;
    });
    _showCustomSnackBar("🔄 Giliran Player $currentPlayer", Colors.blueGrey);
  }

  // Menampilkan dialog pertanyaan
  Future<bool> showQuestionDialog(int targetPos, {bool isBonus = false}) async {
    TextEditingController answerCtrl = TextEditingController();
    bool isCorrect = false;
    final qna = questions[targetPos]!;

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isBonus ? Icons.star : Icons.quiz,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isBonus ? "Soal Bonus!" : "Soal di Kotak $targetPos",
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
                    qna["question"]!,
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
                  controller: answerCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Jawabanmu...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onSubmitted: (value) {
                    // Memungkinkan submit dengan keyboard
                    String input = answerCtrl.text.trim();
                    if (input.isNotEmpty) {
                      isCorrect = (input == qna["answer"]);
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    String input = answerCtrl.text.trim();
                    if (input.isNotEmpty) {
                      isCorrect = (input == qna["answer"]);
                      Navigator.pop(context);
                    } else {
                      _showCustomSnackBar(
                        "Jawaban tidak boleh kosong!",
                        Colors.orange,
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Kirim Jawaban"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
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
      },
    );
    return isCorrect;
  }

  // Menampilkan dialog kemenangan
  Future<void> showWinDialog(int player) async {
    if (!isTwoPlayer) await _saveBestScore(throwCount);

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    "✨ SELAMAT PLAYER $player! ✨",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isTwoPlayer)
                    Text(
                      "Kamu menang dalam $throwCount lemparan!\nSkor Terbaik: $bestScore",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      resetGame();
                    },
                    icon: const Icon(Icons.celebration),
                    label: const Text("Main Lagi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFFA000),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Mereset state permainan ke awal
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
    _showCustomSnackBar("🔄 Permainan dimulai ulang!", Colors.blueGrey);
  }

  // Menampilkan notifikasi custom (SnackBar)
  void _showCustomSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Menampilkan dialog pemilihan mode permainan
  Future<void> _showModeSelectionDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        // Menggunakan Dialog biasa untuk kontrol penuh atas layout
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Membuat Column sesuai ukuran konten
              children: [
                // Header Dialog
                Icon(
                  Icons.gamepad_rounded,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pilih Mode Permainan",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mau bermain sendiri atau tantang temanmu?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Tombol Pilihan (Layout Column)
                SizedBox(
                  width:
                      double.infinity, // Membuat tombol memenuhi lebar dialog
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text("1 Pemain (Solo)"),
                    onPressed: () {
                      setState(() => isTwoPlayer = false);
                      Navigator.pop(context);
                      _showCustomSnackBar(
                        "Mode 1 Pemain dipilih. Lawan dirimu sendiri!",
                        Colors.teal,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width:
                      double.infinity, // Membuat tombol memenuhi lebar dialog
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text("2 Pemain (Duel)"),
                    onPressed: () {
                      setState(() => isTwoPlayer = true);
                      Navigator.pop(context);
                      _showCustomSnackBar(
                        "Mode 2 Pemain dipilih. Ajak temanmu!",
                        Colors.amber.shade700,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget utama yang membangun seluruh tampilan
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              const Text(
                'Ular Tangga Matematika',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                'Lempar dadu, jawab soal, dan capai garis finis!',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8), // Sedikit ruang tambahan
              // Tombol untuk mengontrol musik
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _toggleMusic,
                  tooltip: _isMusicPlaying ? "Matikan Musik" : "Putar Musik",
                ),
              ),
              const SizedBox(height: 8),

              // Skor dan Status
              buildGameStatus(),
              if (!isTwoPlayer) ...[
                const SizedBox(height: 8),
                buildLeaderboard(),
              ],
              const SizedBox(height: 20),

              // Papan Permainan
              buildBoard(),
              const SizedBox(height: 20),

              // Kontrol Permainan
              buildGameControls(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk papan permainan
  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1, // Membuat papan selalu persegi
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: boardSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardColumns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            // *** LOGIKA BARU UNTUK PENOMORAN DARI BAWAH KIRI ***
            int row = index ~/ boardColumns;
            int col = index % boardColumns;
            int invertedRow = (boardSize - 1) ~/ boardColumns - row;
            int boxNumber;
            if (invertedRow % 2 == 0) {
              // Baris genap (0, 2, 4): Kiri ke Kanan
              boxNumber = invertedRow * boardColumns + col + 1;
            } else {
              // Baris ganjil (1, 3, 5): Kanan ke Kiri
              boxNumber =
                  invertedRow * boardColumns + (boardColumns - 1 - col) + 1;
            }
            // *** AKHIR LOGIKA BARU ***

            bool hasLadder = ladders.containsKey(boxNumber);
            bool hasSnake = snakes.containsKey(boxNumber);

            return AnimatedBuilder(
              animation: _playerAnimation,
              builder: (context, child) {
                bool hasPlayer1 = player1Position == boxNumber;
                bool hasPlayer2 = isTwoPlayer && player2Position == boxNumber;
                double scale =
                    (hasPlayer1 && currentPlayer == 1) ||
                            (hasPlayer2 && currentPlayer == 2)
                        ? _playerAnimation.value
                        : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (invertedRow + col) % 2 == 0
                              ? const Color(0xFFE0F2F1)
                              : const Color(0xFFB2DFDB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Nomor Kotak
                        Text(
                          "$boxNumber",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        // Ikon Ular dan Tangga
                        if (hasLadder)
                          Text(
                            "🪜",
                            style: TextStyle(
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        if (hasSnake)
                          Text(
                            "🐍",
                            style: TextStyle(
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                        // Pion Pemain
                        if (hasPlayer1 && hasPlayer2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [buildPlayerPawn(1), buildPlayerPawn(2)],
                          )
                        else if (hasPlayer1)
                          buildPlayerPawn(1)
                        else if (hasPlayer2)
                          buildPlayerPawn(2),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Widget untuk pion pemain
  Widget buildPlayerPawn(int player) {
    return CircleAvatar(
      backgroundColor: player == 1 ? Colors.blue.shade700 : Colors.red.shade700,
      radius: 14,
      child: Text(
        "P$player",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget untuk panel skor terbaik
  Widget buildLeaderboard() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.star,
          color: Theme.of(context).colorScheme.secondary,
          size: 32,
        ),
        title: const Text(
          "Skor Terbaik",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Jumlah lemparan paling sedikit"),
        trailing: Text(
          bestScore == 0 ? "-" : bestScore.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget untuk panel status permainan
  Widget buildGameStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatusColumn(
              icon: Icons.person,
              label: "Player 1",
              value: player1Position.toString(),
              color: Colors.blue.shade700,
              isActive: currentPlayer == 1,
            ),
            if (isTwoPlayer)
              _buildStatusColumn(
                icon: Icons.person,
                label: "Player 2",
                value: player2Position.toString(),
                color: Colors.red.shade700,
                isActive: currentPlayer == 2,
              ),
            _buildStatusColumn(
              icon: Icons.casino,
              label: "Dadu",
              value: diceValue.toString(),
              color: Colors.grey.shade700,
            ),
            _buildStatusColumn(
              icon: Icons.score,
              label: "Lemparan",
              value: throwCount.toString(),
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat kolom di panel status
  Widget _buildStatusColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol-tombol kontrol
  Widget buildGameControls() {
    return Column(
      children: [
        // Dadu
        AnimatedBuilder(
          animation: _diceController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _diceAnimation.value * 2 * pi,
              child: Transform.scale(
                scale: 1 + (_diceAnimation.value * 0.2),
                child: Icon(
                  diceValue == 1
                      ? Icons.filter_1
                      : diceValue == 2
                      ? Icons.filter_2
                      : diceValue == 3
                      ? Icons.filter_3
                      : diceValue == 4
                      ? Icons.filter_4
                      : diceValue == 5
                      ? Icons.filter_5
                      : Icons.filter_6,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Tombol Lempar Dadu
        ElevatedButton.icon(
          onPressed: isDiceRolling || isWaitingAnswer ? null : rollDice,
          icon: const Icon(Icons.casino_outlined),
          label: Text(
            isDiceRolling
                ? "Mengacak..."
                : isWaitingAnswer
                ? "Menunggu Jawaban..."
                : "Lempar Dadu! (P$currentPlayer)",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol Kembali dan Reset
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali"),
                onPressed: () {
                  // Pastikan untuk menghentikan musik saat kembali ke halaman sebelumnya
                  _stopBackgroundMusic();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HomeScreen(
                            userName: widget.userName,
                            nisn: widget.nisn,
                          ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                onPressed: resetGame,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
