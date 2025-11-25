import 'package:flutter/material.dart';
import 'package:ecopath/ui/root_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _pwCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    // After login, show intro-style loading page.
    Navigator.of(context).pushReplacementNamed('/intro-loading');
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF00221C); // deep green
    const Color fieldBg = Color(0xFFEFF6F3); // pale greenish field fill
    const Color buttonBase = Color(0xFFB9BFB7); // idle button color
    const Color buttonPressed = Color(0xFF00221C); // when pressed

    final double mascotSize = 120;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // dark background base
            Container(color: bgDark),

            // white rounded sheet
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ===== TOP content =====
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 24),

                                  Text(
                                    'Log in with Email',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 24),

                                  _RoundedInput(
                                    controller: _emailCtl,
                                    hintText: 'Email address',
                                    backgroundColor: fieldBg,
                                    obscureText: false,
                                  ),

                                  const SizedBox(height: 16),

                                  _RoundedInput(
                                    controller: _pwCtl,
                                    hintText: 'Password',
                                    backgroundColor: fieldBg,
                                    obscureText: _obscure,
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscure = !_obscure;
                                        });
                                      },
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // ===== BOTTOM content =====
                              Column(
                                children: [
                                  const SizedBox(height: 24),

                                  const SizedBox(height: 16),

                                  // "Next" button -> IntroLoadingScreen -> DASHBOARD
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: _goToDashboard,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith<
                                                Color>((states) {
                                          if (states.contains(
                                              MaterialState.pressed)) {
                                            return buttonPressed;
                                          }
                                          return buttonBase;
                                        }),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                          Colors.black.withOpacity(0.8),
                                        ),
                                        padding:
                                            MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        shape:
                                            MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // mascot sitting on top edge of white sheet
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/logingirl.png',
                  width: mascotSize,
                  height: mascotSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- reusable rounded textfield ---------- */
class _RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color backgroundColor;
  final Widget? trailing;

  const _RoundedInput({
    required this.controller,
    required this.hintText,
    required this.backgroundColor,
    required this.obscureText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
