import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'dart:ui';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true); // Repeats animation back and forth

    // Color Animation (Gradient Effect)
    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
            weight: 1.0,
            tween: ColorTween(begin: Colors.red, end: Colors.orange)),
        TweenSequenceItem(
            weight: 1.0,
            tween: ColorTween(begin: Colors.blue, end: Colors.white)),
        TweenSequenceItem(
            weight: 1.0,
            tween: ColorTween(begin: Colors.black, end: Colors.white)),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/bg/background_dashboard.jpg',
            fit: BoxFit.cover,
          ),

          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Animated Welcome Text
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Text(
                  'Welcome to Rent And Employee Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _colorAnimation.value, // Animated color
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: _colorAnimation.value!.withValues(alpha: 0.8),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassButton(
                  label: 'Login',
                  onPressed: () => Navigator.pushNamed(context, loginRoute),
                ),
                const SizedBox(height: 20),
                _buildGlassButton(
                  label: 'Sign Up',
                  onPressed: () => Navigator.pushNamed(context, signUpRoute),
                ),
                const SizedBox(height: 20),
                _buildGlassButton(
                  label: 'Forgot Password',
                  onPressed: () =>
                      Navigator.pushNamed(context, forgotPasswordRoute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Glassmorphism Button
  Widget _buildGlassButton(
      {required String label, required VoidCallback onPressed}) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white..withValues(alpha: 0.4)),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
