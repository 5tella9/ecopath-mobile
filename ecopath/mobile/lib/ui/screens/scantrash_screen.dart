// lib/ui/screens/scantrash_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:ecopath/core/progress_tracker.dart';
import 'package:ecopath/ui/root_shell.dart';

class ScanTrashScreen extends StatefulWidget {
  const ScanTrashScreen({super.key});

  @override
  State<ScanTrashScreen> createState() => _ScanTrashScreenState();
}

class _ScanTrashScreenState extends State<ScanTrashScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initFuture;
  List<CameraDescription> _cameras = const [];
  bool _hasCamera = false;
  bool _isScanning = false;
  String? _camError;

  late final AnimationController _lineCtrl;
  late final Animation<double> _lineAnim;

  int pointsEarned = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();

    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut),
    );
  }

  // ===========================================================
  //                     CAMERA INITIALIZATION
  // ===========================================================
  Future<void> _initCamera() async {
    setState(() => _camError = null);

    try {
      if (kIsWeb) {
        _hasCamera = false;
        _cameras = const [];
      } else {
        _cameras = await availableCameras();
        _hasCamera = _cameras.isNotEmpty;

        if (_hasCamera) {
          final back = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          );

          final ctrl = CameraController(
            back,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

          _initFuture = ctrl.initialize();
          await _controller?.dispose();

          setState(() => _controller = ctrl);
        } else {
          await _controller?.dispose();
          setState(() => _controller = null);
        }
      }
    } catch (e) {
      _camError = e.toString();
      await _controller?.dispose();

      setState(() {
        _controller = null;
        _hasCamera = false;
      });
    }
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // ===========================================================
  //                          SCANNING
  // ===========================================================
  Future<void> _scanTrash() async {
    if (_isScanning ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    final tracker = ProgressTracker.instance;
    if (tracker.energy <= 0) {
      _toast('Not enough energy to scan.');
      return;
    }

    // 1 energy per scan
    tracker.spendEnergy(1);

    setState(() => _isScanning = true);

    final XFile? photo = await _controller?.takePicture();
    if (photo == null) {
      setState(() => _isScanning = false);
      return;
    }

    const String apiUrl =
        "https://almost-enhancements-phys-doe.trycloudflare.com/predict";

    try {
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image_b64": base64Image}),
      );

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);
        _finishScan(result);
      } else {
        debugPrint("❌ Error ${res.statusCode}: ${res.body}");
        _toast("Scan failed (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
      _toast("Scan error: $e");
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  // ===========================================================
  //                     FINISH SCAN → SHOW RESULT
  // ===========================================================
  void _finishScan(Map<String, dynamic> result) {
    final cs = Theme.of(context).colorScheme;

    setState(() => pointsEarned += 15);

    ProgressTracker.instance.addPointsAndXp(15);

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan Complete!',
              style: GoogleFonts.lato(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scanned ${result['item']}, this must go to ${result['bin_korea']} • +15 pts',
              style: GoogleFonts.alike(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: cs.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    '+15 points',
                    style: GoogleFonts.lato(
                      color: cs.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _goToGamesTab() async {
    try {
      await _controller?.dispose();
    } catch (_) {}

    _controller = null;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 3)),
      (route) => false,
    );
  }

  // ===========================================================
  //                           UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final init = _initFuture;

    return WillPopScope(
      onWillPop: () async {
        await _goToGamesTab();
        return false;
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Stack(
            children: [
              // Camera Preview
              if (_controller != null && init != null)
                FutureBuilder(
                  future: init,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    return CameraPreview(_controller!);
                  },
                )
              else
                Container(color: Colors.black),

              // Scan overlay
              _ScannerOverlay(lineAnim: _lineAnim),

              // ---------- Top Bar ----------
              Positioned(
                left: 8,
                right: 16,
                top: 8,
                child: Row(
                  children: [
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primary,
                      ),
                      onPressed: _goToGamesTab,
                      icon:
                          Icon(Icons.arrow_back_rounded, color: cs.onPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scan Trash',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _PointsPill(points: pointsEarned),
                  ],
                ),
              ),

              // ---------- Bottom Controls ----------
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isScanning ? null : _scanTrash,
                    child: Text(
                      _isScanning ? "Scanning…" : "Scan",
                      style: GoogleFonts.lato(
                        color: cs.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
//                        WIDGETS
// ===========================================================

class _PointsPill extends StatelessWidget {
  final int points;
  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.stars, color: cs.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$points pts',
            style: GoogleFonts.lato(
              color: cs.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final Animation<double> lineAnim;

  const _ScannerOverlay({required this.lineAnim});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        size: Size.infinite,
        painter: _CutoutPainter(lineAnim.value),
      ),
    );
  }
}

class _CutoutPainter extends CustomPainter {
  final double t;
  _CutoutPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final scanRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.22,
      size.width * 0.70,
      size.height * 0.45,
    );

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..blendMode = BlendMode.darken;

    canvas.drawRect(Offset.zero & size, bgPaint);

    // Clear scan window
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(scanRect, clearPaint);
    canvas.restore();

    // Green borders
    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(scanRect, borderPaint);

    // Moving scan line
    final lineY = scanRect.top + (scanRect.height * t);
    final linePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.75)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(scanRect.left, lineY),
      Offset(scanRect.right, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_CutoutPainter old) => old.t != t;
}
