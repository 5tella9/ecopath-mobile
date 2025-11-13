// lib/ui/screens/termsofservice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const Color kInk = Color(0xFF00221C);
  static const Color kBg = Color(0xFFF5F5F5);

  Text _h1(String s) => Text(
        s,
        textAlign: TextAlign.left,
        style: GoogleFonts.lato(
          color: kInk,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _p(String s) => Text(
        s,
        textAlign: TextAlign.left,
        style: GoogleFonts.alike(
          color: kInk,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 24,
                      height: 24,
                      semanticsLabel: 'Back',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.lato(
                        color: kInk,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _p('Last updated: Oct 14, 2025'),
                    const SizedBox(height: 20),

                    _h1('1. Agreement to Terms'),
                    const SizedBox(height: 8),
                    _p(
                      'By creating an account or using EcoPath, you agree to be bound by these Terms. '
                      'If you do not agree, do not use the Service.',
                    ),

                    const SizedBox(height: 20),
                    _h1('2. Who May Use EcoPath'),
                    const SizedBox(height: 8),
                    _p(
                      'You must be at least 13 years old (or the minimum age required in your country) '
                      'to use the Service. If you are under 18, you represent that you have parental consent.',
                    ),

                    const SizedBox(height: 16),
                    _h1('3. Your Account & Security'),
                    const SizedBox(height: 8),
                    _p(
                      'You are responsible for maintaining the confidentiality of your credentials and for all '
                      'activities that occur under your account. Notify us of any unauthorized use.',
                    ),

                    const SizedBox(height: 16),
                    _h1('4. Acceptable Use'),
                    const SizedBox(height: 8),
                    _p(
                      'Do not misuse EcoPath. For example, do not: (a) break the law; (b) reverse engineer, '
                      'scrape, or overload our systems; (c) upload malware; (d) harass others; or (e) attempt '
                      'to gain unauthorized access to any part of the Service.',
                    ),

                    const SizedBox(height: 16),
                    _h1('5. Content & Licenses'),
                    const SizedBox(height: 8),
                    _p(
                      'You own the content you submit. You grant EcoPath a worldwide, non-exclusive, royalty-free '
                      'license to host, store, process, and display your content solely to operate and improve the Service.',
                    ),

                    const SizedBox(height: 16),
                    _h1('6. Virtual Points & Rewards'),
                    const SizedBox(height: 8),
                    _p(
                      'Points, badges, or rewards have no cash value and are not transferable. We may modify or '
                      'terminate reward programs at any time.',
                    ),

                    const SizedBox(height: 16),
                    _h1('7. Third-Party Services'),
                    const SizedBox(height: 8),
                    _p(
                      'EcoPath may link to or integrate third-party services (e.g., maps, payment, authentication). '
                      'Those services are governed by their own terms and policies.',
                    ),

                    const SizedBox(height: 16),
                    _h1('8. Privacy'),
                    const SizedBox(height: 8),
                    _p(
                      'Please see our Privacy Policy to understand how we collect, use, and share information.',
                    ),

                    const SizedBox(height: 16),
                    _h1('9. Disclaimers'),
                    const SizedBox(height: 8),
                    _p(
                      'EcoPath is provided “as is” and “as available.” We disclaim all warranties to the extent '
                      'permitted by law, including implied warranties of merchantability, fitness for a particular '
                      'purpose, and non-infringement.',
                    ),

                    const SizedBox(height: 16),
                    _h1('10. Limitation of Liability'),
                    const SizedBox(height: 8),
                    _p(
                      'To the maximum extent permitted by law, EcoPath and its affiliates will not be liable for any '
                      'indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenue.',
                    ),

                    const SizedBox(height: 16),
                    _h1('11. Termination'),
                    const SizedBox(height: 8),
                    _p(
                      'We may suspend or terminate your access at any time if you breach these Terms or if required by law. '
                      'You may stop using the Service at any time.',
                    ),

                    const SizedBox(height: 16),
                    _h1('12. Changes to These Terms'),
                    const SizedBox(height: 8),
                    _p(
                      'We may update these Terms from time to time. We will post the updated version in the app. '
                      'Your continued use after changes means you accept the new Terms.',
                    ),

                    const SizedBox(height: 16),
                    _h1('13. Contact Us'),
                    const SizedBox(height: 8),
                    _p(
                      'If you have questions about these Terms, contact the EcoPath team at support@ecopath.app.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
