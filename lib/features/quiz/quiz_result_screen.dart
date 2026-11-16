import 'package:flutter/material.dart';
import '../../core/storage/session_store.dart';
import '../../models/materi.dart';
import '../home/home_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final List<dynamic> kuisData;
  final UnlockMateriResult? unlockResult;
  final SessionStore? sessionStore;

  const QuizResultScreen({
    super.key,
    required this.kuisData,
    this.unlockResult,
    this.sessionStore,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutBack),
    );

    _confettiController.forward();
    _scoreController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  int get totalScore {
    return widget.kuisData.fold<int>(
      0,
      (sum, item) => sum + ((item['skor'] ?? 0) as int),
    );
  }

  int get correctAnswers {
    return widget.kuisData.where((item) => item['skor'] > 0).length;
  }

  double get percentage {
    if (widget.kuisData.isEmpty) return 0;
    return (correctAnswers / widget.kuisData.length) * 100;
  }

  Color get scoreColor {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get performanceText {
    if (percentage >= 80) return 'Luar Biasa!';
    if (percentage >= 60) return 'Bagus!';
    return 'Tetap Semangat!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              if (widget.unlockResult != null &&
                  widget.unlockResult!.message.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildUnlockBanner(widget.unlockResult!),
              ],
              const SizedBox(height: 32),
              _buildScoreCard(),
              const SizedBox(height: 32),
              _buildDetailedResults(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_confettiController.value * 0.1),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  percentage >= 80
                      ? Icons.emoji_events
                      : percentage >= 60
                      ? Icons.thumb_up
                      : Icons.psychology,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          performanceText,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kuis Telah Selesai',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor, scoreColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: scoreColor.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$correctAnswers dari ${widget.kuisData.length} Benar',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total Skor: $totalScore',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailedResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Detail Jawaban',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          ...List.generate(widget.kuisData.length, (index) {
            final soal = widget.kuisData[index];
            final isCorrect = soal['skor'] > 0;

            return Container(
              margin: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: index == widget.kuisData.length - 1 ? 24 : 16,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isCorrect
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pertanyaan ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isCorrect
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${soal['skor']} poin',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    soal['pertanyaan'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Jawaban benar: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        soal['jawaban_benar'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Jawaban Anda: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        (soal['jawaban_user'] ?? '-').toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pembahasan:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    soal['pembahasan'] ?? 'Tidak ada pembahasan tersedia.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUnlockBanner(UnlockMateriResult result) {
    final bgColor =
        result.unlocked
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : const Color(0xFFF59E0B).withValues(alpha: 0.12);
    final fgColor =
        result.unlocked ? const Color(0xFF047857) : const Color(0xFFB45309);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            result.unlocked ? Icons.lock_open_rounded : Icons.lock_outline,
            color: fgColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.message,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
            ),
            onPressed: () async {
              final store = widget.sessionStore ?? SessionStore();
              final userName = await store.getUserName() ?? 'Siswa';
              final nisn = await store.getNisn() ?? '';
              final token = await store.getToken();

              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => HomeScreen(
                        key: UniqueKey(),
                        userName: userName,
                        nisn: nisn,
                        token: token,
                      ),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home),
                SizedBox(width: 8),
                Text(
                  'Kembali ke Beranda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
