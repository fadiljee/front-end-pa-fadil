import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NameInputScreen extends StatefulWidget {
  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late AnimationController _loadingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });

    // Focus listener
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    // Auto hide error after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
        });
      }
    });
  }

  void _login() async {
    String nisn = _controller.text.trim();
    if (nisn.isEmpty) {
      _showError('NISN tidak boleh kosong');
      return;
    }

    if (nisn.length < 10) {
      _showError('NISN harus minimal 10 digit');
      return;
    }

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _loadingController.repeat();

    try {
      final response = await http.post(
        Uri.parse('http://114.125.252.103:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nisn': nisn}),
      );

      _loadingController.stop();
      _loadingController.reset();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        String nama = data['data_siswa']['nama'];
        String nisnResp = data['data_siswa']['nisn'].toString();

        await _saveToken(token);

        // Success feedback
        HapticFeedback.mediumImpact();

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    HomeScreen(userName: nama, nisn: nisnResp, token: token),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        String message = data['message'] ?? 'Login gagal';
        _showError(message);
      }
    } catch (e) {
      _loadingController.stop();
      _loadingController.reset();

      setState(() {
        _isLoading = false;
      });

      _showError('Koneksi bermasalah. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 40),

                        // Main Card
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            double shake = _shakeAnimation.value;
                            return Transform.translate(
                              offset: Offset(
                                shake * 10 * (0.5 - (shake * 0.5)).sign,
                                0,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.9),
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Icon
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF667eea),
                                            Color(0xFF764ba2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.school_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),

                                    SizedBox(height: 24),

                                    // Title
                                    Text(
                                      'Verifikasi Identitas',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D3748),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    SizedBox(height: 8),

                                    // Subtitle
                                    Text(
                                      'Masukkan NISN untuk melanjutkan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF718096),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    SizedBox(height: 32),

                                    // Input Field
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                _focusNode.hasFocus
                                                    ? Color(
                                                      0xFF667eea,
                                                    ).withOpacity(0.2)
                                                    : Colors.grey.withOpacity(
                                                      0.1,
                                                    ),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _controller,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2D3748),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'NISN',
                                          hintText: 'Masukkan 10 digit NISN',
                                          counterText: '',
                                          prefixIcon: Container(
                                            margin: EdgeInsets.all(12),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(
                                                    0xFF667eea,
                                                  ).withOpacity(0.8),
                                                  Color(
                                                    0xFF764ba2,
                                                  ).withOpacity(0.8),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.badge_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 20,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFF667eea),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red[400]!,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.red[400]!,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                          labelStyle: GoogleFonts.poppins(
                                            color:
                                                _focusNode.hasFocus
                                                    ? Color(0xFF667eea)
                                                    : Color(0xFF718096),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Color(0xFFA0AEC0),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Error Message
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      height: _hasError ? 40 : 0,
                                      child:
                                          _hasError
                                              ? Container(
                                                margin: EdgeInsets.only(
                                                  top: 12,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.red[200]!,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .error_outline_rounded,
                                                      color: Colors.red[600],
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _errorMessage,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .red[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              : SizedBox(),
                                    ),

                                    SizedBox(height: 32),

                                    // Submit Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                        onTap: _isLoading ? null : _login,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 200),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors:
                                                  _isLoading
                                                      ? [
                                                        Colors.grey[400]!,
                                                        Colors.grey[500]!,
                                                      ]
                                                      : [
                                                        Color(0xFF667eea),
                                                        Color(0xFF764ba2),
                                                      ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    _isLoading
                                                        ? Colors.grey
                                                            .withOpacity(0.3)
                                                        : Color(
                                                          0xFF667eea,
                                                        ).withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child:
                                              _isLoading
                                                  ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Memverifikasi...',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ],
                                                  )
                                                  : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Verifikasi',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 32),

                        // Help Text
                        Text(
                          'Kesulitan mengingat NISN?\nHubungi admin sekolah',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
