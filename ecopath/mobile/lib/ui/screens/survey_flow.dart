// lib/ui/screens/survey_flow.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/userProvider.dart';
import '../../util/survey_storage.dart';

/* -------------------- MODEL -------------------- */
class SurveyData {
  SurveyData();

  String name = '';
  String dateOfBirth = ''; // yyyy/mm/dd
  String gender = '';

  // Korean-style address (English labels)
  String sido = ''; // Province/Metro City
  String sigungu = ''; // City/District
  String dong = ''; // Neighborhood
  String detail = ''; // Detailed address

  String houseType = '';
  String livingWith = '';

  // Extras for EcoPath
  List<String> ecoGoals = [];
  bool hasElectricBill = true;
  bool hasGasBill = true;
  String electricProvider = '';
  String gasProvider = '';
  bool wantsQuizzes = true;
  bool wantsNotifications = true;

  String toJson() => json.encode({
        'name': name,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'sido': sido,
        'sigungu': sigungu,
        'dong': dong,
        'detail': detail,
        'houseType': houseType,
        'livingWith': livingWith,
        'ecoGoals': ecoGoals,
        'hasElectricBill': hasElectricBill,
        'hasGasBill': hasGasBill,
        'electricProvider': electricProvider,
        'gasProvider': gasProvider,
        'wantsQuizzes': wantsQuizzes,
        'wantsNotifications': wantsNotifications,
      });

  factory SurveyData.fromJson(String source) {
    final map = json.decode(source);
    final data = SurveyData();
    data.name = map['name'] ?? '';
    data.dateOfBirth = map['dateOfBirth'] ?? '';
    data.gender = map['gender'] ?? '';
    data.sido = map['sido'] ?? '';
    data.sigungu = map['sigungu'] ?? '';
    data.dong = map['dong'] ?? '';
    data.detail = map['detail'] ?? '';
    data.houseType = map['houseType'] ?? '';
    data.livingWith = map['livingWith'] ?? '';
    data.ecoGoals = List<String>.from(map['ecoGoals'] ?? []);
    data.hasElectricBill = map['hasElectricBill'] ?? true;
    data.hasGasBill = map['hasGasBill'] ?? true;
    data.electricProvider = map['electricProvider'] ?? '';
    data.gasProvider = map['gasProvider'] ?? '';
    data.wantsQuizzes = map['wantsQuizzes'] ?? true;
    data.wantsNotifications = map['wantsNotifications'] ?? true;
    return data;
  }
}

/* -------------------- COLORS -------------------- */
const _ink = Color(0xFF00221C); // base green accent (toggle thumb)
const _fg = Color(0xFFF5F5F5); // main text color on gradient
const _muted = Color(0xCCF5F5F5); // hint / helper text
const _fieldBg = Color(0x14FFFFFF); // translucent input bg
const _border = Color(0x33FFFFFF); // translucent border

LinearGradient _bgGradient() => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF00221C),
        Color(0xFF0C3A2F),
        Color(0xFF145243),
      ],
    );

/* -------------------- ROOT SURVEY FLOW SCREEN -------------------- */
class SurveyFlow extends StatefulWidget {
  const SurveyFlow({super.key});
  @override
  State<SurveyFlow> createState() => _SurveyFlowState();
}

class _SurveyFlowState extends State<SurveyFlow> with TickerProviderStateMixin {
  final SurveyData data = SurveyData();
  Map<String, List<String>> _sidoSigungu = {};
  bool _loadingAddr = true;

  int index = 0;

  // Flow order:
  // 0 Welcome
  // 1 Name
  // 2 DOB
  // 3 Gender
  // 4 Address
  // 5 InterstitialAddress
  // 6 HouseType
  // 7 LivingWith
  // 8 Goals
  // 9 InterstitialCheer
  // 10 EnergyPlan
  // 11 QuizNotify
  // 12 Finish
  late final List<Widget Function()> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      () => _WelcomePage(onNext: _next),
      () => _NameStep(data: data, onNext: _next),
      () => _DobStep(data: data, onNext: _next),
      () => _GenderStep(data: data, onNext: _next),
      () => _AddressStep(
            data: data,
            onNext: _next,
            getMap: () => _sidoSigungu,
            loading: _loadingAddr,
          ),
      () => _InterstitialPage(
            text: "Now, we got your address.\nI will write it down.",
            imageAsset: 'assets/images/survey2.png',
            onNext: _next,
          ),
      () => _HouseTypeStep(data: data, onNext: _next),
      () => _LivingWithStep(data: data, onNext: _next),
      () => _GoalsStep(data: data, onNext: _next),
      () => _InterstitialPage(
            text: "Keep going!\nWe’re almost done!",
            imageAsset: 'assets/images/survey1.png',
            onNext: _next,
          ),
      
      () => _QuizNotifyStep(data: data, onNext: _next),
      () => _FinishStep(
            data: data,
        onFinish: () async {
          await SurveyStorage.save(data);

          // 🟢 Update user in Provider
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.updateFromSurvey(data);  // <-- ADD THIS

          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/intro-loading');
        },
          ),
    ];

    _loadAddressJson();
  }

  Future<void> _loadAddressJson() async {
  try {
    final raw = await rootBundle.loadString('assets/data/kr_address.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;

    final List<dynamic> regions = decoded['regions'] ?? [];

    final Map<String, List<String>> map = {};

    for (final region in regions) {
      final r = region as Map<String, dynamic>;

      // Use English names for survey (as you said)
      final String regionName = r['en'] as String;

      final List<dynamic> districts = r['districts'] ?? [];
      final List<String> districtNames = districts
          .map((d) => (d as Map<String, dynamic>)['en'] as String)
          .toList();

      map[regionName] = districtNames;
    }

    if (!mounted) return;
    setState(() {
      _sidoSigungu = map;
      _loadingAddr = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _sidoSigungu = {};
      _loadingAddr = false;
    });
  }
}


  void _next() => setState(() {
        index = (index + 1).clamp(0, _steps.length - 1);
      });
  void _back() => setState(() {
        index = (index - 1).clamp(0, _steps.length - 1);
      });

  bool get _isInterstitial => index == 0 || index == 5 || index == 9;

  @override
  Widget build(BuildContext context) {
    final titles = [
      '', // 0 welcome (no header)
      'What is your name?',
      'What is your date of birth?',
      'What is your gender?',
      'Enter your address',
      '', // 5 interstitial
      'What type of house do you live in?',
      'How many people do you live with?',
      'Your eco goals',
      '', // 9 interstitial
    
      'Quizzes & notifications',
      'All set!',
    ];
    final String title = titles[index];

    return Container(
      decoration: BoxDecoration(gradient: _bgGradient()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar + title (skip on interstitial pages)
              if (!_isInterstitial)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      if (index > 0)
                        InkWell(
                          onTap: _back,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _fg.withOpacity(.6)),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: _fg,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40, height: 40),
                      const Spacer(),
                      Image.asset(
                        'assets/images/ecopath.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

              if (!_isInterstitial)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GoogleFonts.lato(
                        color: _fg,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

              // Body / page content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim);
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: slide,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    key: ValueKey(index),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: _steps[index](),
                  ),
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (index + 1) / _steps.length,
                    backgroundColor: _fg.withOpacity(.2),
                    color: _fg,
                    minHeight: 6,
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

/* -------------------- WELCOME INTERSTITIAL -------------------- */
class _WelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fadeImg;
  late final Animation<Offset> _slideImg;
  late final Animation<double> _fadeText;
  late final Animation<Offset> _slideText;
  late final Animation<double> _fadeBtn;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _fadeImg = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _slideImg = Tween<Offset>(
      begin: const Offset(0, .10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _fadeText = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    _slideText = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _fadeBtn = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Text appears above the image visually, but anim starts later.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          FadeTransition(
            opacity: _fadeText,
            child: SlideTransition(
              position: _slideText,
              child: Column(
                children: [
                  Text(
                    'Welcome to EcoPath',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: _fg,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Let's start our journey.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: _muted,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          FadeTransition(
            opacity: _fadeImg,
            child: SlideTransition(
              position: _slideImg,
              child: Image.asset(
                'assets/images/welcome.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          FadeTransition(
            opacity: _fadeBtn,
            child: _nextBtn('Next', widget.onNext),
          ),
        ],
      ),
    );
  }
}

/* -------------------- GENERIC INTERSTITIAL PAGE -------------------- */
class _InterstitialPage extends StatefulWidget {
  final String text;
  final String imageAsset;
  final VoidCallback onNext;

  const _InterstitialPage({
    required this.text,
    required this.imageAsset,
    required this.onNext,
  });

  @override
  State<_InterstitialPage> createState() => _InterstitialPageState();
}

class _InterstitialPageState extends State<_InterstitialPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fadeText;
  late final Animation<Offset> _slideText;
  late final Animation<double> _fadeImg;
  late final Animation<Offset> _slideImg;
  late final Animation<double> _fadeBtn;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeText = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, .45, curve: Curves.easeOut),
    );
    _slideText = Tween<Offset>(
      begin: const Offset(0, .1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(0.0, .45, curve: Curves.easeOutCubic),
      ),
    );

    _fadeImg = CurvedAnimation(
      parent: _ac,
      curve: const Interval(.25, .75, curve: Curves.easeOut),
    );
    _slideImg = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ac,
        curve: const Interval(.25, .75, curve: Curves.easeOutCubic),
      ),
    );

    _fadeBtn = CurvedAnimation(
      parent: _ac,
      curve: const Interval(.7, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),

          FadeTransition(
            opacity: _fadeText,
            child: SlideTransition(
              position: _slideText,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: _fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          FadeTransition(
            opacity: _fadeImg,
            child: SlideTransition(
              position: _slideImg,
              child: Image.asset(
                widget.imageAsset,
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          FadeTransition(
            opacity: _fadeBtn,
            child: _nextBtn('Next', widget.onNext),
          ),
        ],
      ),
    );
  }
}

/* -------------------- SURVEY STEP WIDGETS -------------------- */

class _NameStep extends StatefulWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _NameStep({required this.data, required this.onNext});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  final _ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctl.text = widget.data.name;
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _go() {
    widget.data.name = _ctl.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Enter your name'),
        const SizedBox(height: 10),
        _darkTextField(
          controller: _ctl,
          hint: 'e.g., Stella',
          onDone: _go,
        ),
        const Spacer(),
        _nextBtn('Next', _go),
      ],
    );
  }
}

/// Date of Birth step (replaces "age")
class _DobStep extends StatefulWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _DobStep({required this.data, required this.onNext});

  @override
  State<_DobStep> createState() => _DobStepState();
}

class _DobStepState extends State<_DobStep> {
  final TextEditingController _dobCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dobCtl.text = widget.data.dateOfBirth;
  }

  @override
  void dispose() {
    _dobCtl.dispose();
    super.dispose();
  }

  // parse yyyy/mm/dd safely
  DateTime? _parseDobOrNull(String dobText) {
    final parts = dobText.split('/');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  // turn a DateTime into "yyyy/mm/dd"
  String _formatDateYMD(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  Future<void> _pickDate() async {
    final initial = _parseDobOrNull(widget.data.dateOfBirth) ??
        DateTime(DateTime.now().year - 20, 1, 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
      builder: (context, child) {
        // dark style picker to match survey aesthetic
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _fg,
              surface: Color(0xFF0F2E28),
              onSurface: _fg,
              onPrimary: _ink,
            ),
            dialogBackgroundColor: Color(0xFF0F2E28),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = _formatDateYMD(picked);
      setState(() {
        _dobCtl.text = formatted;
      });
    }
  }

  void _go() {
    widget.data.dateOfBirth = _dobCtl.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Enter your date of birth (yyyy/mm/dd)\nOr pick from calendar'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _darkTextField(
                controller: _dobCtl,
                hint: '1999/07/21',
                keyboardType: TextInputType.datetime,
                onDone: _go,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              width: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _fg.withOpacity(.9),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _pickDate,
                child: const Icon(
                  Icons.calendar_today,
                  color: _fg,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        _nextBtn('Next', _go),
      ],
    );
  }
}

class _GenderStep extends StatelessWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _GenderStep({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      'Female',
      'Male',
      'Non-binary',
      'Prefer not to say'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Choose one'),
        const SizedBox(height: 10),
        ...options.map(
          (o) => _pill(o, () {
            data.gender = o;
            onNext();
          }),
        ),
        const Spacer(),
      ],
    );
  }
}

class _AddressStep extends StatefulWidget {
  final SurveyData data;
  final VoidCallback onNext;
  final Map<String, List<String>> Function() getMap;
  final bool loading;
  const _AddressStep({
    required this.data,
    required this.onNext,
    required this.getMap,
    required this.loading,
  });

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  String? _sido;
  String? _sigungu;
  final _dongCtl = TextEditingController();
  final _detailCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sido = widget.data.sido.isEmpty ? null : widget.data.sido;
    _sigungu = widget.data.sigungu.isEmpty ? null : widget.data.sigungu;
    _dongCtl.text = widget.data.dong;
    _detailCtl.text = widget.data.detail;
  }

  @override
  void dispose() {
    _dongCtl.dispose();
    _detailCtl.dispose();
    super.dispose();
  }

  void _go() {
    widget.data.sido = _sido ?? '';
    widget.data.sigungu = _sigungu ?? '';
    widget.data.dong = _dongCtl.text.trim();
    widget.data.detail = _detailCtl.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _fg,
        ),
      );
    }

    final map = widget.getMap();
    final sidos = map.keys.toList()..sort();
    final sigungus = (_sido == null) ? <String>[] : (map[_sido] ?? []);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hint('Korean address format'),
          const SizedBox(height: 10),

          _label('Province / Metropolitan City (시/도)'),
          _darkDropdown(
            value: _sido,
            items: sidos,
            onChanged: (v) {
              setState(() {
                _sido = v;
                _sigungu = null;
              });
            },
          ),

          const SizedBox(height: 12),

          _label('City / District (시/군/구)'),
          _darkDropdown(
            value: _sigungu,
            items: sigungus,
            onChanged: (v) {
              setState(() {
                _sigungu = v;
              });
            },
          ),

          const SizedBox(height: 12),

          _label('Neighborhood (동/읍/면)'),
          _darkTextField(
            controller: _dongCtl,
            hint: 'e.g., Yeoksam-dong',
          ),

          const SizedBox(height: 12),

          _label('Detailed address'),
          _darkTextField(
            controller: _detailCtl,
            hint: 'e.g., 123-45, #101',
            onDone: _go,
          ),

          const SizedBox(height: 16),
          _nextBtn('Next', _go),
        ],
      ),
    );
  }
}

class _HouseTypeStep extends StatelessWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _HouseTypeStep({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      'Apartment',
      'House',
      'One-room (studio)',
      'Shared house',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Select one'),
        const SizedBox(height: 10),
        ...options.map(
          (o) => _pill(o, () {
            data.houseType = o;
            onNext();
          }),
        ),
        const Spacer(),
      ],
    );
  }
}

class _LivingWithStep extends StatelessWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _LivingWithStep({required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      '1 person (only me)',
      '2 people',
      '3 people',
      '4+ people',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Select one'),
        const SizedBox(height: 10),
        ...options.map(
          (o) => _pill(o, () {
            data.livingWith = o;
            onNext();
          }),
        ),
        const Spacer(),
      ],
    );
  }
}

class _GoalsStep extends StatefulWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _GoalsStep({required this.data, required this.onNext});

  @override
  State<_GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends State<_GoalsStep> {
  final goals = [
    'Reduce electricity use',
    'Reduce gas use',
    'Dispose trash properly',
    'Recycle more',
    'Cut food waste',
    'Use public transit more',
  ];
  final selected = <String>{};

  @override
  void initState() {
    super.initState();
    selected.addAll(widget.data.ecoGoals);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Choose your eco goals (multiple selections allowed)'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: goals.map((g) {
            final on = selected.contains(g);
            return _chip(g, on, () {
              setState(() => on ? selected.remove(g) : selected.add(g));
            });
          }).toList(),
        ),
        const Spacer(),
        _nextBtn('Next', () {
          widget.data.ecoGoals = selected.toList();
          widget.onNext();
        }),
      ],
    );
  }
}



class _QuizNotifyStep extends StatefulWidget {
  final SurveyData data;
  final VoidCallback onNext;
  const _QuizNotifyStep({required this.data, required this.onNext});

  @override
  State<_QuizNotifyStep> createState() => _QuizNotifyStepState();
}

class _QuizNotifyStepState extends State<_QuizNotifyStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hint('Earn points with quizzes and manage reminders'),
        const SizedBox(height: 10),

        _toggleRow(
          label: 'Join quizzes (earn points)',
          value: widget.data.wantsQuizzes,
          onChanged: (v) =>
              setState(() => widget.data.wantsQuizzes = v),
        ),

        const SizedBox(height: 12),

        _toggleRow(
          label: 'Receive notifications (bills/reminders)',
          value: widget.data.wantsNotifications,
          onChanged: (v) =>
              setState(() => widget.data.wantsNotifications = v),
        ),

        const Spacer(),
        _nextBtn('Next', widget.onNext),
      ],
    );
  }
}

class _FinishStep extends StatelessWidget {
  final SurveyData data;
  final VoidCallback onFinish;
  const _FinishStep({
    required this.data,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text(
          'Congratulations!',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: _fg,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Your setup is complete.\nReady to start your eco journey?',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 15,
            height: 1.4,
            color: _muted,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: Image.asset(
            'assets/images/outro.png',
            width: 260,
            fit: BoxFit.contain,
          ),
        ),

        const Spacer(),

        _nextBtn('Start EcoPath', onFinish),
      ],
    );
  }
}

/* -------------------- SHARED DARK UI HELPERS -------------------- */

Widget _nextBtn(String label, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _fg.withOpacity(.9), width: 1.4),
          foregroundColor: _fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
      ),
    );

Widget _hint(String s) => Text(
      s,
      style: GoogleFonts.lato(
        color: _muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );

Widget _label(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        s,
        style: GoogleFonts.lato(
          color: _fg,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

Widget _pill(String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: _fieldBg,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: _fg.withOpacity(.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.lato(
                      color: _fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Widget _chip(
  String label,
  bool isOn,
  VoidCallback onTap,
) =>
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isOn ? _fg.withOpacity(.12) : _fieldBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOn ? _fg : _border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: _fg,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

Widget _darkTextField({
  required TextEditingController controller,
  required String hint,
  TextInputType? keyboardType,
  VoidCallback? onDone,
}) =>
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction:
          onDone == null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: (_) => onDone?.call(),
      style: GoogleFonts.lato(
        color: _fg,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: _fg,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
          color: _muted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: _border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _fg.withOpacity(.9),
            width: 1.6,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

Widget _darkDropdown({
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: const Color(0xFF0F2E28),
        iconEnabledColor: _fg,
        style: GoogleFonts.lato(
          color: _fg,
        ),
        hint: Text(
          'Select',
          style: GoogleFonts.lato(
            color: _muted,
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );

Widget _toggleRow({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) =>
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: _fg,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _ink,
            activeTrackColor: _fg,
            inactiveThumbColor: _fg.withOpacity(.7),
            inactiveTrackColor: _fg.withOpacity(.3),
          ),
        ],
      ),
    );
