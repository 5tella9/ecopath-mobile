import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroLoadingScreen extends StatefulWidget {
  const IntroLoadingScreen({super.key});

  @override
  State<IntroLoadingScreen> createState() => _IntroLoadingScreenState();
}

class _IntroLoadingScreenState extends State<IntroLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const Color kBg = Colors.white;
  static const Color kInk = Color(0xFF00221C);
  static const Color kSoftMint = Color(0xFF6A8F88);

  late final AnimationController _ac;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // same animation style as IntroScreen (without button)
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _titleFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // 3-second intro loading, then go to dashboard (RootShell)
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/root',
        arguments: 0, // first tab
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 180),
              // Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'EcoPath',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.adventPro(
                      color: kInk,
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              FadeTransition(
                opacity: _subtitleFade,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: Text(
                    'Let’s Reduce, Reuse, and Recycle',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.aBeeZee(
                      color: kSoftMint,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Just a spinner (no text)
              const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  valueColor: AlwaysStoppedAnimation<Color>(kInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
