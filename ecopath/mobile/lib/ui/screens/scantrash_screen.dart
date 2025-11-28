// lib/ui/screens/scantrash_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:ecopath/core/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ecopath/core/progress_tracker.dart';
import 'package:ecopath/ui/root_shell.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/enums.dart';
import 'package:geocoding/geocoding.dart';

class BagRule {
  final String bagColor;
  final String imagePath;
  final WasteType wasteType;  // <-- use enum instead of string
  final int basePointsPerLiter;

  BagRule(this.bagColor, this.imagePath, this.wasteType,
      {this.basePointsPerLiter = 1});
}

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
  String? _selectedRegion;
  String? _selectedDistrict;

  int pointsEarned = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();

    _getAddressFromLocation();

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
        "https://pos-guitar-pick-his.trycloudflare.com/predict";

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
        final visibleBags = _getVisibleBags(); // based on location


        String wasteType = WasteType.values
            .firstWhere(
              (e) => e.name.toLowerCase() == (result['WasteType'] ?? '').toLowerCase(),
          orElse: () => WasteType.GeneralWaste, // fallback 🚀
        )
            .name;

        await _sendToWasteScanAPI(
          base64Img: base64Image,
          wasteType: wasteType,
        );

        final selectedBag = visibleBags.firstWhere(
              (b) => b.wasteType.name.toLowerCase() == wasteType.toLowerCase(),
          orElse: () => yellowFood, // default fallback
        );

        _finishScan(result, selectedBag);
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



// ===== RECYCLABLES =====
  final BagRule blueMetal   = BagRule("Blue Bag", "assets/images/bluebag.png", WasteType.Metal);
  final BagRule blueGlass   = BagRule("Blue Bag", "assets/images/bluebag.png", WasteType.Glass);
  final BagRule bluePaper   = BagRule("Blue Bag", "assets/images/bluebag.png", WasteType.PaperAndCardboard);
  final BagRule bluePlastic = BagRule("Blue Bag", "assets/images/bluebag.png", WasteType.Plastic);

// Yellow alternative for plastic in some areas
  final BagRule yellowPlastic = BagRule("Yellow Bag", "assets/images/yellowbag.png", WasteType.Plastic);

// ===== FOOD WASTE =====
  final BagRule purpleFood  = BagRule("Purple Bag", "assets/images/purplebag.png", WasteType.BioWaste);
  final BagRule yellowFood  = BagRule("Yellow Bag", "assets/images/yellowbag.png", WasteType.BioWaste);
  final BagRule orangeFood  = BagRule("Orange Bag", "assets/images/orangebag.png", WasteType.BioWaste);
  final BagRule blueFood   = BagRule("Green Bag", "assets/images/bluebag.png", WasteType.BioWaste);

// ===== GENERAL WASTE =====
  final BagRule whiteGeneral = BagRule("White Bag", "assets/images/whitebag.png", WasteType.GeneralWaste);





  List<BagRule> _getVisibleBags() {

    final Map<String, List<BagRule>> seoulDistrictRules = {
      "Seocho-gu":   [bluePlastic, blueGlass, blueMetal, bluePaper, blueFood, whiteGeneral],
      "Gwangjin-gu": [bluePlastic, blueGlass, blueMetal, bluePaper, purpleFood, whiteGeneral],
      "Gangnam-gu":  [bluePlastic, blueGlass, blueMetal, bluePaper, yellowFood, whiteGeneral],
      "Jung-gu":     [bluePlastic, blueGlass, blueMetal, bluePaper, purpleFood, whiteGeneral],
      "Jongno-gu":   [bluePlastic, blueGlass, blueMetal, bluePaper, orangeFood, whiteGeneral],
      "Songpa-gu":   [bluePlastic, blueGlass, blueMetal, bluePaper, yellowFood, whiteGeneral],
      "Dobong-gu":   [yellowPlastic, blueGlass, blueMetal, bluePaper, yellowFood, whiteGeneral],

      // Default: MOST districts in Seoul
      "default":     [bluePlastic, blueGlass, blueMetal, bluePaper, yellowFood, whiteGeneral],
    };

    if (_selectedRegion != "Seoul" || _selectedDistrict == null) return [];

    return seoulDistrictRules[_selectedDistrict!] ??
        seoulDistrictRules["default"]!;
  }



  Future<void> _getAddressFromLocation() async {
    Position position = await _getLocation();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      _selectedRegion = place.administrativeArea; // Region / State
      _selectedDistrict = place.locality;         // District / City
    });
  }



  Future<void> _sendToWasteScanAPI({
    required String base64Img,
    required String wasteType,
  }) async {
    try {
      final pos = await _getLocation();
      debugPrint("Geolocation: ${pos.latitude}, ${pos.longitude}");
      final res = await http.post(

        Uri.parse(ApiConfig.baseUrl + "/api/waste-scans"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image": base64Img,
          "timestamp" : "2025-01-01 10:00:00.000000 +00:00",
          "wasteType": wasteType.toLowerCase(),
          "geoLocation": {
            "latitude": pos.latitude,
            "longitude": pos.longitude,
          }
        }),
      );

      if (res.statusCode == 200) {
        debugPrint("Waste scan succesvol opgeslagen! 👍");
      } else {
        debugPrint("❌ Server error: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Fout bij POST: $e");
    }
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Locatieservices staan uit.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Locatie permissie geweigerd.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Locatie permanent geblokkeerd.');
    }

    return await Geolocator.getCurrentPosition();
  }


  // ===========================================================
  //                     FINISH SCAN → SHOW RESULT
  // ===========================================================
  void _finishScan(Map<String, dynamic> result, BagRule selectedBag) {
    final cs = Theme.of(context).colorScheme;

    setState(() => pointsEarned += 15);

    ProgressTracker.instance.rewardFromGame(
      points: 15,
      gameName: 'Scan Trash',
    );

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

            // 🟢 SHOW BAG IMAGE HERE
            Image.asset(
              selectedBag.imagePath,
              height: 120,
            ),
            const SizedBox(height: 12),

            Text(
              'You scanned ${result['item']} — this must go to\n${result['bin_korea']} (${selectedBag.bagColor}) • +15 pts',
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

  
  Navigator.of(context).pop();
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
