import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/admin/ui/views/admin_view.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/ui/views/login_view.dart';
import 'package:gym_app/features/coach/home/ui/views/coach_bottom_nav_bar_view.dart';
import 'package:gym_app/features/coach/setup/coach_setup_screen.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _shimmerOpacity;
  late final Animation<double> _shimmerPos;
  late final Animation<double> _pulse;

  String? _token;
  String? _role;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAuthAndNavigate();
  }

  void _setupAnimations() {
    // Logo: scale + fade in
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // App name: slide up + fade
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    // Tagline: fade in
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn));

    // Shimmer progress bar
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shimmerOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeIn));
    _shimmerPos = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    // Glow pulse behind logo
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Sequence the animations
    _logoCtrl.forward().then((_) {
      _textCtrl.forward().then((_) {
        _taglineCtrl.forward().then((_) {
          _shimmerCtrl.forward();
          // Start shimmer loop
          _runShimmer();
        });
      });
    });
  }

  void _runShimmer() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) break;
      _shimmerCtrl.forward(from: 0);
    }
  }

  Future<void> _loadAuthAndNavigate() async {
    final [token, role] = await Future.wait([
      ApiClient.getToken(),
      ApiClient.getRole(),
    ]);
    _token = token;
    _role = role;

    // Minimum splash display: 2.6 s
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final dest = await _resolveRoute(_token, _role);
    if (!mounted) return;
    context.go(dest);
  }

  Future<String> _resolveRoute(String? token, String? role) async {
    if (token == null || token.isEmpty) return LoginView.routeName;
    switch (role) {
      case 'admin':
        return AdminView.routeName;
      case 'coach':
        try {
          final data  = await AuthRepository.getCoachGymRequest();
          final req   = data['gym_request'] as Map<String, dynamic>?;
          if (req != null && req['status'] == 'pending') {
            return CoachGymPendingScreen.routeName;
          }
        } catch (_) {}
        return CoachBottomNavBarView.routeName;
      default:
        return BottomNavBarView.routeName;
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _taglineCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background geometric decoration
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.35,
            child: _GlowCircle(size: size.width * 0.9, color: AppColors.purple),
          ),
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.4,
            child: _GlowCircle(size: size.width * 0.85, color: AppColors.purple),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing glow + logo
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(
                              alpha: 0.35 * _pulse.value,
                            ),
                            blurRadius: 60 * _pulse.value,
                            spreadRadius: 20 * _pulse.value,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E0A35), Color(0xFF0F172A)],
                          ),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: SvgPicture.asset(
                            'assets/images/dumbbell.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFD0AAFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'FitQuad',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'Train Smart. Live Strong.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom shimmer bar
          Positioned(
            bottom: 60,
            left: size.width * 0.25,
            right: size.width * 0.25,
            child: FadeTransition(
              opacity: _shimmerOpacity,
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, __) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 3,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 1.0,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                final pos = _shimmerPos.value;
                                return LinearGradient(
                                  begin: Alignment(pos - 0.5, 0),
                                  end: Alignment(pos + 0.5, 0),
                                  colors: [
                                    Colors.transparent,
                                    AppColors.purple.withValues(alpha: 0.9),
                                    Colors.transparent,
                                  ],
                                ).createShader(rect);
                              },
                              child: Container(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Powered by text
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: const Text(
                'Powered by FitQuad™',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
