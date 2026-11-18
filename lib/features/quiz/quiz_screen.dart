import 'package:flutter/material.dart';
import '../../core/errors/app_exception.dart';
import '../../services/kuis_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int kuisId;
  final KuisService? kuisService;

  const QuizScreen({super.key, required this.kuisId, this.kuisService});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  String selectedAnswer = '';
  List<Map<String, dynamic>> hasilKuisData = [];

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    fetchQuizData();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  KuisService get _kuisService => widget.kuisService ?? KuisService();

  Future<void> fetchQuizData() async {
    try {
      final loaded = await _kuisService.getKuis(widget.kuisId);
      if (!mounted) return;
      setState(() {
        questions = loaded;
        isLoading = false;
      });
      _slideController.forward();
      _fadeController.forward();
      _updateProgress();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat kuis.';
        isLoading = false;
      });
    }
  }

  void _updateProgress() {
    if (questions.isEmpty) return;
    final progress = (currentQuestionIndex + 1) / questions.length;
    _progressController.animateTo(progress);
  }

  Future<Map<String, dynamic>?> kirimHasilKuis(
    int kuisId,
    String jawabanUser,
  ) async {
    try {
      return await _kuisService.submitJawaban(
        kuisId: kuisId,
        jawabanUser: jawabanUser,
      );
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return null;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengirim jawaban, coba lagi.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return null;
    }
  }

  Future<UnlockMateriResult?> unlockNextMateri(int materiId) async {
    try {
      return await _kuisService.unlockNextMateri(materiId);
    } catch (_) {
      return null;
    }
  }

  void nextQuestion() async {
    if (selectedAnswer.isEmpty) return;

    final soal = questions[currentQuestionIndex];
    final jawabanMap = {
      'jawaban_a': 'a',
      'jawaban_b': 'b',
      'jawaban_c': 'c',
      'jawaban_d': 'd',
    };
    final jawabanUser = (jawabanMap[selectedAnswer] ?? '').toLowerCase();

    final submitResp = await kirimHasilKuis(soal['id'], jawabanUser);
    if (submitResp == null) {
      // Tetap di soal saat ini agar pengguna dapat mengulang pengiriman secara idempoten (FE-26).
      return;
    }

    // Mendukung fase 1 (jawaban_benar dari soal) maupun fase 2 (benar/skor/pembahasan dari server).
    final bool benar =
        submitResp.containsKey('benar')
            ? submitResp['benar'] == true
            : soal['jawaban_benar'] == jawabanUser;
    final int skor =
        submitResp.containsKey('skor')
            ? (submitResp['skor'] as int? ?? 0)
            : (benar ? (soal['nilai'] as int? ?? 10) : 0);
    final String pembahasan =
        submitResp['pembahasan']?.toString() ??
        soal['pembahasan']?.toString() ??
        '';

    hasilKuisData.add({
      'pertanyaan': soal['pertanyaan'],
      'jawaban_benar': soal['jawaban_benar'] ?? '-',
      'jawaban_user': jawabanUser,
      'benar': benar,
      'skor': skor,
      'pembahasan': pembahasan,
      'materi_id': soal['materi_id'],
    });

    if (currentQuestionIndex < questions.length - 1) {
      await _slideController.reverse();
      if (!mounted) return;
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = '';
      });
      _updateProgress();
      await _slideController.forward();
    } else {
      // Selalu panggil POST /unlock-next-materi dan percayai hasil server (FE-23).
      UnlockMateriResult? unlockResult;
      if (hasilKuisData.isNotEmpty && hasilKuisData[0]['materi_id'] is int) {
        final materiId = hasilKuisData[0]['materi_id'] as int;
        unlockResult = await unlockNextMateri(materiId);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => QuizResultScreen(
                kuisData: hasilKuisData,
                unlockResult: unlockResult,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child:
            isLoading
                ? _buildLoadingState()
                : errorMessage.isNotEmpty
                ? _buildErrorState()
                : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildQuizContent(),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Memuat kuis...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Quiz Challenge',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${currentQuestionIndex + 1} dari ${questions.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((currentQuestionIndex + 1) / questions.length * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 32),
          _buildAnswerChoices(),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PERTANYAAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            questions[currentQuestionIndex]['pertanyaan'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerChoices() {
    final options = ['jawaban_a', 'jawaban_b', 'jawaban_c', 'jawaban_d'];
    final labels = ['A', 'B', 'C', 'D'];

    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final label = labels[index];
        final isSelected = selectedAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFE2E8F0),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 15 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    selectedAnswer = option;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          questions[currentQuestionIndex][option],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = selectedAnswer.isNotEmpty;
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 8 : 0,
          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
        ),
        onPressed: isEnabled ? nextQuestion : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastQuestion ? 'Selesai' : 'Lanjutkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastQuestion ? Icons.check : Icons.arrow_forward,
              color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
