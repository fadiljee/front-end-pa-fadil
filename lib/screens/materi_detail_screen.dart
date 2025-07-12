import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart'; // Pastikan Anda memiliki file ini

class MateriDetailScreen extends StatefulWidget {
  final String title;
  final int materiId;
  final Function(int)? onMateriCompleted;

  const MateriDetailScreen({
    super.key,
    required this.title,
    required this.materiId,
    this.onMateriCompleted,
  });

  @override
  _MateriDetailScreenState createState() => _MateriDetailScreenState();
}

class _MateriDetailScreenState extends State<MateriDetailScreen>
    with TickerProviderStateMixin {
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<String> errorMessage = ValueNotifier('');
  String content = '';
  String? gambarUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // --- Palet Warna ---
  final Color blueButtonColor = const Color(0xFF007BFF);
  final Color primaryTextColor = const Color(0xFF1E293B);
  final Color secondaryTextColor = const Color(0xFF64748B);
  final Color borderColor = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    fetchMateriDetail();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMateriDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    final baseUrl = 'http://127.0.0.1:8000/api/materi/${widget.materiId}';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw 'Sesi kamu habis, coba login ulang ya!';

      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          content = data['konten'] ?? 'Konten tidak tersedia.';
          gambarUrl = data['gambar_url'];
        });
        isLoading.value = false;
        _animationController.forward();
      } else {
        throw 'Gagal memuat materi (Error: ${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value =
          e.toString().contains('Timeout')
              ? 'Koneksi internet lambat, coba lagi nanti.'
              : e.toString();
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, _) {
          return ValueListenableBuilder<String>(
            valueListenable: errorMessage,
            builder: (context, error, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    loading
                        ? _buildLoadingState()
                        : error.isNotEmpty
                        ? _buildErrorState(error)
                        : _buildMainContent(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      key: const ValueKey('loading'),
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(blueButtonColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Menyiapkan materi...',
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      key: const ValueKey('error'),
      color: Colors.white,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 80, color: borderColor),
          const SizedBox(height: 20),
          Text(
            'Oops, Gagal Terhubung!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(color: secondaryTextColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: fetchMateriDetail,
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: primaryTextColor,
            ),
            label: Text('Coba Lagi', style: TextStyle(color: primaryTextColor)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET UTAMA (KONTEN DAN GAMBAR)
  Widget _buildMainContent() {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0, // Memberi ruang untuk gambar
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              stretch: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor.withOpacity(0.7)),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                // MEMANGGIL WIDGET UNTUK MENAMPILKAN GAMBAR
                background: _buildResponsiveImage(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    120,
                  ), // Padding bawah untuk tombol
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          color: secondaryTextColor,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Tombol CTA diposisikan di bawah layar
        Align(alignment: Alignment.bottomCenter, child: _buildCtaButton()),
      ],
    );
  }

  // WIDGET UNTUK MENAMPILKAN GAMBAR
  Widget _buildResponsiveImage() {
    if (gambarUrl == null || gambarUrl!.isEmpty) {
      // Tampilan jika tidak ada gambar
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
        ),
      );
    }
    // Tampilan jika ada gambar
    return Hero(
      tag: 'materi-image-${widget.materiId}',
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(gambarUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET UNTUK TOMBOL "MULAI KUIS"
  Widget _buildCtaButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onMateriCompleted?.call(widget.materiId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(kuisId: widget.materiId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: blueButtonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Mulai Kuis',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
