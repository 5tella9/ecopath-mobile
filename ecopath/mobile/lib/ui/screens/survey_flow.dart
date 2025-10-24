// lib/ui/screens/survey_flow.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

/* -------------------- MODEL -------------------- */
class SurveyData {
  String name = '';
  int? age;
  String gender = '';

  // Korean-style address (English labels)
  String sido = '';     // Province/Metro City
  String sigungu = '';  // City/District
  String dong = '';     // Neighborhood
  String detail = '';   // Detailed address

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
}

/* -------------------- COLORS -------------------- */
const _ink = Color(0xFF00221C);     // base green
const _fg  = Color(0xFFF5F5F5);     // text color
const _muted = Color(0xCCF5F5F5);   // hint / muted text
const _fieldBg = Color(0x14FFFFFF); // input bg on dark
const _border = Color(0x33FFFFFF);  // input border

LinearGradient _bgGradient() => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF00221C),
    Color(0xFF0C3A2F),
    Color(0xFF145243),
  ],
);

/* -------------------- SCREEN -------------------- */
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

  // Flow order (with 3 interstitial pages):
  // 0 WelcomeInterstitial
  // 1 Name
  // 2 Age
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
      () => _WelcomePage(onNext: _next), // NEW: first page after Intro
      () => _NameStep(data: data, onNext: _next),
      () => _AgeStep(data: data, onNext: _next),
      () => _GenderStep(data: data, onNext: _next),
      () => _AddressStep(data: data, onNext: _next, getMap: () => _sidoSigungu, loading: _loadingAddr),
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
      () => _EnergyPlanStep(data: data, onNext: _next),
      () => _QuizNotifyStep(data: data, onNext: _next),
      () => _FinishStep(
            data: data,
            onFinish: () => Navigator.of(context).pushReplacementNamed('/root'),
          ),
    ];
    _loadAddressJson();
  }

  Future<void> _loadAddressJson() async {
    try {
      final raw = await rootBundle.loadString('assets/data/kr_address.json');
      final Map<String, dynamic> m = json.decode(raw);
      _sidoSigungu = m.map((k, v) => MapEntry(k, List<String>.from(v)));
    } catch (_) {
      _sidoSigungu = {};
    } finally {
      if (mounted) setState(() => _loadingAddr = false);
    }
  }

  void _next() => setState(() => index = (index + 1).clamp(0, _steps.length - 1));
  void _back() => setState(() => index = (index - 1).clamp(0, _steps.length - 1));

  bool get _isInterstitial => index == 0 || index == 5 || index == 9;

  @override
  Widget build(BuildContext context) {
    final titles = [
      '', // 0 welcome (no title bar)
      'What is your name?',
      'How old are you?',
      'What is your gender?',
      'Enter your address',
      '', // 5 interstitial (no title bar)
      'What type of house do you live in?',
      'How many people do you share the house with?',
      'Your eco goals',
      '', // 9 interstitial (no title bar)
      'Energy bills & providers',
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
              // Top bar with back and app name (skip for interstitials)
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
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _fg.withOpacity(.6)),
                            ),
                            child: Icon(Icons.arrow_back, color: _fg, size: 20),
                          ),
                        )
                      else
                        const SizedBox(width: 40, height: 40),
                      const Spacer(),
                      Text('EcoPath',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: _fg,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          )),
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

              // Content (no white card; directly on gradient)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim);
                    return FadeTransition(opacity: anim, child: SlideTransition(position: slide, child: child));
                  },
                  child: Padding(
                    key: ValueKey(index),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: _steps[index](),
                  ),
                ),
              ),

              // Progress
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
// Layout requirement:
// - Two texts ABOVE the png; everything centered.
// - Transition order: 1) PNG appears, 2) texts appear, 3) Next button appears.
//   (We keep texts above in layout but delay their animation to come after the image.)
class _WelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fadeImg;
  late final Animation<Offset> _slideImg;
  late final Animation<double> _fadeText;
  late final Animation<Offset> _slideText;
  late final Animation<double> _fadeBtn;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

    // 1) Image first
    _fadeImg  = CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.45, curve: Curves.easeOut));
    _slideImg = Tween<Offset>(begin: const Offset(0, .10), end: Offset.zero).animate(
      CurvedAnimation(parent: _ac, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)),
    );

    // 2) Texts second
    _fadeText  = CurvedAnimation(parent: _ac, curve: const Interval(0.35, 0.8, curve: Curves.easeOut));
    _slideText = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero).animate(
      CurvedAnimation(parent: _ac, curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic)),
    );

    // 3) Button last
    _fadeBtn = CurvedAnimation(parent: _ac, curve: const Interval(0.75, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We keep texts above the image in layout, but their animation starts AFTER the image.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Texts
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
          // Image
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
          // Button
          FadeTransition(
            opacity: _fadeBtn,
            child: _nextBtn('Next', widget.onNext),
          ),
        ],
      ),
    );
  }
}

/* -------------------- INTERSTITIAL PAGE (GENERIC) -------------------- */
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

class _InterstitialPageState extends State<_InterstitialPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fadeText;
  late final Animation<Offset> _slideText;
  late final Animation<double> _fadeImg;
  late final Animation<Offset> _slideImg;
  late final Animation<double> _fadeBtn;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fadeText = CurvedAnimation(parent: _ac, curve: const Interval(0.0, .45, curve: Curves.easeOut));
    _slideText = Tween<Offset>(begin: const Offset(0, .1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ac, curve: const Interval(0.0, .45, curve: Curves.easeOutCubic)),
    );
    _fadeImg = CurvedAnimation(parent: _ac, curve: const Interval(.25, .75, curve: Curves.easeOut));
    _slideImg = Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ac, curve: const Interval(.25, .75, curve: Curves.easeOutCubic)),
    );
    _fadeBtn = CurvedAnimation(parent: _ac, curve: const Interval(.7, 1, curve: Curves.easeOut));
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

/* -------------------- SURVEY STEPS -------------------- */

class _NameStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  const _NameStep({required this.data, required this.onNext});
  @override State<_NameStep> createState() => _NameStepState();
}
class _NameStepState extends State<_NameStep> {
  final _ctl = TextEditingController();
  @override void initState(){ super.initState(); _ctl.text = widget.data.name; }
  @override void dispose(){ _ctl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Enter your real name or nickname'),
      const SizedBox(height: 10),
      _darkTextField(controller: _ctl, hint: 'e.g., Minji Kim ', onDone: _go),
      const Spacer(),
      _nextBtn('Next', _go),
    ]);
  }
  void _go(){ widget.data.name = _ctl.text.trim(); widget.onNext(); }
}

class _AgeStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  const _AgeStep({required this.data, required this.onNext});
  @override State<_AgeStep> createState() => _AgeStepState();
}
class _AgeStepState extends State<_AgeStep> {
  final _ctl = TextEditingController();
  @override void initState(){ super.initState(); _ctl.text = widget.data.age?.toString() ?? ''; }
  @override void dispose(){ _ctl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Enter your age'),
      const SizedBox(height: 10),
      _darkTextField(
        controller: _ctl,
        hint: 'e.g., 24',
        keyboardType: TextInputType.number,
        onDone: _go,
      ),
      const Spacer(),
      _nextBtn('Next', _go),
    ]);
  }
  void _go(){ widget.data.age = int.tryParse(_ctl.text.trim()); widget.onNext(); }
}

class _GenderStep extends StatelessWidget {
  final SurveyData data; final VoidCallback onNext;
  const _GenderStep({required this.data, required this.onNext});
  @override Widget build(BuildContext context){
    final options = ['Female','Male','Non-binary','Prefer not to say'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Choose one'),
      const SizedBox(height: 10),
      ...options.map((o) => _pill(o, (){ data.gender = o; onNext(); })),
      const Spacer(),
    ]);
  }
}

class _AddressStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  final Map<String, List<String>> Function() getMap;
  final bool loading;
  const _AddressStep({
    required this.data,
    required this.onNext,
    required this.getMap,
    required this.loading,
  });
  @override State<_AddressStep> createState() => _AddressStepState();
}
class _AddressStepState extends State<_AddressStep> {
  String? _sido; String? _sigungu;
  final _dongCtl = TextEditingController(); final _detailCtl = TextEditingController();

  @override void initState(){
    super.initState();
    _sido = widget.data.sido.isEmpty ? null : widget.data.sido;
    _sigungu = widget.data.sigungu.isEmpty ? null : widget.data.sigungu;
    _dongCtl.text = widget.data.dong; _detailCtl.text = widget.data.detail;
  }
  @override void dispose(){ _dongCtl.dispose(); _detailCtl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context){
    if (widget.loading) return const Center(child: CircularProgressIndicator(color: _fg));
    final map = widget.getMap();
    final sidos = map.keys.toList()..sort();
    final sigungus = (_sido == null) ? <String>[] : (map[_sido] ?? []);

    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Korean address format'),
      const SizedBox(height: 10),
      _label('Province / Metropolitan City (시/도)'),
      _darkDropdown(value: _sido, items: sidos, onChanged: (v){ setState((){ _sido=v; _sigungu=null; }); }),
      const SizedBox(height: 12),
      _label('City / District (시/군/구)'),
      _darkDropdown(value: _sigungu, items: sigungus, onChanged: (v){ setState((){ _sigungu=v; }); }),
      const SizedBox(height: 12),
      _label('Neighborhood (동/읍/면)'),
      _darkTextField(controller: _dongCtl, hint: 'e.g., Yeoksam-dong'),
      const SizedBox(height: 12),
      _label('Detailed address'),
      _darkTextField(controller: _detailCtl, hint: 'e.g., 123-45, #101', onDone: _go),
      const SizedBox(height: 16),
      _nextBtn('Next', _go),
    ]));
  }

  void _go(){
    widget.data.sido = _sido ?? '';
    widget.data.sigungu = _sigungu ?? '';
    widget.data.dong = _dongCtl.text.trim();
    widget.data.detail = _detailCtl.text.trim();
    widget.onNext();
  }
}

class _HouseTypeStep extends StatelessWidget {
  final SurveyData data; final VoidCallback onNext;
  const _HouseTypeStep({required this.data, required this.onNext});
  @override Widget build(BuildContext context){
    final options = ['Apartment','House','One-room (studio)','Shared house','Other'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Select one'),
      const SizedBox(height: 10),
      ...options.map((o) => _pill(o, (){ data.houseType = o; onNext(); })),
      const Spacer(),
    ]);
  }
}

class _LivingWithStep extends StatelessWidget {
  final SurveyData data; final VoidCallback onNext;
  const _LivingWithStep({required this.data, required this.onNext});
  @override Widget build(BuildContext context){
    final options = ['Parents','Siblings','Friends','Relatives','Spouse/Partner','Alone'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Select one'),
      const SizedBox(height: 10),
      ...options.map((o) => _pill(o, (){ data.livingWith = o; onNext(); })),
      const Spacer(),
    ]);
  }
}

class _GoalsStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  const _GoalsStep({required this.data, required this.onNext});
  @override State<_GoalsStep> createState() => _GoalsStepState();
}
class _GoalsStepState extends State<_GoalsStep> {
  final goals = ['Reduce electricity use','Reduce gas use','Recycle more','Cut food waste','Use public transit more'];
  final selected = <String>{};
  @override void initState(){ super.initState(); selected.addAll(widget.data.ecoGoals); }
  @override Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Choose your eco goals (multiple selections allowed)'),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10, runSpacing: 10,
        children: goals.map((g){
          final on = selected.contains(g);
          return _chip(g, on, (){
            setState(()=> on ? selected.remove(g) : selected.add(g));
          });
        }).toList(),
      ),
      const Spacer(),
      _nextBtn('Next', (){
        widget.data.ecoGoals = selected.toList();
        widget.onNext();
      }),
    ]);
  }
}

class _EnergyPlanStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  const _EnergyPlanStep({required this.data, required this.onNext});
  @override State<_EnergyPlanStep> createState() => _EnergyPlanStepState();
}
class _EnergyPlanStepState extends State<_EnergyPlanStep> {
  final _elecCtl = TextEditingController(); final _gasCtl = TextEditingController();
  @override void initState(){ super.initState(); _elecCtl.text = widget.data.electricProvider; _gasCtl.text = widget.data.gasProvider; }
  @override void dispose(){ _elecCtl.dispose(); _gasCtl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context){
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Set up bill linking and points deduction preferences'),
      const SizedBox(height: 10),
      _toggleRow(label: 'Use electricity bill features', value: widget.data.hasElectricBill, onChanged: (v)=>setState(()=>widget.data.hasElectricBill=v)),
      if (widget.data.hasElectricBill) ...[
        const SizedBox(height: 8),
        _label('Electricity provider'),
        _darkTextField(controller: _elecCtl, hint: 'e.g., KEPCO (한국전력)'),
      ],
      const SizedBox(height: 12),
      _toggleRow(label: 'Use gas bill features', value: widget.data.hasGasBill, onChanged: (v)=>setState(()=>widget.data.hasGasBill=v)),
      if (widget.data.hasGasBill) ...[
        const SizedBox(height: 8),
        _label('Gas provider'),
        _darkTextField(controller: _gasCtl, hint: 'e.g., City Gas ○○', onDone: _go),
      ],
      const SizedBox(height: 16),
      _nextBtn('Next', _go),
    ]));
  }
  void _go(){
    widget.data.electricProvider = _elecCtl.text.trim();
    widget.data.gasProvider = _gasCtl.text.trim();
    widget.onNext();
  }
}

class _QuizNotifyStep extends StatefulWidget {
  final SurveyData data; final VoidCallback onNext;
  const _QuizNotifyStep({required this.data, required this.onNext});
  @override State<_QuizNotifyStep> createState() => _QuizNotifyStepState();
}
class _QuizNotifyStepState extends State<_QuizNotifyStep> {
  @override Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _hint('Earn points with quizzes and manage reminders'),
      const SizedBox(height: 10),
      _toggleRow(label: 'Join quizzes (earn points)', value: widget.data.wantsQuizzes, onChanged: (v)=>setState(()=>widget.data.wantsQuizzes=v)),
      const SizedBox(height: 12),
      _toggleRow(label: 'Receive notifications (bills/reminders)', value: widget.data.wantsNotifications, onChanged: (v)=>setState(()=>widget.data.wantsNotifications=v)),
      const Spacer(),
      _nextBtn('Next', widget.onNext),
    ]);
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

        // Title
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

        // Subtext
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

        // PNG image (girl)
        Center(
          child: Image.asset(
            'assets/images/outro.png',
            width: 260,
            fit: BoxFit.contain,
          ),
        ),

        const Spacer(),

        // Button
        _nextBtn('Start EcoPath', onFinish),
      ],
    );
  }
}

/* -------------------- DARK UI HELPERS -------------------- */

Widget _nextBtn(String label, VoidCallback onTap)=>SizedBox(
  width: double.infinity,
  child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: _fg.withOpacity(.9), width: 1.4),
      foregroundColor: _fg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    onPressed: onTap,
    child: Text(label, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .2)),
  ),
);

Widget _hint(String s)=>Text(
  s,
  style: GoogleFonts.lato(color: _muted, fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
);

Widget _label(String s)=>Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(s, style: GoogleFonts.lato(color: _fg, fontSize: 14, fontWeight: FontWeight.w900)),
);

Widget _pill(String label, VoidCallback onTap)=>Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Ink(
      decoration: BoxDecoration(
        color: _fieldBg,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: _fg.withOpacity(.9)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: GoogleFonts.lato(color: _fg, fontSize: 16, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    ),
  ),
);

Widget _chip(String label, bool isOn, VoidCallback onTap)=>InkWell(
  onTap: onTap, borderRadius: BorderRadius.circular(20),
  child: Ink(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: isOn ? _fg.withOpacity(.12) : _fieldBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isOn ? _fg : _border),
    ),
    child: Text(label, style: GoogleFonts.lato(color: _fg, fontSize: 14, fontWeight: FontWeight.w800)),
  ),
);

Widget _darkTextField({
  required TextEditingController controller,
  required String hint,
  TextInputType? keyboardType,
  VoidCallback? onDone,
}) => TextField(
  controller: controller,
  keyboardType: keyboardType,
  textInputAction: onDone == null ? TextInputAction.next : TextInputAction.done,
  onSubmitted: (_) => onDone?.call(),
  style: GoogleFonts.lato(color: _fg, fontSize: 16, fontWeight: FontWeight.w700),
  cursorColor: _fg,
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.lato(color: _muted, fontSize: 14),
    filled: true,
    fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _border),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _fg.withOpacity(.9), width: 1.6),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);

Widget _darkDropdown({
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12),
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
    style: GoogleFonts.lato(color: _fg),
    hint: Text('Select', style: GoogleFonts.lato(color: _muted)),
    items: items.map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: onChanged,
  ),
);

Widget _toggleRow({required String label, required bool value, required ValueChanged<bool> onChanged})=>Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  decoration: BoxDecoration(
    color: _fieldBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
  ),
  child: Row(
    children: [
      Expanded(child: Text(label, style: GoogleFonts.lato(color: _fg, fontSize: 14, fontWeight: FontWeight.w900))),
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
