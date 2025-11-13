// lib/ui/screens/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String query = '';

  TextStyle _titleStyle(BuildContext context) =>
      GoogleFonts.lato(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );

  TextStyle _btnStyle(BuildContext context) =>
      GoogleFonts.alike(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  Widget _pillButton(BuildContext context, String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        margin: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(label, style: _btnStyle(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ======= THEMED HEADER (primary bg) =======
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  color: cs.primary,
                  padding: const EdgeInsets.only(top: 21, bottom: 83),
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Back button (kept as SVG, tinted with onPrimary)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18, bottom: 23),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: 44,
                              height: 39,
                              decoration: BoxDecoration(
                                color: cs.primary, // blend into header
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: cs.onPrimary.withOpacity(.25),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/back.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    cs.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Search bar (surface on primary)
                      Container
                      (
                        margin: const EdgeInsets.symmetric(horizontal: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.onPrimary.withOpacity(.15)),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 13),
                              child: Icon(Icons.search, color: cs.onSurfaceVariant),
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => query = v),
                                style: GoogleFonts.alike(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Search',
                                  hintStyle: GoogleFonts.alike(
                                    color: cs.onSurfaceVariant.withOpacity(.7),
                                    fontSize: 12,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Girl image
                Positioned(
                  bottom: -43,
                  right: 0,
                  child: SizedBox(
                    width: 113,
                    height: 130,
                    child: Image.asset(
                      'assets/images/logingirl.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),

            // ======= CONTENT =======
            Expanded(
              child: Container(
                width: double.infinity,
                color: cs.surfaceContainerLowest,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 32, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: Text('Feedback', style: _titleStyle(context)),
                      ),
                      const SizedBox(height: 8),

                      _pillButton(context, 'App Experience',
                          () => _tap(context, 'App Experience')),
                      _pillButton(context, 'Feature Functionality',
                          () => _tap(context, 'Feature Functionality')),
                      _pillButton(context, 'Content & Information',
                          () => _tap(context, 'Content & Information')),
                      _pillButton(context, 'Performance & Technical Issues',
                          () => _tap(context, 'Performance & Technical Issues')),
                      _pillButton(context, 'Suggestions',
                          () => _tap(context, 'Suggestions')),
                      _pillButton(context, 'Satisfaction Rating',
                          () => _tap(context, 'Satisfaction Rating')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tap(BuildContext ctx, String which) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Pressed: $which')),
    );
  }
}
