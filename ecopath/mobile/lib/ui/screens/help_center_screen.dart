// lib/ui/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Text _h1(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      s,
      textAlign: TextAlign.left,
      style: GoogleFonts.lato(
        color: cs.onSurface,
        fontSize: 20,
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

  Widget _bullet(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: GoogleFonts.alike(
            color: cs.onSurfaceVariant,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        Expanded(child: _p(context, s)),
      ],
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
                      loc.helpCenter, // localized title
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
                    _h1(context, loc.helpCenterSection1Title),
                    const SizedBox(height: 8),
                    _p(context, loc.helpCenterSection1Body),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection2Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection2Bullet1),
                    _bullet(context, loc.helpCenterSection2Bullet2),
                    _bullet(context, loc.helpCenterSection2Bullet3),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection3Title),
                    const SizedBox(height: 8),
                    _p(context, loc.helpCenterSection3Body),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection3Bullet1),
                    _bullet(context, loc.helpCenterSection3Bullet2),
                    _bullet(context, loc.helpCenterSection3Bullet3),
                    _bullet(context, loc.helpCenterSection3Bullet4),
                    _bullet(context, loc.helpCenterSection3Bullet5),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection4Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection4Bullet1),
                    _bullet(context, loc.helpCenterSection4Bullet2),
                    _bullet(context, loc.helpCenterSection4Bullet3),
                    _bullet(context, loc.helpCenterSection4Bullet4),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection5Title),
                    const SizedBox(height: 8),
                    _p(context, loc.helpCenterSection5Body),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection5Bullet1),
                    _bullet(context, loc.helpCenterSection5Bullet2),
                    _bullet(context, loc.helpCenterSection5Bullet3),
                    _bullet(context, loc.helpCenterSection5Bullet4),
                    _bullet(context, loc.helpCenterSection5Bullet5),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection6Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection6Bullet1),
                    _bullet(context, loc.helpCenterSection6Bullet2),
                    _bullet(context, loc.helpCenterSection6Bullet3),
                    _bullet(context, loc.helpCenterSection6Bullet4),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection7Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection7Bullet1),
                    _bullet(context, loc.helpCenterSection7Bullet2),
                    _bullet(context, loc.helpCenterSection7Bullet3),
                    _bullet(context, loc.helpCenterSection7Bullet4),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection8Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection8Bullet1),
                    _bullet(context, loc.helpCenterSection8Bullet2),
                    _bullet(context, loc.helpCenterSection8Bullet3),
                    _bullet(context, loc.helpCenterSection8Bullet4),
                    _bullet(context, loc.helpCenterSection8Bullet5),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection9Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection9Bullet1),
                    _bullet(context, loc.helpCenterSection9Bullet2),
                    _bullet(context, loc.helpCenterSection9Bullet3),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection10Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection10Bullet1),
                    _bullet(context, loc.helpCenterSection10Bullet2),
                    _bullet(context, loc.helpCenterSection10Bullet3),

                    const SizedBox(height: 20),
                    _h1(context, loc.helpCenterSection11Title),
                    const SizedBox(height: 8),
                    _bullet(context, loc.helpCenterSection11Bullet1),
                    _bullet(context, loc.helpCenterSection11Bullet2),
                    _bullet(context, loc.helpCenterSection11Bullet3),
                    _bullet(context, loc.helpCenterSection11Bullet4),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        loc.helpCenterLastUpdated,
                        style: GoogleFonts.alike(
                          color: cs.onSurfaceVariant.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
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
