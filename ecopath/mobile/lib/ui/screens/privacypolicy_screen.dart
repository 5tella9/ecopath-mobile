// lib/ui/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Text _h1(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      s,
      textAlign: TextAlign.left,
      style: GoogleFonts.lato(
        color: cs.onSurface,
        fontSize: 20,
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
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.privacyPolicy, // from ARB
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
                    _h1(context, loc.privacySection1Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection1Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection2Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection2Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection3Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection3Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection4Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection4Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection5Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection5Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection6Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection6Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection7Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection7Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection8Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection8Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection9Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection9Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection10Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection10Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.privacySection11Title),
                    const SizedBox(height: 8),
                    _p(context, loc.privacySection11Body),
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
