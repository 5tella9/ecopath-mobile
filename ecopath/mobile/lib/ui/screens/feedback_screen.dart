// lib/ui/screens/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecopath/l10n/app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  TextStyle _titleStyle(BuildContext context) => GoogleFonts.lato(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );

  TextStyle _btnStyle(BuildContext context) => GoogleFonts.alike(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  TextStyle _labelStyle(BuildContext context) => GoogleFonts.lato(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  InputBorder _inputBorder(ColorScheme cs) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      );

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    // later you can send this to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.feedbackThankYou)),
    );

    _emailController.clear();
    _subjectController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ======= HEADER =======
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  color: cs.primary,
                  padding: const EdgeInsets.only(top: 21, bottom: 83),
                  width: double.infinity,
                  child: Column(
                    children: [
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
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: cs.onPrimary.withOpacity(.25),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Girl illustration
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
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: Text(t.feedbackTitle, style: _titleStyle(context)),
                      ),
                      const SizedBox(height: 16),

                      // Form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              Text(t.feedbackEmail, style: _labelStyle(context)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.lato(fontSize: 14),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: _inputBorder(cs),
                                  enabledBorder: _inputBorder(cs),
                                  focusedBorder: _inputBorder(cs),
                                  filled: true,
                                  fillColor: cs.surface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return t.feedbackEmailError;
                                  }
                                  if (!value.contains('@')) {
                                    return t.feedbackEmailInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Subject
                              Text(t.feedbackSubject, style: _labelStyle(context)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _subjectController,
                                style: GoogleFonts.lato(fontSize: 14),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: _inputBorder(cs),
                                  enabledBorder: _inputBorder(cs),
                                  focusedBorder: _inputBorder(cs),
                                  filled: true,
                                  fillColor: cs.surface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return t.feedbackSubjectError;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Description
                              Text(t.feedbackDescription,
                                  style: _labelStyle(context)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 6,
                                minLines: 4,
                                style: GoogleFonts.lato(fontSize: 14),
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: _inputBorder(cs),
                                  enabledBorder: _inputBorder(cs),
                                  focusedBorder: _inputBorder(cs),
                                  filled: true,
                                  fillColor: cs.surface,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return t.feedbackDescriptionError;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: cs.primary,
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    t.feedbackSubmit,
                                    style: _btnStyle(context),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
