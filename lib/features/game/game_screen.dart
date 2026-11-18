import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'controllers/game_controller.dart';
import 'dialogs/mode_selection_dialog.dart';
import 'dialogs/question_dialog.dart';
import 'dialogs/win_dialog.dart';
import 'services/game_audio_service.dart';
import 'widgets/game_board.dart';
import 'widgets/game_controls.dart';
import 'widgets/game_snackbar.dart';
import 'widgets/game_status_card.dart';

/// Kelas utama aplikasi permainan ular tangga matematika.
class SnakesLaddersQuiz extends StatelessWidget {
  final String userName;
  final String nisn;

  const SnakesLaddersQuiz({
    super.key,
    required this.userName,
    required this.nisn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ular Tangga Matematika Keren',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
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

/// Halaman utama permainan ular tangga matematika.
class GamePage extends StatefulWidget {
  final String userName;
  final String nisn;

  const GamePage({super.key, required this.userName, required this.nisn});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final GameController _controller = GameController();
  final GameAudioService _audioService = GameAudioService();

  late final AnimationController _diceController;
  late final AnimationController _playerController;
  late final Animation<double> _diceAnimation;
  late final Animation<double> _playerAnimation;

  @override
  void initState() {
    super.initState();
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

    _controller.loadBestScore(widget.nisn);
    _audioService.playBackgroundMusic();

    WidgetsBinding.instance.addPostFrameCallback((_) => _promptModeSelection());
  }

  @override
  void dispose() {
    _diceController.dispose();
    _playerController.dispose();
    _audioService.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _promptModeSelection() async {
    final twoPlayers = await showModeSelectionDialog(context);
    if (!mounted || twoPlayers == null) return;

    _controller.setTwoPlayer(twoPlayers);
    if (twoPlayers) {
      showGameSnackBar(
        context,
        "Mode 2 Pemain dipilih. Ajak temanmu!",
        Colors.amber.shade700,
      );
    } else {
      showGameSnackBar(
        context,
        "Mode 1 Pemain dipilih. Lawan dirimu sendiri!",
        Colors.teal,
      );
    }
  }

  Future<void> _toggleMusic() async {
    await _audioService.toggle();
    if (mounted) setState(() {});
  }

  Future<void> _rollDice() async {
    if (_controller.isWaitingAnswer || _controller.isDiceRolling) return;

    _controller.setDiceRolling(true);
    _diceController.forward(from: 0);

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      _controller.randomizeDiceValue();
    }

    final tentativePos =
        _controller.currentPlayerPosition + _controller.diceValue;
    if (tentativePos > _controller.boardSize) {
      showGameSnackBar(
        context,
        "🚫 Langkah terlalu besar, harus pas di kotak ${_controller.boardSize}!",
        Colors.orange,
      );
      _controller.setDiceRolling(false);
      _switchPlayer();
      return;
    }

    _controller.startTurnWaitingAnswer();
    final correct = await showQuestionDialog(
      context,
      targetPos: tentativePos,
      qna: _controller.questions[tentativePos]!,
    );
    if (!mounted) return;

    _controller.finishTurn();

    if (correct) {
      await _movePlayer(tentativePos);
    } else {
      showGameSnackBar(
        context,
        "❌ Jawaban salah! Tetap di tempat.",
        Colors.redAccent,
      );
      _switchPlayer();
    }
  }

  Future<void> _movePlayer(int newPos) async {
    _controller.setCurrentPlayerPosition(newPos);
    _playerController.forward(from: 0);
    showGameSnackBar(
      context,
      "👍 Pemain ${_controller.currentPlayer} maju ke kotak $newPos",
      Colors.green,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_controller.ladders.containsKey(newPos)) {
      await _handleLadder(newPos);
    } else if (_controller.snakes.containsKey(newPos)) {
      await _handleSnake(newPos);
    }
    if (!mounted) return;

    if (_controller.currentPlayerPosition == _controller.boardSize) {
      if (!_controller.isTwoPlayer) {
        await _controller.saveBestScore(widget.nisn, _controller.throwCount);
        if (!mounted) return;
      }
      await showWinDialog(
        context,
        player: _controller.currentPlayer,
        isTwoPlayer: _controller.isTwoPlayer,
        throwCount: _controller.throwCount,
        bestScore: _controller.bestScore,
      );
      if (!mounted) return;
      _resetGame();
    } else {
      _switchPlayer();
    }
  }

  Future<void> _handleLadder(int pos) async {
    showGameSnackBar(
      context,
      "✨ Wow, dapat tangga! Jawab soal untuk naik.",
      Colors.cyan,
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final canClimb = await showQuestionDialog(
      context,
      targetPos: pos,
      qna: _controller.questions[pos]!,
      isBonus: true,
    );
    if (!mounted) return;

    if (canClimb) {
      final finalPos = _controller.ladders[pos]!;
      _controller.setCurrentPlayerPosition(finalPos);
      _playerController.forward(from: 0);
      showGameSnackBar(
        context,
        "🪜 Berhasil! Naik ke kotak $finalPos!",
        Colors.green,
      );
    } else {
      showGameSnackBar(
        context,
        "😥 Gagal naik tangga, jawaban salah.",
        Colors.orange,
      );
    }
  }

  Future<void> _handleSnake(int pos) async {
    showGameSnackBar(
      context,
      "😱 Awas, ada ular! Jawab soal agar tidak turun.",
      Colors.orangeAccent,
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final canAvoid = await showQuestionDialog(
      context,
      targetPos: pos,
      qna: _controller.questions[pos]!,
      isBonus: true,
    );
    if (!mounted) return;

    if (canAvoid) {
      showGameSnackBar(context, "✅ Fiuhh! Selamat dari ular!", Colors.green);
    } else {
      final finalPos = _controller.snakes[pos]!;
      _controller.setCurrentPlayerPosition(finalPos);
      _playerController.forward(from: 0);
      showGameSnackBar(
        context,
        "🐍 Yah, turun ke kotak $finalPos!",
        Colors.redAccent,
      );
    }
  }

  void _switchPlayer() {
    if (_controller.switchPlayer()) {
      showGameSnackBar(
        context,
        "🔄 Giliran Pemain ${_controller.currentPlayer}",
        Colors.blueGrey,
      );
    }
  }

  void _resetGame() {
    _controller.resetGame();
    showGameSnackBar(context, "🔄 Permainan dimulai ulang!", Colors.blueGrey);
  }

  void _navigateBack() {
    _audioService.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                HomeScreen(userName: widget.userName, nisn: widget.nisn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Ular Tangga Matematika',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Lempar dadu, jawab soal, dan menangkan game!',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _audioService.isMusicPlaying
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _toggleMusic,
                      tooltip:
                          _audioService.isMusicPlaying
                              ? "Matikan Musik"
                              : "Putar Musik",
                    ),
                  ),
                  const SizedBox(height: 8),
                  GameStatusCard(controller: _controller),
                  if (!_controller.isTwoPlayer) ...[
                    const SizedBox(height: 8),
                    GameLeaderboardCard(bestScore: _controller.bestScore),
                  ],
                  const SizedBox(height: 20),
                  GameBoard(
                    controller: _controller,
                    playerAnimation: _playerAnimation,
                  ),
                  const SizedBox(height: 20),
                  GameControls(
                    controller: _controller,
                    diceController: _diceController,
                    diceAnimation: _diceAnimation,
                    onRollDice: _rollDice,
                    onBack: _navigateBack,
                    onReset: _resetGame,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
