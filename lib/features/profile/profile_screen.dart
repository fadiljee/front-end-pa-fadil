import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/errors/app_exception.dart';
import '../../core/storage/session_store.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth/name_input_screen.dart';
import '../game/game_loading_screen.dart';
import '../game/game_screen.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String nisn;
  final UserService? userService;
  final AuthService? authService;
  final SessionStore? sessionStore;

  const ProfileScreen({
    super.key,
    required this.nisn,
    this.userService,
    this.authService,
    this.sessionStore,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF0077B6);
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _cardColor = Colors.white;
  static const Color _primaryTextColor = Color(0xFF212529);
  static const Color _secondaryTextColor = Color(0xFF6C757D);
  static const Color _dangerColor = Color(0xFFD90429);

  bool isLoading = true;
  SiswaProfile? _siswa;
  String errorMessage = '';
  final int _selectedIndex = 2;
  int? _totalScore;
  String? _gelar;
  late final UserService _userService;
  late final AuthService _authService;
  late final SessionStore _sessionStore;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _authService = widget.authService ?? AuthService();
    _sessionStore = widget.sessionStore ?? SessionStore();
    _initAnimations();
    _loadAllProfileData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Center(
              child: Text(
                'Konfirmasi Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin keluar dari akun Anda?',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryTextColor, fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                child: const Text(
                  'Batal',
                  style: TextStyle(color: _secondaryTextColor),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dangerColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Keluar'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await _authService.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NameInputScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> _loadAllProfileData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final profile = await _userService.getProfile(defaultNisn: widget.nisn);
      UserStats? stats;
      try {
        stats = await _userService.getStats();
      } catch (_) {
        // Statistik opsional bila profil utama berhasil dimuat
      }

      if (!mounted) return;
      setState(() {
        _siswa = profile;
        _totalScore = stats?.totalSkor;
        _gelar = stats?.gelar;
        isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _siswa = null;
        errorMessage = e.message;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _siswa = null;
        errorMessage = 'Periksa koneksi internet Anda, lalu coba lagi.';
        isLoading = false;
      });
    }
  }

  Future<void> _onItemTapped(int index) async {
    if (index == _selectedIndex) return;
    final userName =
        _siswa?.nama ?? await _sessionStore.getUserName() ?? 'Siswa';
    final nisn = _siswa?.nisn ?? widget.nisn;
    if (!mounted) return;

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GamePage(userName: userName, nisn: nisn),
            ),
          );
        }
      });
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  HomeScreen(userName: userName, nisn: nisn),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isLoading ? _primaryTextColor : Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isLoading ? _primaryTextColor : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isLoading ? _backgroundColor : Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: !isLoading,
      body:
          isLoading
              ? _buildShimmerLoadingState()
              : Stack(
                children: [
                  _buildColorHeader(),
                  SafeArea(
                    child:
                        errorMessage.isNotEmpty
                            ? _buildErrorState(customMessage: errorMessage)
                            : _siswa == null
                            ? _buildErrorState(
                              customMessage: "Data siswa tidak ditemukan.",
                            )
                            : _buildProfileContentFixedHeader(),
                  ),
                ],
              ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  /// Bagian header profil (nama + NISN) yang fixed
  Widget _buildProfileHeaderFixed() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.transparent, // Hapus warna biru, jadi transparan
        // borderRadius tetap bisa dipakai kalau mau lekukan
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 54,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _cardColor,
                backgroundImage:
                    _siswa?.profilePictureUrl != null &&
                            _siswa!.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(_siswa!.profilePictureUrl!)
                        : null,
                child:
                    _siswa?.profilePictureUrl == null ||
                            _siswa!.profilePictureUrl!.isEmpty
                        ? Text(
                          _getInitials(_siswa?.nama ?? "P"),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _siswa?.nama ?? 'Nama Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primaryTextColor, // Ganti warna teks jadi hitam/dark
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'NISN: ${_siswa?.nisn ?? widget.nisn}',
              style: const TextStyle(
                color: Colors.black87, // Ganti warna teks NISN jadi hitam/gelap
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Konten informasi akun dan tombol logout yang bisa di-scroll
  Widget _buildProfileContentFixedHeader() {
    return Column(
      children: [
        _buildProfileHeaderFixed(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  Text(
                    'Informasi Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileDetails(),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: kToolbarHeight + 20),
          const CircleAvatar(radius: 54),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 24,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 40),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 60),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Container(width: 150, height: 20, color: Colors.white),
          const SizedBox(height: 16),
          _buildShimmerInfoCard(),
          _buildShimmerInfoCard(),
          _buildShimmerInfoCard(),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  Widget _buildErrorState({String? customMessage}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: _secondaryTextColor.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? "Gagal memuat data.",
              style: TextStyle(fontSize: 14, color: _secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAllProfileData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    final details = [
      if (_gelar != null && _gelar!.isNotEmpty)
        {
          'icon': Icons.military_tech_outlined,
          'label': 'Gelar Peringkat',
          'value': _gelar!,
        },
      if (_totalScore != null)
        {
          'icon': Icons.star_outline_rounded,
          'label': 'Total Skor',
          'value': _totalScore.toString(),
        },
      if (_siswa?.kelas != null && _siswa!.kelas!.isNotEmpty)
        {
          'icon': Icons.class_outlined,
          'label': 'Kelas',
          'value': _siswa!.kelas!,
        },
      if (_siswa?.sekolah != null && _siswa!.sekolah!.isNotEmpty)
        {
          'icon': Icons.school_outlined,
          'label': 'Sekolah',
          'value': _siswa!.sekolah!,
        },
      if (_siswa?.alamat != null && _siswa!.alamat!.isNotEmpty)
        {
          'icon': Icons.location_on_outlined,
          'label': 'Alamat',
          'value': _siswa!.alamat!,
        },
    ];

    return Column(
      children:
          details.map((detail) {
            return _buildInfoCard(
              detail['icon'] as IconData,
              detail['label'] as String,
              detail['value'] as String,
            );
          }).toList(),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      shadowColor: _primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _primaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Keluar dari Akun'),
        onPressed: _logout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: _dangerColor,
          backgroundColor: _dangerColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.sports_esports_rounded, "Game", 0),
          _buildNavItem(Icons.home_filled, "Home", 1),
          _buildNavItem(Icons.person, "Profil", 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryColor : _secondaryTextColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? _primaryColor : _secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] +
            (parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : ''))
        .toUpperCase();
  }
}
