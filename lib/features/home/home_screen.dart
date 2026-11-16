import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/storage/session_store.dart';
import '../../services/materi_service.dart';
import '../../services/user_service.dart';
import '../game/game_loading_screen.dart';
import '../game/game_screen.dart';
import '../materi/materi_detail_screen.dart';
import '../profile/profile_screen.dart';

// Warna utama
const Color _primaryColor = Color(0xFF6B73FF);
const Color _textColorSecondary = Color(0xFF718096);
const Color _lockedColor = Color(0xFFCBD5E0);

class HomeScreen extends StatefulWidget {
  final String userName;
  final String nisn;
  final String? token;
  final MateriService? materiService;
  final UserService? userService;
  final SessionStore? sessionStore;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.nisn,
    this.token,
    this.materiService,
    this.userService,
    this.sessionStore,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  Future<List<Map<String, dynamic>>>? _futureMateri;

  Set<int> _completedMateriIds = {};
  Set<int> _unlockedMateriIds = {};
  int _totalMateriCount = 0;
  UserStats? _userStats;
  bool _isStatsLoading = true;
  bool _hasStatsError = false;

  late final MateriService _materiService;
  late final UserService _userService;
  late final SessionStore _sessionStore;

  late AnimationController _pageLoadController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsCardsAnimation;
  late Animation<double> _materiListAnimation;

  @override
  void initState() {
    super.initState();
    _materiService = widget.materiService ?? MateriService();
    _userService = widget.userService ?? UserService();
    _sessionStore = widget.sessionStore ?? SessionStore();
    _initializeAnimations();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() {
        _isStatsLoading = true;
        _hasStatsError = false;
      });
    }
    await _loadLocalProgress();
    await _refreshFromServer();
  }

  Future<void> _loadLocalProgress() async {
    final completedIds = await _sessionStore.getCompletedMateriIds(widget.nisn);
    final unlockedIds = await _sessionStore.getUnlockedMateriIds(widget.nisn);
    if (mounted) {
      setState(() {
        _completedMateriIds = completedIds;
        _unlockedMateriIds = unlockedIds.toSet();
      });
    }
  }

  Future<void> _refreshFromServer() async {
    try {
      final unlockedIds = await _materiService.getUnlockedMateriIds();
      await _sessionStore.saveUnlockedMateriIds(widget.nisn, unlockedIds);
      if (mounted) {
        setState(() {
          _unlockedMateriIds = unlockedIds.toSet();
        });
      }
    } catch (_) {
      // Gunakan cache lokal untuk mode luring singkat (FE-15).
    }

    final materiFuture = fetchMateri();
    if (mounted) {
      setState(() {
        _futureMateri = materiFuture;
      });
    }

    try {
      final stats = await _userService.getStats();
      if (mounted) {
        setState(() {
          _userStats = stats;
          _isStatsLoading = false;
          _hasStatsError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isStatsLoading = false;
          _hasStatsError = true;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchMateri() async {
    final list = await _materiService.getMateriList();
    if (mounted) {
      setState(() {
        _totalMateriCount = list.length;
      });
    }
    return list;
  }

  Future<void> _markMateriAsCompleted(int materiId) async {
    await _sessionStore.markMateriCompleted(widget.nisn, materiId);
    if (mounted) {
      setState(() {
        _completedMateriIds.add(materiId);
      });
    }
  }

  void _initializeAnimations() {
    _pageLoadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimation = CurvedAnimation(
      parent: _pageLoadController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageLoadController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _statsCardsAnimation = CurvedAnimation(
      parent: _pageLoadController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    );
    _materiListAnimation = CurvedAnimation(
      parent: _pageLoadController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _pageLoadController.forward();
  }

  @override
  void dispose() {
    _pageLoadController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(context, _createRoute(LoadingScreen()));
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            _createRoute(
              GamePage(userName: widget.userName, nisn: widget.nisn),
            ),
          );
        }
      });
    } else if (index == 2) {
      Navigator.push(context, _createRoute(ProfileScreen(nisn: widget.nisn)));
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi! 🌅';
    if (hour < 15) return 'Selamat Siang! ☀️';
    if (hour < 18) return 'Selamat Sore! 🌇';
    return 'Selamat Malam! 🌙';
  }

  String _getMotivationalText() {
    final messages = [
      'Ayo semangat belajar hari ini! 💪',
      'Kamu pasti bisa! Terus berusaha! 🌟',
      'Belajar itu seru, lho! 📚✨',
      'Setiap langkah kecil adalah kemajuan! 🚀',
    ];
    return messages[DateTime.now().day % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B73FF), Color(0xFF9D50BB), Color(0xFFFF6B9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              FadeTransition(opacity: _headerAnimation, child: _buildHeader()),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildMateriList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Text('📚', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.userName,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Hero(
                  tag: 'profile_avatar',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.nunito(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                _getMotivationalText(),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(scale: _statsCardsAnimation, child: _buildStatsRow()),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    if (_isStatsLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.6),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 86,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_hasStatsError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Statistik gagal dimuat',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadInitialData,
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final unlockedText =
        _totalMateriCount > 0
            ? '${_unlockedMateriIds.length}/$_totalMateriCount'
            : '${_unlockedMateriIds.length}';
    final progressPct = (_userStats?.totalSkor ?? 0).clamp(0, 100);
    final gelarText = _userStats?.gelar ?? '-';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Materi',
            unlockedText,
            Icons.book_rounded,
            const Color(0xFFFFB74D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Progress',
            '$progressPct%',
            Icons.trending_up_rounded,
            const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Gelar',
            gelarText,
            Icons.military_tech_rounded,
            const Color(0xFFEF5350),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Text(
                '📚 Materi Belajar',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Semua',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureMateri,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(color: _textColorSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadInitialData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada materi tersedia.',
                    style: GoogleFonts.nunito(color: _textColorSecondary),
                  ),
                );
              }

              final materiList = snapshot.data!;

              return FadeTransition(
                opacity: _materiListAnimation,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: materiList.length,
                  itemBuilder: (context, index) {
                    final materi = materiList[index];
                    final bool isLocked =
                        !_unlockedMateriIds.contains(materi['id'] as int);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _pageLoadController,
                          curve: Interval(
                            0.6 + (index * 0.05).clamp(0.0, 0.4),
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildMateriCard(materi, index, isLocked),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMateriCard(
    Map<String, dynamic> materi,
    int index,
    bool isLocked,
  ) {
    final colors = [
      const Color(0xFF6A5AE0),
      const Color(0xFF48BB78),
      const Color(0xFFF59E0B),
      const Color(0xFFE53935),
    ];
    final accentColor = colors[index % colors.length];

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: InkWell(
        onTap:
            isLocked
                ? null
                : () async {
                  HapticFeedback.lightImpact();
                  await Navigator.push(
                    context,
                    _createRoute(
                      MateriDetailScreen(
                        title: materi['judul'] ?? 'Materi',
                        materiId: materi['id'] ?? 0,
                        onMateriCompleted: (id) => _markMateriAsCompleted(id),
                      ),
                    ),
                  );
                  if (mounted) {
                    _loadInitialData();
                  }
                },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      isLocked
                          ? _lockedColor
                          : accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : Icons.menu_book_rounded,
                  color: isLocked ? Colors.grey.shade700 : accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi['judul'] ?? 'Judul Kosong',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isLocked
                                ? Colors.grey.shade700
                                : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLocked
                          ? 'Selesaikan materi sebelumnya'
                          : 'Tap untuk mulai belajar',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color:
                            isLocked
                                ? Colors.grey.shade600
                                : const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A5B6B8B),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.sports_esports_rounded, 0, 'Game'),
          _buildNavItem(Icons.home_filled, 1, 'Home'),
          _buildNavItem(Icons.person_rounded, 2, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryColor : _textColorSecondary,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
