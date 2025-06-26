import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'name_input_screen.dart'; // Pastikan file ini ada

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _pulseController;
  late final AnimationController _floatingController;

  // --- Animations ---
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);

    _slideController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _floatingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _floatingAnimation = Tween<double>(begin: -10, end: 10)
        .animate(CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _slideController.forward());
    _pulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }
  
  // --- UI Builder Methods ---

  /// Membangun elemen lingkaran yang mengambang di latar belakang
  List<Widget> _buildFloatingCircles(Size size) {
    return List.generate(
      6,
      (index) => AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            top: 100 + (index * 120) + _floatingAnimation.value,
            left: (index % 2 == 0) ? -50 : size.width - 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // === PERUBAHAN DI SINI: Logo gambar diganti dengan Ikon ===
  // ==========================================================
  /// Membangun avatar dengan animasi denyut
  Widget _buildPulsingAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              // Nested CircleAvatar dengan backgroundImage dihilangkan,
              // dan diganti dengan Icon langsung.
              child: Icon(
                Icons.waving_hand_rounded, // Ikon lambaian tangan
                size: 80,
                color: Color(0xFF764ba2), // Warna ikon disesuaikan dengan tema
              ),
            ),
          ),
        );
      },
    );
  }
  // ==========================================================
  // === AKHIR DARI PERUBAHAN ===
  // ==========================================================

  /// Membangun blok teks selamat datang
  Widget _buildWelcomeText() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white70],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'SELAMAT DATANG!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mari mulai perjalanan yang menakjubkan',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Membangun tombol "Mulai Sekarang" yang modern
  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => NameInputScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mulai Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            ..._buildFloatingCircles(size),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPulsingAvatar(),
                          const SizedBox(height: 60),
                          _buildWelcomeText(),
                          const SizedBox(height: 80),
                          _buildStartButton(context),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(index == 0 ? 0.8 : 0.3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}