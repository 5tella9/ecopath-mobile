// lib/ui/screens/termsofservice_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Text _h1(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      s,
      textAlign: TextAlign.left,
      style: GoogleFonts.lato(
        color: cs.onSurface,
        fontSize: 20, // match Privacy Policy section headers
        fontWeight: FontWeight.w700,
        height: 1.28,
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
        height: 1.6,
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
            // ---- Top bar (same style as Privacy Policy) ----
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
                      loc.termsOfService,
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
                    _p(context, loc.termsLastUpdated),
                    const SizedBox(height: 20),

                    _h1(context, loc.termsSection1Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection1Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection2Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection2Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection3Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection3Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection4Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection4Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection5Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection5Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection6Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection6Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection7Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection7Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection8Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection8Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection9Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection9Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection10Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection10Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection11Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection11Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection12Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection12Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.termsSection13Title),
                    const SizedBox(height: 8),
                    _p(context, loc.termsSection13Body),
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
