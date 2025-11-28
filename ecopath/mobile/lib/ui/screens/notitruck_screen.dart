// lib/ui/screens/notitruck_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecopath/l10n/app_localizations.dart';
import 'package:ecopath/core/pickup_service.dart';

class NotiTruckScreen extends StatefulWidget {
  const NotiTruckScreen({super.key});

  @override
  State<NotiTruckScreen> createState() => _NotiTruckScreenState();
}

class _NotiTruckScreenState extends State<NotiTruckScreen> {
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle(BuildContext context) {
    return GoogleFonts.alike(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onBackground,
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return GoogleFonts.alike(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Validate inputs
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notiTruckSnackLocationMissing)),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take or select a photo')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Call the API
      final pickupService = PickupService();
      final response = await pickupService.submitPickupRequest(
        location: _locationController.text.trim(),
        imageFile: _imageFile!,
        notes: _noteController.text.trim(),
      );

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show result dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) {
            final isSuccess = response['success'] == true;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isSuccess ? l10n.notiTruckDialogTitle : 'Error',
                style: GoogleFonts.alike(
                  fontWeight: FontWeight.w700,
                  color: isSuccess ? cs.onSurface : Colors.red,
                ),
              ),
              content: Text(
                isSuccess 
                    ? l10n.notiTruckDialogMessage 
                    : response['error'] ?? 'An unknown error occurred',
                style: GoogleFonts.alike(
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // close dialog
                    if (isSuccess) {
                      Navigator.of(context).pop(); // go back to previous screen
                    }
                  },
                  child: Text(isSuccess ? l10n.notiTruckDialogDone : 'OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to submit request: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String label,
      {String? hint, int? maxLines}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: _labelStyle(context),
      hintStyle: GoogleFonts.alike(
        fontSize: 13,
        color: cs.onSurface.withOpacity(0.6),
      ),
      filled: true,
      fillColor: cs.surface.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      isDense: true,
      alignLabelWithHint: maxLines != null && maxLines > 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: cs.onBackground,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notiTruckTitle,
          style: GoogleFonts.alike(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onBackground,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notiTruckHeader,
                style: _titleStyle(context),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.notiTruckDescription,
                style: GoogleFonts.alike(
                  fontSize: 13,
                  color: cs.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Location
              TextField(
                controller: _locationController,
                decoration: _inputDecoration(
                  context,
                  l10n.notiTruckLocationLabel,
                  hint: l10n.notiTruckLocationHint,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Photo buttons
              Text(
                l10n.notiTruckPhotoLabel,
                style: _labelStyle(context),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: Text(l10n.notiTruckPhotoCamera),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.notiTruckPhotoGallery),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: cs.primary.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.file(
                      _imageFile!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Note
              TextField(
                controller: _noteController,
                decoration: _inputDecoration(
                  context,
                  l10n.notiTruckNoteLabel,
                  hint: l10n.notiTruckNoteHint,
                  maxLines: 4,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.alike(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.notiTruckRegisterButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
