// lib/ui/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Text _h1(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      s,
      textAlign: TextAlign.left,
      style: GoogleFonts.lato(
        color: cs.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    );
  }

  Widget _p(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      s,
      textAlign: TextAlign.left,
      style: GoogleFonts.alike(
        color: cs.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/back.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: tt.titleLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ---- Scrollable content ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _h1(context, '1. Introduction'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'EcoPath is committed to protecting your privacy. '
                        'This Privacy Policy explains what data we collect, how we use it, and the choices you have. '
                        'By using EcoPath, you agree to this Policy.'),

                    const SizedBox(height: 20),
                    _h1(context, '2. Information We Collect'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        '• Personal Information: such as your name, email address, or profile data (only if you provide them voluntarily).\n'
                        '• App Activity: achievements, points, challenges joined, basic usage analytics.\n'
                        '• Device Data: app version, OS, language, crash diagnostics.\n'
                        '• Optional Inputs: feedback messages, images you upload within features.\n'
                        '• Location (Optional): only if you enable features that require it.'),

                    const SizedBox(height: 20),
                    _h1(context, '3. How We Use Your Information'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        '• Provide and maintain core features (profiles, points).\n'
                        '• Improve app performance, safety, and reliability.\n'
                        '• Track and display your environmental progress, challenges, and achievements.\n'
                        '• Personalize non-sensitive content such as streak reminders.\n'
                        '• Communicate important updates, security notices, or policy changes.\n'
                        '• Comply with legal obligations.'),

                    const SizedBox(height: 20),
                    _h1(context, '4. Sharing & Transfers'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'We do not sell your personal data. We may share limited data with service providers who help us operate the app '
                        '(e.g., analytics, crash reporting) under confidentiality agreements. We may disclose information if required by law '
                        'or to protect our rights, users, or the public.'),

                    const SizedBox(height: 20),
                    _h1(context, '5. Data Retention'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'We retain your data for as long as your account is active or as needed to provide services. '
                        'You may request deletion; some records may be kept to meet legal or security requirements.'),

                    const SizedBox(height: 20),
                    _h1(context, '6. Your Choices & Rights'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        '• Access & Update: edit profile details in-app.\n'
                        '• Delete: request account deletion from Settings or by contacting us.\n'
                        '• Notifications: toggle reminders and notifications in Settings.\n'
                        '• Permissions: manage device-level permissions (e.g., location, camera).'),

                    const SizedBox(height: 20),
                    _h1(context, '7. Children’s Privacy'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'EcoPath is not directed to children under the age where parental consent is required by local law. '
                        'If we learn that we collected data from such a child without consent, we will delete it.'),

                    const SizedBox(height: 20),
                    _h1(context, '8. Security'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'We use reasonable technical and organizational measures to protect your information. '
                        'However, no method of transmission or storage is completely secure.'),

                    const SizedBox(height: 20),
                    _h1(context, '9. International Use'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'Your information may be processed in countries other than your own. '
                        'We take steps to ensure appropriate safeguards in line with applicable laws.'),

                    const SizedBox(height: 20),
                    _h1(context, '10. Changes to This Policy'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'We may update this Policy from time to time. We will notify you of material changes by in-app notice or other means. '
                        'Your continued use of EcoPath after changes indicates acceptance.'),

                    const SizedBox(height: 20),
                    _h1(context, '11. Contact Us'),
                    const SizedBox(height: 8),
                    _p(
                        context,
                        'If you have questions or requests about this Policy or your data, please contact our team via the Feedback section in Settings.'),
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
