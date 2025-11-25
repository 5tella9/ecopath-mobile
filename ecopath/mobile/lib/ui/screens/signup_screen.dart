import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // make sure this path is correct

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  bool _obscurePw = true;
  bool _obscureConfirmPw = true;

  TextStyle _labelStyle(BuildContext context) {
    return GoogleFonts.alike(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade800,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      // override dark theme for textfields
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: GoogleFonts.alike(
        fontSize: 14,
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF5E9460),
          width: 1.5,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('Sign up with:');
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_pwController.text}');
      // TODO: call backend signup here later

      // ✅ AFTER SIGN UP → GO TO SURVEY FLOW
      Navigator.pushReplacementNamed(context, '/survey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* ---------- TOP HERO SECTION ---------- */
              SizedBox(
                height: 260,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // dark green background bar
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFF00221C),
                    ),

                    // GIRL + SPEECH BUBBLE (on green)
                    Positioned(
                      top: 24,
                      left: 0,
                      right: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // speech bubble on LEFT of her head
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(
                              right: 8,
                              top: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "Join us!",
                              style: GoogleFonts.alike(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // girl image
                          SizedBox(
                            height: 110,
                            child: Image.asset(
                              'assets/images/signupgirl.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // WHITE CONTAINER (card)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 120,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Sign Up Here!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.alike(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create an account & be with EcoPath!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.alike(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF5E9460),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /* ---------- FORM SECTION ---------- */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full name
                      Text("Full name", style: _labelStyle(context)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(hint: "Your name"),
                        style: GoogleFonts.alike(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      Text("Email", style: _labelStyle(context)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            _inputDecoration(hint: "example@email.com"),
                        style: GoogleFonts.alike(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter your email";
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Text("Password", style: _labelStyle(context)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _pwController,
                        obscureText: _obscurePw,
                        decoration: _inputDecoration(
                          hint: "Enter password",
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePw
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePw = !_obscurePw;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.alike(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter a password";
                          }
                          if (val.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Text("Confirm password", style: _labelStyle(context)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmPwController,
                        obscureText: _obscureConfirmPw,
                        decoration: _inputDecoration(
                          hint: "Re-enter password",
                          suffix: IconButton(
                            icon: Icon(
                              _obscureConfirmPw
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPw = !_obscureConfirmPw;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.alike(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (val != _pwController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign Up button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E9460),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _onSignUpPressed,
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.alike(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey.shade300,
                  height: 1,
                ),
              ),

              const SizedBox(height: 16),

              // already have account? login
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.alike(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log in!",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00221C),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF00221C),
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
}
