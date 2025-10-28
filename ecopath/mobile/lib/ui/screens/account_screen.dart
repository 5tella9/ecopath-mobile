import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  static const dark = Color(0xFF00221C);
  static const lightBg = Color(0xFFF5F5F5);
  static const cardBg = Color(0x33E2CECE); // same tone as Settings
  static const rowBg = Color(0xFFF1EDED);
  static const divider = Color(0xFFD9D9D9);
  static const danger = Color(0xFFE53935);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditing = false;

  // -------------------------
  // User data (example initial data)
  // Later you can inject from survey/sign-up provider.
  // -------------------------
  String _username = 'eco_snow';
  String _dob = '2003/07/15';
  String _fullAddress =
      'Sejong Univ Dorm 204, Gunja-dong, Gwangjin-gu, Seoul'; // coupang-style single line

  // sign-in info
  String _authProvider =
      'google'; // "google", "facebook", "instagram", "email"
  String _authAccount = 'snow@gmail.com';

  // -------------------------
  // Controllers for edit mode
  // -------------------------
  final _usernameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // username validation state
  String? _usernameStatusText; // null = not checked yet
  bool? _usernameIsValid; // null = not checked yet / unknown

  @override
  void initState() {
    super.initState();
    _syncControllersFromState();
  }

  void _syncControllersFromState() {
    _usernameCtrl.text = _username;
    _dobCtrl.text = _dob;
    _addressCtrl.text = _fullAddress;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // -------------------------
  // Edit toggle handlers
  // -------------------------
  void _onTapEdit() {
    setState(() {
      _isEditing = true;
      _usernameStatusText = null;
      _usernameIsValid = null;
      _syncControllersFromState();
    });
  }

  Future<void> _onTapDone() async {
    // Ask "Are you sure you want to save?"
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Are you sure you want to save?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AccountScreen.dark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Done",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      // user hit cancel → stay editing
      return;
    }

    // Save to state
    setState(() {
      _username = _usernameCtrl.text.trim();
      _dob = _dobCtrl.text.trim();
      _fullAddress = _addressCtrl.text.trim();
      _isEditing = false;
    });

    // Show success alert
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Successfully Saved!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AccountScreen.dark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "OK",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onTapDeleteAccount() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/alert.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Do you want to delete your account?\nIt will disappear permanently.",
                  style: TextStyle(
                    color: AccountScreen.dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "No",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Yes",
                style: TextStyle(
                  color: AccountScreen.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // -------------------------
  // DOB picker
  // -------------------------
  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final initial = _parseDobOrNow(_dobCtrl.text, now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );

    if (picked != null) {
      // format yyyy/mm/dd
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dobCtrl.text = "$y/$m/$d";
      });
    }
  }

  DateTime _parseDobOrNow(String txt, DateTime fallback) {
    // Expect yyyy/mm/dd
    try {
      final parts = txt.split('/');
      if (parts.length == 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        return DateTime(y, m, d);
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  // -------------------------
  // Username uniqueness check
  // -------------------------
  void _checkUsernameUnique(String value) {
    // Example "taken list". Replace with backend check later.
    const takenUsernames = [
      'eco_snow',
      'ecopath_user',
      'admin',
    ];

    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) {
      setState(() {
        _usernameIsValid = null;
        _usernameStatusText = null;
      });
      return;
    }

    final isTaken = takenUsernames.contains(cleaned);
    setState(() {
      if (isTaken) {
        _usernameIsValid = false;
        _usernameStatusText = "username is already taken";
      } else {
        _usernameIsValid = true;
        _usernameStatusText = "username is valid to use";
      }
    });
  }

  // -------------------------
  // UI helpers
  // -------------------------

  Widget _buildHeaderBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        children: [
          // back → profile_screen.dart (previous page)
          IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            icon: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 28,
              height: 28,
              semanticsLabel: 'Back',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              'Account Setting',
              style: TextStyle(
                color: AccountScreen.dark,
                fontSize: 22, // smaller font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (!_isEditing)
            TextButton(
              onPressed: _onTapEdit,
              child: Text(
                "Edit",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _onTapDone,
              child: Text(
                "Done",
                style: TextStyle(
                  color: AccountScreen.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AccountScreen.dark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Username row (with unique check message in edit mode)
  Widget _infoRowUsername() {
    final labelStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final valueStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    if (_isEditing) {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username", style: labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _usernameCtrl,
              style: valueStyle,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
              ),
              onChanged: _checkUsernameUnique,
            ),
            if (_usernameStatusText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _usernameStatusText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _usernameIsValid == true
                        ? Colors.green
                        : (_usernameIsValid == false
                            ? Colors.red
                            : AccountScreen.dark),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username", style: labelStyle),
            const SizedBox(height: 4),
            Text(_username, style: valueStyle),
          ],
        ),
      );
    }
  }

  // Date of Birth row (with text field + calendar in edit mode)
  Widget _infoRowDob() {
    final labelStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final valueStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    if (_isEditing) {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date of Birth (yyyy/mm/dd)", style: labelStyle),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dobCtrl,
                    style: valueStyle,
                    decoration: const InputDecoration(
                      hintText: "yyyy/mm/dd",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AccountScreen.dark,
                  ),
                  onPressed: _openDatePicker,
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date of Birth (yyyy/mm/dd)", style: labelStyle),
            const SizedBox(height: 4),
            Text(_dob, style: valueStyle),
          ],
        ),
      );
    }
  }

  // Address row (single full address string)
  Widget _infoRowAddress() {
    final labelStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final valueStyle = TextStyle(
      color: AccountScreen.dark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    if (_isEditing) {
      // Coupang-style editable address: just multi-line text field
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address", style: labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _addressCtrl,
              maxLines: 3,
              style: valueStyle,
              decoration: const InputDecoration(
                hintText: "Edit your delivery address",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      );
    } else {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address", style: labelStyle),
            const SizedBox(height: 4),
            Text(
              _fullAddress,
              style: valueStyle,
            ),
          ],
        ),
      );
    }
  }

  // Sign-in method row (icon + provider + account email/id)
  Widget _signInMethodRow() {
    String label;
    String assetPath;
    switch (_authProvider) {
      case 'google':
        label = 'Google';
        assetPath = 'assets/icons/google.svg';
        break;
      case 'facebook':
        label = 'Facebook';
        assetPath = 'assets/icons/fb.svg';
        break;
      case 'instagram':
        label = 'Instagram';
        assetPath = 'assets/icons/insta.svg';
        break;
      case 'email':
      default:
        label = 'Email';
        assetPath = 'assets/icons/mailb.svg';
        break;
    }

    return _LinedRow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sign-in Method",
            style: TextStyle(
              color: AccountScreen.dark,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                assetPath,
                width: 20,
                height: 20,
                // keep provider brand color (no colorFilter)
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "$label  ($_authAccount)",
                  style: TextStyle(
                    color: AccountScreen.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AccountScreen.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Username
            _infoRowUsername(),

            const _InnerDivider(),

            // DOB
            _infoRowDob(),

            const _InnerDivider(),

            // Address (full string)
            _infoRowAddress(),

            const _InnerDivider(),

            // Sign-in method (read only)
            _signInMethodRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: GestureDetector(
        onTap: _onTapDeleteAccount,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AccountScreen.danger, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "Delete Account",
              style: TextStyle(
                color: AccountScreen.danger,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  // build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccountScreen.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // align section left
            children: [
              _buildHeaderBar(context),

              _sectionTitle("Your Info"),

              _buildMainCard(),

              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- helper widgets ---------- */

class _InnerDivider extends StatelessWidget {
  const _InnerDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AccountScreen.divider,
      ),
    );
  }
}

class _LinedRow extends StatelessWidget {
  final Widget child;
  const _LinedRow({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AccountScreen.rowBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }
}
