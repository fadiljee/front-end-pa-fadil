import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart';

class MateriDetailScreen extends StatefulWidget {
  final String title;
  final int materiId;
  // PENAMBAHAN: Terima fungsi callback opsional dari HomeScreen
  final Function(int)? onMateriCompleted;

  const MateriDetailScreen({
    super.key,
    required this.title,
    required this.materiId,
    this.onMateriCompleted, // PENAMBAHAN: Tambahkan ke constructor
  });

  @override
  _MateriDetailScreenState createState() => _MateriDetailScreenState();
}

class _MateriDetailScreenState extends State<MateriDetailScreen>
    with TickerProviderStateMixin {
  bool isLoading = true;
  String content = '';
  String? gambarUrl;
  String errorMessage = '';

  late AnimationController _contentAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    fetchMateriDetail();
  }

  void _initAnimations() {
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _buttonScaleAnimation = CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchMateriDetail() async {
    final baseUrl = 'http://114.125.252.103:8000/api/materi/${widget.materiId}';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Sesi Anda telah berakhir. Silakan login ulang.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          content = data['konten'] ?? 'Konten tidak tersedia.';
          gambarUrl = data['gambar_url'];
          isLoading = false;
        });
        _contentAnimationController.forward();
        _buttonAnimationController.forward();
      } else {
        setState(() {
          errorMessage = 'Gagal memuat materi (Kode: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan jaringan. Periksa koneksi Anda.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF4F6F8).withOpacity(0.5),
              const Color(0xFFF4F6F8),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? _buildLoadingState()
                  : errorMessage.isNotEmpty
                  ? _buildErrorState()
                  : _buildMainContent(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          isLoading || errorMessage.isNotEmpty ? null : _buildQuizButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4A5568),
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        widget.title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3748),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
          const SizedBox(height: 20),
          Text(
            'Sedang memuat materi...',
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Memuat Data',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchMateriDetail,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          physics: const BouncingScrollPhysics(),
          children: [
            if (gambarUrl != null && gambarUrl!.isNotEmpty) ...[
              _buildImageCard(),
              const SizedBox(height: 24),
            ],
            _buildContentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Hero(
      tag: 'materi-image-${widget.materiId}',
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            gambarUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Materi Pembelajaran',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const Divider(height: 32),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: GoogleFonts.lato(
              fontSize: 16.5,
              color: const Color(0xFF4A5568),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizButton() {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton.icon(
          // MODIFIKASI: Panggil callback di sini
          onPressed: () {
            HapticFeedback.lightImpact();

            // Panggil callback untuk menandai materi ini selesai.
            // Tanda `?.` memastikan kode tidak error jika callback tidak diberikan.
            widget.onMateriCompleted?.call(widget.materiId);

            // Lanjutkan navigasi ke QuizScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(kuisId: widget.materiId),
              ),
            );
          },
          icon: const Icon(Icons.quiz_rounded, size: 22),
          label: const Text('Mulai Kuis'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF48BB78),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            elevation: 5,
            shadowColor: const Color(0xFF48BB78).withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
