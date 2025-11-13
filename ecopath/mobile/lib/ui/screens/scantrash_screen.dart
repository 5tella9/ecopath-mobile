import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _scanTrash() async {
    if (_isScanning || _controller == null || !_controller!.value.isInitialized) return;

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

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image_b64": base64Image}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _finishScan(result);
      } else {
        debugPrint("❌ Error ${response.statusCode}: ${response.body}");
        _toast('Scan failed (${response.statusCode})');
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
      _toast('Scan error: $e');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _finishScan(Map<String, dynamic> result) {
    final cs = Theme.of(context).colorScheme;
    setState(() => pointsEarned += 15);
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
            Text('Scan Complete!',
                style: GoogleFonts.lato(
                    color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'you scanned ${result['item']}, this needs to be in the ${result['bin_korea']} • +15 pts',
              style: GoogleFonts.alike(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: cs.onPrimary),
                  const SizedBox(width: 8),
                  Text('+15 points',
                      style: GoogleFonts.lato(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              // Camera preview if available; otherwise a neutral dim background
              if (_controller != null && init != null)
                FutureBuilder(
                  future: init,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CameraPreview(_controller!);
                  },
                )
              else
                Container(color: Colors.black.withOpacity(0.35)),

              // Scanner overlay
              _ScannerOverlay(lineAnim: _lineAnim),

              // Top bar: Material back button (no SVG) + title + points
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
                      icon: Icon(Icons.arrow_back_rounded, color: cs.onPrimary),
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

              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Daily Quest: Scan 3 items • +30',
                        style: GoogleFonts.alike(
                          color: cs.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Capture button only when a real camera is initialized.
                    if (_controller != null &&
                        _hasCamera &&
                        (_controller?.value.isInitialized ?? false))
                      GestureDetector(
                        onTap: _scanTrash,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.primary, width: 4),
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          FilledButton.icon(
                            onPressed: _initCamera,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb)
                                ? 'iOS Simulator has no camera.'
                                : (_camError ?? 'No cameras found.'),
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Loading veil during scan
              if (_isScanning)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
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

class _PointsPill extends StatelessWidget {
  final int points;
  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    return LayoutBuilder(builder: (context, c) {
      const double margin = 28;
      final scanRect = Rect.fromLTWH(
        margin,
        c.maxHeight * 0.18,
        c.maxWidth - margin * 2,
        c.maxHeight * 0.42,
      );

      return Stack(children: [
        Container(color: Colors.black.withOpacity(0.35)),
        CustomPaint(
          size: Size(c.maxWidth, c.maxHeight),
          painter: _CutoutPainter(scanRect: scanRect, radius: 18),
        ),
        Positioned.fromRect(
          rect: scanRect,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(.9), width: 2),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: lineAnim,
          builder: (_, __) {
            final y = scanRect.top + (scanRect.height - 2) * lineAnim.value;
            return Positioned(
              left: scanRect.left + 6,
              right: scanRect.right - 6,
              top: y,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF71D8C6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ]);
    });
  }
}

class _CutoutPainter extends CustomPainter {
  final Rect scanRect;
  final double radius;
  _CutoutPainter({required this.scanRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(radius)));
    final cutPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..blendMode = BlendMode.dstOut;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(overlay, Paint()..color = Colors.black.withOpacity(0.35));
    canvas.drawPath(cutout, cutPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter old) =>
      old.scanRect != scanRect || old.radius != radius;
}
