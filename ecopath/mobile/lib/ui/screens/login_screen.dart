import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtl = TextEditingController();
  final TextEditingController _pwCtl = TextEditingController();
  bool _obscure = true;

  String? _emailError;
  String? _pwError;

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    setState(() {
      _emailError = null;
      _pwError = null;
    });

    final email = _emailCtl.text.trim();
    final pw = _pwCtl.text.trim();

    bool ok = true;

    if (email.isEmpty) {
      _emailError = "Please enter your email";
      ok = false;
    } else if (!email.contains("@")) {
      _emailError = "Invalid email format";
      ok = false;
    }

    if (pw.isEmpty) {
      _pwError = "Please enter your password";
      ok = false;
    }

    if (!ok) return;

    // Success → go to intro loading then dashboard
    Navigator.of(context).pushReplacementNamed('/intro-loading');
  }

  void _goToSignUp() {
    Navigator.of(context).pushNamed('/signup'); // <-- change route if needed
  }

  @override
  Widget build(BuildContext context) {
    const Color bgDark = Color(0xFF00221C);
    const Color fieldBg = Color(0xFFEFF6F3);
    const Color buttonBase = Color(0xFFB9BFB7);
    const Color buttonPressed = Color(0xFF00221C);

    final double mascotSize = 120;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: bgDark),

            // White sheet filling bottom
            Positioned.fill(
              top: 120,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Log in with Email',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // EMAIL FIELD
                        _RoundedInput(
                          controller: _emailCtl,
                          hintText: 'Email address',
                          backgroundColor: fieldBg,
                          obscureText: false,
                          errorText: _emailError,
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD FIELD
                        _RoundedInput(
                          controller: _pwCtl,
                          hintText: 'Password',
                          backgroundColor: fieldBg,
                          obscureText: _obscure,
                          trailing: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          errorText: _pwError,
                        ),

                        const SizedBox(height: 40),

                        // NEXT BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _attemptLogin,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states
                                    .contains(MaterialState.pressed)) {
                                  return buttonPressed;
                                }
                                return buttonBase;
                              }),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // NEW MEMBER? SIGN UP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New member? ',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _goToSignUp,
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00221C),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Mascot on top
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/logingirl.png',
                  width: mascotSize,
                  height: mascotSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- INPUT FIELD WITH ERROR SUPPORT ---------- */
class _RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color backgroundColor;
  final Widget? trailing;
  final String? errorText;

  const _RoundedInput({
    required this.controller,
    required this.hintText,
    required this.backgroundColor,
    required this.obscureText,
    this.trailing,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: hasError
                ? Border.all(color: Colors.red, width: 1.4)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: InputBorder.none,
                  ).copyWith(hintText: hintText),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
