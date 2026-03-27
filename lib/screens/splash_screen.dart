import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Timers ────────────────────────────────────────────────────────
  Timer? _progressTimer;
  Timer? _countdownTimer;

  // ── State ─────────────────────────────────────────────────────────
  double _progress = 0.0;
  int _countdown = 5;
  bool _isLeaving = false;

  // ── Particle system ───────────────────────────────────────────────
  late List<_Particle> _particles;
  final Random _random = Random();

  // ── Animation controllers ─────────────────────────────────────────
  late AnimationController _logoCtrl;
  late AnimationController _titleCtrl;
  late AnimationController _taglineCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _tagsCtrl;

  // ── Animations ────────────────────────────────────────────────────
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _progressFade;
  late Animation<double> _tagsFade;

  static const _orange = Color(0xFFF97316);
  static const _orangeLight = Color(0xFFFB923C);

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _startStaggeredAnims();
    _startProgressAndCountdown();
  }

  // ── Init ──────────────────────────────────────────────────────────

  void _initParticles() {
    _particles = List.generate(80, (_) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      vx: (_random.nextDouble() - 0.5) * 0.4,
      vy: (_random.nextDouble() - 0.5) * 0.4,
      radius: _random.nextDouble() * 1.4 + 0.4,
      alpha: _random.nextDouble() * 0.45 + 0.1,
    ));
  }

  AnimationController _ctrl(int ms) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: ms),
      );

  Animation<double> _fade(AnimationController c) =>
      Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut));

  Animation<Offset> _slide(AnimationController c) =>
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOutCubic));

  void _initAnimations() {
    _logoCtrl     = _ctrl(700);
    _titleCtrl    = _ctrl(700);
    _taglineCtrl  = _ctrl(700);
    _progressCtrl = _ctrl(700);
    _tagsCtrl     = _ctrl(700);

    _logoFade     = _fade(_logoCtrl);
    _logoSlide    = _slide(_logoCtrl);
    _titleFade    = _fade(_titleCtrl);
    _titleSlide   = _slide(_titleCtrl);
    _taglineFade  = _fade(_taglineCtrl);
    _taglineSlide = _slide(_taglineCtrl);
    _progressFade = _fade(_progressCtrl);
    _tagsFade     = _fade(_tagsCtrl);
  }

  void _startStaggeredAnims() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _titleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _taglineCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _progressCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) _tagsCtrl.forward();
    });
  }

  void _startProgressAndCountdown() {
    const total = Duration(seconds: 5);
    final start = DateTime.now();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) { t.cancel(); return; }
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final p = (elapsed / total.inMilliseconds).clamp(0.0, 1.0);
      setState(() => _progress = p);
      if (p >= 1.0) t.cancel();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });

    Future.delayed(total, () {
      if (mounted && !_isLeaving) _navigateHome();
    });
  }

  // ── Navigation ────────────────────────────────────────────────────

  void _navigateHome() {
    if (_isLeaving) return;
    setState(() => _isLeaving = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  // ── Dispose ───────────────────────────────────────────────────────

  @override
  void dispose() {
    _progressTimer?.cancel();
    _countdownTimer?.cancel();
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _progressCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _navigateHome,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isLeaving ? 0.0 : 1.0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0704), Color(0xFF1A1208), Color(0xFF0A0704)],
            ),
          ),
          child: Stack(
            children: [
              // ── Particles ────────────────────────────────────────
              RepaintBoundary(
                child: CustomPaint(
                  painter: _ParticlePainter(particles: _particles),
                  size: size,
                ),
              ),

              // ── Glow overlay ─────────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.65,
                        colors: [
                          _orange.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────────────
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: _buildLogo(),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Title
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: _buildTitle(size),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineFade,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: _buildTagline(),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Progress bar
                    FadeTransition(
                      opacity: _progressFade,
                      child: _buildProgressBar(),
                    ),

                    const SizedBox(height: 24),

                    // Countdown ring
                    _buildCountdownRing(),

                    const SizedBox(height: 16),

                    // Skip hint
                    Text(
                      'TAP ANYWHERE TO SKIP',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Bottom tags
                    FadeTransition(
                      opacity: _tagsFade,
                      child: _buildBottomTags(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _orange.withOpacity(0.20),
              width: 1.5,
            ),
          ),
        ),
        // Icon box
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_orange, Color(0xFFEA580C)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _orange.withOpacity(0.45),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(Size screenSize) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
          height: 1,
          decoration: TextDecoration.none,
        ),
        children: [
          TextSpan(
            text: 'STARK',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: ' INNOVATION',
            style: TextStyle(color: _orange),
          ),
          TextSpan(
            text: 'Z',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Payment & Project Dashboard',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: Colors.white.withOpacity(0.35),
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          // Track
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              color: Colors.white.withOpacity(0.07),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_orange, _orangeLight],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _orange.withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stepLabel('INIT', 0),
              _stepLabel('SERVICES', 0.33),
              _stepLabel('DATABASE', 0.66),
              _stepLabel('READY', 0.9),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepLabel(String label, double threshold) {
    final active = _progress >= threshold;
    return Text(
      label,
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: active
            ? _orange.withOpacity(0.7)
            : Colors.white.withOpacity(0.18),
      ),
    );
  }

  Widget _buildCountdownRing() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _RingPainter(progress: _progress, color: _orange),
            size: const Size(60, 60),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'SEC',
                style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTags() {
    final tags = [
      'Hardware', 'Software', '3D Design',
      '3D Printing', 'Training', 'Documentation',
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: tags
          .map((t) => Text(
                t.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: Colors.white.withOpacity(0.12),
                ),
              ))
          .toList(),
    );
  }
}

// ── Particle ──────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy, radius, alpha;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.alpha,
  });
}

// ── Particle Painter ──────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter({required this.particles});

  static const _orange = Color(0xFFF97316);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final dotPaint = Paint();
    final linePaint = Paint()..strokeWidth = 0.5;

    for (final p in particles) {
      p.x = (p.x + p.vx / 100) % 1.0;
      p.y = (p.y + p.vy / 100) % 1.0;
      if (p.x < 0) p.x += 1;
      if (p.y < 0) p.y += 1;
    }

    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];
      final x1 = p1.x * size.width;
      final y1 = p1.y * size.height;

      dotPaint.color = Color.fromRGBO(249, 115, 22, p1.alpha);
      canvas.drawCircle(Offset(x1, y1), p1.radius, dotPaint);

      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];
        final x2 = p2.x * size.width;
        final y2 = p2.y * size.height;
        final dx = x2 - x1;
        final dy = y2 - y1;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < 120) {
          final opacity = (1 - dist / 120) * 0.08;
          linePaint.color = Color.fromRGBO(249, 115, 22, opacity);
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── Ring Painter ──────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Track
    paint.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(center, radius, paint);

    // Arc
    if (progress > 0) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}