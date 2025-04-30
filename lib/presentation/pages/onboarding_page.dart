import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'tasks_page.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Organic Mind',
      'description':
          'Your personal task manager designed to keep you focused and organized.',
      'image': 'assets/images/onboarding1.png',
      'color': const Color(0xFF1E293B),
    },
    {
      'title': 'Create and Organize',
      'description':
          'Create tasks, add details, set due dates, and organize them in custom lists.',
      'image': 'assets/images/onboarding2.png',
      'color': const Color(0xFF0EA5E9),
    },
    {
      'title': 'Stay Productive',
      'description':
          'With only the features you need, Organic Mind is customized for a stress-free productivity experience.',
      'image': 'assets/images/onboarding3.png',
      'color': AppTheme.primaryDarkColor,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _navigateToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TasksPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _pages.length - 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Skip',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMediumColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // Main content - PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(index);
                },
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Navigation button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToNextPage,
                  style: AppTheme.primaryButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Continue'
                          : 'Get Started',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
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

  Widget _buildOnboardingPage(int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _pages[index]['color'],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [AppTheme.smallShadow],
                ),
                child: Stack(
                  children: [
                    // Logo or brand name
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Text(
                        'Organic\nMind',
                        style: AppTheme.headingMedium.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                    ),

                    // Animated shapes
                    Positioned.fill(
                      child: AnimatedShapes(colorIndex: index),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                _pages[index]['title'],
                style: AppTheme.headingLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                _pages[index]['description'],
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textMediumColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class AnimatedShapes extends StatefulWidget {
  final int colorIndex;

  const AnimatedShapes({Key? key, required this.colorIndex}) : super(key: key);

  @override
  State<AnimatedShapes> createState() => _AnimatedShapesState();
}

class _AnimatedShapesState extends State<AnimatedShapes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Generate a color based on the page index
  Color getShapeColor(int baseValue) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.infoColor,
      AppTheme.warningColor,
      AppTheme.accentColor,
    ];

    return colors[(widget.colorIndex + baseValue) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating shape 1
            Positioned(
              top: 50 + 10 * math.sin(_controller.value * 2 * math.pi),
              right: 50 + 15 * math.cos(_controller.value * 2 * math.pi),
              child: Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    color: getShapeColor(0),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),

            // Floating shape 2
            Positioned(
              top: 120 + 20 * math.cos(_controller.value * 2 * math.pi + 1),
              left: 40 + 10 * math.sin(_controller.value * 2 * math.pi + 2),
              child: Transform.rotate(
                angle: -_controller.value * 2 * math.pi,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: getShapeColor(1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            // Floating shape 3
            Positioned(
              bottom: 40 + 15 * math.sin(_controller.value * 2 * math.pi + 3),
              right: 60 + 20 * math.cos(_controller.value * 2 * math.pi + 1.5),
              child: Transform.rotate(
                angle: _controller.value * 2 * math.pi * 0.7,
                child: Container(
                  width: 50,
                  height: 80,
                  decoration: BoxDecoration(
                    color: getShapeColor(2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),

            // White dot
            Positioned(
              top: 70 + 30 * math.cos(_controller.value * 2 * math.pi),
              left: 100 + 20 * math.sin(_controller.value * 2 * math.pi),
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // White dot 2
            Positioned(
              bottom: 80 + 20 * math.sin(_controller.value * 2 * math.pi + 2),
              right: 30 + 10 * math.cos(_controller.value * 2 * math.pi + 1),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Curved lines
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: AnimatedCurvedLinePainter(
                animationValue: _controller.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class AnimatedCurvedLinePainter extends CustomPainter {
  final double animationValue;

  AnimatedCurvedLinePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // First curve
    final path1 = Path();
    final startX1 = size.width * 0.2;
    final startY1 =
        size.height * (0.3 + 0.05 * math.sin(animationValue * 2 * math.pi));

    path1.moveTo(startX1, startY1);
    path1.quadraticBezierTo(
      size.width * (0.5 + 0.1 * math.cos(animationValue * 2 * math.pi)),
      size.height * (0.2 + 0.1 * math.sin(animationValue * 2 * math.pi)),
      size.width * (0.8 - 0.05 * math.cos(animationValue * 2 * math.pi)),
      size.height * (0.4 + 0.05 * math.sin(animationValue * 2 * math.pi)),
    );

    // Second curve
    final path2 = Path();
    final startX2 = size.width * 0.15;
    final startY2 =
        size.height * (0.6 + 0.05 * math.cos(animationValue * 2 * math.pi + 1));

    path2.moveTo(startX2, startY2);
    path2.quadraticBezierTo(
      size.width * (0.3 - 0.1 * math.sin(animationValue * 2 * math.pi)),
      size.height * (0.7 - 0.05 * math.cos(animationValue * 2 * math.pi)),
      size.width * (0.6 + 0.1 * math.sin(animationValue * 2 * math.pi + 2)),
      size.height * (0.75 + 0.05 * math.cos(animationValue * 2 * math.pi + 1)),
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // Add small animated dots
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dot positions along the paths
    final dot1Pos =
        _getPositionAlongPath(path1, (animationValue * 2) % 1.0, size);
    final dot2Pos =
        _getPositionAlongPath(path2, (animationValue * 1.5 + 0.5) % 1.0, size);

    canvas.drawCircle(dot1Pos, 3, dotPaint);
    canvas.drawCircle(dot2Pos, 2, dotPaint);
  }

  Offset _getPositionAlongPath(Path path, double percent, Size size) {
    final pathMetrics = path.computeMetrics().first;
    final length = pathMetrics.length;
    final pos = pathMetrics.getTangentForOffset(length * percent)?.position ??
        Offset.zero;
    return pos;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
