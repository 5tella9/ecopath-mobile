import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditing = false;

  String _username = 'eco_snow';
  String _dob = '2003/07/15';
  String _fullAddress =
      'Sejong Univ Dorm 204, Gunja-dong, Gwangjin-gu, Seoul';

  String _authProvider = 'google';
  String _authAccount = 'snow@gmail.com';

  final _usernameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _usernameStatusText;
  bool? _usernameIsValid;

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

  void _onTapEdit() {
    setState(() {
      _isEditing = true;
      _usernameStatusText = null;
      _usernameIsValid = null;
      _syncControllersFromState();
    });
  }

  Future<void> _onTapDone() async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("Cancel", style: TextStyle(color: cs.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Done",
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _username = _usernameCtrl.text.trim();
      _dob = _dobCtrl.text.trim();
      _fullAddress = _addressCtrl.text.trim();
      _isEditing = false;
    });

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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "OK",
                style: TextStyle(
                  color: cs.primary,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("No", style: TextStyle(color: cs.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                "Yes",
                style: TextStyle(
                  color: theme.colorScheme.error,
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
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dobCtrl.text = "$y/$m/$d";
      });
    }
  }

  DateTime _parseDobOrNow(String txt, DateTime fallback) {
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

  void _checkUsernameUnique(String value) {
    const takenUsernames = ['eco_snow', 'ecopath_user', 'admin'];
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

  Widget _buildHeaderBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Account Setting',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _isEditing ? _onTapDone : _onTapEdit,
            child: Text(
              _isEditing ? "Done" : "Edit",
              style: TextStyle(
                color: cs.primary,
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRowUsername() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurface,
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
                            : cs.onSurface),
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

  Widget _infoRowDob() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500);

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
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.calendar_today_outlined, size: 20, color: cs.primary),
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

  Widget _infoRowAddress() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500);

    if (_isEditing) {
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
            Text(_fullAddress, style: valueStyle),
          ],
        ),
      );
    }
  }

  Widget _signInMethodRow() {
    final cs = Theme.of(context).colorScheme;
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
      default:
        label = 'Email';
        assetPath = 'assets/icons/mailb.svg';
        break;
    }

    return _LinedRow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sign-in Method", style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(assetPath, width: 20, height: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "$label  ($_authAccount)",
                  style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _infoRowUsername(),
            const _InnerDivider(),
            _infoRowDob(),
            const _InnerDivider(),
            _infoRowAddress(),
            const _InnerDivider(),
            _signInMethodRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: GestureDetector(
        onTap: _onTapDeleteAccount,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.error, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              "Delete Account",
              style: TextStyle(color: cs.error, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
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
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }
}
