import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const Color deepGreen = Color(0xFF00221C);
  static const Color fbBlue = Color(0xFF2F6BFF);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;

    return Scaffold(
      backgroundColor: deepGreen,
      body: Stack(
        children: [
          // main white curved sheet
          Positioned.fill(
            top: media.padding.top + 170,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Sign Up Here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create an account & be with EcoPath!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal.shade700.withOpacity(.75),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Facebook button (filled blue)
                    _SolidSocialButton(
                      label: 'Continue with Facebook',
                      bg: fbBlue,
                      fg: Colors.white,
                      iconPath: 'assets/icons/fb.svg',
                      onTap: () {
                        // TODO: Facebook signup
                      },
                    ),
                    const SizedBox(height: 18),

                    // Instagram button (gradient outline)
                    _GradientOutlineButton(
                      label: 'Continue with Instagram',
                      iconPath: 'assets/icons/insta.svg',
                      onTap: () {
                        // TODO: Instagram signup
                      },
                    ),
                    const SizedBox(height: 18),

                    // Google button (black outline)
                    _OutlineButton(
                      label: 'Continue with Google',
                      iconPath: 'assets/icons/google.svg',
                      onTap: () {
                        // TODO: Google signup
                      },
                    ),
                    const SizedBox(height: 18),

                    // Email button (filled dark green)
                    _SolidSocialButton(
                      label: 'Continue with Email',
                      bg: deepGreen,
                      fg: Colors.white,
                      iconPath: 'assets/icons/mail.svg',
                      onTap: () {
                        // TODO: go to email flow (could reuse LoginScreen if same UI)
                      },
                    ),

                    const SizedBox(height: 26),

                    // bottom row: Already have an account? Log in!
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?  ',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Log in!',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Girl + bubble on top dark area
          Positioned(
            top: media.padding.top + 20,
            left: 0,
            right: 0,
            child: SizedBox(
              width: w,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // girl waving
                  Image.asset(
                    'assets/images/signup_girl.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  // speech bubble "Join us!"
                  Positioned(
                    left: 36,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: _SpeechBubbleBorder(
                          tailOffset: Offset(18, 18),
                        ),
                      ),
                      child: const Text(
                        'Join us!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------- BUTTON WIDGETS ------------------- */

/// Filled button (Facebook / Email)
class _SolidSocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _SolidSocialButton({
    required this.label,
    required this.iconPath,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
              // Facebook/email buttons are solid bg
              // so we usually keep original icon color
              // If you ever want white icon, pass colorFilter.
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Black outline button (Google)
class _OutlineButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          foregroundColor: Colors.black,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient outline button (Instagram)
class _GradientOutlineButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const _GradientOutlineButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B6BFF), // bluish-purple
            Color(0xFFFF3E6C), // pink/red
            Color(0xFFFFA64D), // orange
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.5),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------- SPEECH BUBBLE SHAPE ------------------- */

class _SpeechBubbleBorder extends ShapeBorder {
  final Offset tailOffset;
  const _SpeechBubbleBorder({required this.tailOffset});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // rounded bubble
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    final p = Path()..addRRect(r);

    // tiny tail
    final tx = rect.left + tailOffset.dx;
    final ty = rect.bottom - tailOffset.dy;
    p.moveTo(tx, ty);
    p.relativeLineTo(10, 8);
    p.relativeLineTo(-16, 2);
    p.close();

    return p;
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
