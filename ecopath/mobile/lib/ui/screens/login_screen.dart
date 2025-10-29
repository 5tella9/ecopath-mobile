import 'package:flutter/material.dart';
import 'package:ecopath/ui/root_shell.dart'; // you already navigate to /root so keeping import

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
    Navigator.of(context).pushReplacementNamed('/root'); // ✅ go to RootShell
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF00221C); // deep green
    const Color fieldBg = Color(0xFFEFF6F3); // pale greenish field fill
    const Color buttonDisabled = Color(0xFFB9BFB7); // gray/green button

    final double mascotSize = 120;
    final double sheetTopOffset = 100; // how far down the white sheet starts

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

                              // ===== BOTTOM content (clean version) =====
                              Column(
                                children: [
                                  const SizedBox(height: 24),

                                  GestureDetector(
                                    onTap: () {
                                      // TODO: forgot password flow
                                    },
                                    child: Text(
                                      'Forget password',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black.withOpacity(0.9),
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            Colors.black.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // "Next" button -> DASHBOARD
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: _goToDashboard,
                                      style: TextButton.styleFrom(
                                        backgroundColor: buttonDisabled,
                                        foregroundColor:
                                            Colors.black.withOpacity(0.8),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
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

                                  // ⬇ removed:
                                  // - the "or log in with" divider Row
                                  // - the 3 social icon buttons Row
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
