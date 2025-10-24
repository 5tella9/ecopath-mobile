import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ScanTrashScreen extends StatefulWidget {
  const ScanTrashScreen({super.key});

  @override
  State<ScanTrashScreen> createState() => _ScanTrashScreenState();
}

class _ScanTrashScreenState extends State<ScanTrashScreen>
    with SingleTickerProviderStateMixin {
  static const Color kInk = Color(0xFF00221C);
  static const Color kBg = Color(0xFFF5F5F5);

  CameraController? _controller;
  Future<void>? _initFuture;

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
    final cams = await availableCameras();
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cams.first,
    );
    final ctrl = CameraController(back, ResolutionPreset.medium,
        enableAudio: false);
    _initFuture = ctrl.initialize();
    setState(() => _controller = ctrl);
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _scanTrash() async {
    final XFile? photo = await _controller?.takePicture();
    if (photo == null) return;

    const String apiUrl = "https://giveable-mikayla-hasteless.ngrok-free.dev/predict";

    try {
      // Read image bytes
      final bytes = await photo.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Make the request body
      final Map<String, dynamic> body = {
        "image_base64": "data:image/jpeg;base64,$base64Image",
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint("✅ Prediction:");
        debugPrint(result.toString());
        // Example: show results in UI
        debugPrint("Klasse: ${result['klasse']}");
        debugPrint("Confidence: ${result['confidence']}");
        debugPrint("Bak: ${result['bak']}");
        _finishScan(result);
      } else {
        debugPrint("❌ Error: ${response.statusCode}");
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
    }
  }

  void _finishScan(Map<String, dynamic> result) {
    // Simulate detection + reward popup
    setState(() => pointsEarned += 15);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Scan Complete!', style: GoogleFonts.lato(
              color: kInk, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text( 'you scanned ${result['klasse']}, this needs to be in the ${result['bak']} • +15 pts',
                style: GoogleFonts.alike(color: kInk, fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kInk,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Color(0xFFF5F5F5)),
                  const SizedBox(width: 8),
                  Text('+15 points',
                      style: GoogleFonts.lato(
                        color: const Color(0xFFF5F5F5),
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

  @override
  Widget build(BuildContext context) {
    final init = _initFuture;
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
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
              const Center(child: CircularProgressIndicator()),

            // Dark overlay with cutout + scan line
            _ScannerOverlay(lineAnim: _lineAnim),

            // Top bar (Back + title + points pill)
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Row(
                children: [
                  // back.svg inside dark box (00221C) with white icon (F5F5F5)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00221C),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/back.svg',
                        width: 20,
                        height: 20,
                        //colorFilter: const ColorFilter.mode(
                          //Color(0xFFF5F5F5), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Scan Trash', style: GoogleFonts.lato(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _PointsPill(points: pointsEarned),
                ],
              ),
            ),

            // Bottom actions
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Daily quest chip-style hint
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Daily Quest: Scan 3 items • +30',
                        style: GoogleFonts.alike(
                            color: kInk, fontSize: 12, fontWeight: FontWeight.w400)),
                  ),
                  const SizedBox(height: 14),
                  // Capture/Scan button
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
                          border: Border.all(color: kInk, width: 4),
                        ),
                      ),
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
}

class _PointsPill extends StatelessWidget {
  final int points;
  const _PointsPill({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00221C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Color(0xFFF5F5F5), size: 18),
          const SizedBox(width: 6),
          Text('$points pts',
              style: GoogleFonts.lato(
                color: const Color(0xFFF5F5F5),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

/// Overlay that dims the camera except a rounded-rect "scan window" and
/// animates a scanning line up/down.
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
        // Dim the whole screen
        Container(color: Colors.black.withOpacity(0.35)),
        // Clear the scanRect area using BlendMode
        CustomPaint(
          size: Size(c.maxWidth, c.maxHeight),
          painter: _CutoutPainter(scanRect: scanRect, radius: 18),
        ),
        // Stroke around scanRect
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
        // Moving scan line
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF71D8C6),
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
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..blendMode = BlendMode.dstOut;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(overlay, Paint()..color = Colors.black.withOpacity(0.35));
    canvas.drawPath(cutout, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect || oldDelegate.radius != radius;
}
