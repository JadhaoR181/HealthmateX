import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:healthmatex/screens/home_page.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPage({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Scan & Analyze\nHealth Reports",
      description:
          "Upload your lab reports and let AI extract key health parameters instantly with advanced OCR technology",
      icon: Icons.document_scanner_outlined,
      color: Color(0xFF0066FF),
      gradient: [Color(0xFF0066FF), Color(0xFF00B4FF)],
    ),
    OnboardingData(
      title: "Get Instant\nHealth Insights",
      description:
          "Receive personalized health analysis for 15+ common conditions affecting Indians - from diabetes to thyroid",
      icon: Icons.insights_outlined,
      color: Color(0xFF0066FF),
      gradient: [Color(0xFF0066FF), Color(0xFF00B4FF)],
    ),
    OnboardingData(
      title: "Track & Stay\nHealthy",
      description:
          "Monitor your health trends, get wellness tips, and timely reminders for a healthier lifestyle",
      icon: Icons.favorite_outlined,
      color: Color(0xFF0066FF),
      gradient: [Color(0xFF0066FF), Color(0xFF00B4FF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Restart animations on page change
    _fadeController.reset();
    _scaleController.reset();
    _slideController.reset();
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  void _skipToEnd() {
    widget.onFinish();
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      widget.onFinish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _pages[_currentPage].color.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipToEnd,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),

              // Bottom Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildIndicator(index),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Action Button
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor:
                              _pages[_currentPage].color.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPage(OnboardingData data, int index) {
    return FadeTransition(
      opacity: _fadeController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon with Gradient Background
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _scaleController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: data.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withOpacity(0.3),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated Pulse Effect
                  Center(
                    child: AnimatedPulse(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Icon(
                      data.icon,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 60),

          // Title
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOut,
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Colors.grey[900],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // Description
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOut,
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? _pages[_currentPage].color
            : Colors.grey[300],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

// Animated Pulse Widget
class AnimatedPulse extends StatefulWidget {
  final Color color;

  const AnimatedPulse({Key? key, required this.color}) : super(key: key);

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.3),
          child: Opacity(
            opacity: 1.0 - _controller.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
