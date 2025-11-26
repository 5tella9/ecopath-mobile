import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ecopath/l10n/app_localizations.dart';
import '../../providers/userProvider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

/* ------------ internal address models for bilingual JSON ------------ */

class _DistrictData {
  final String id;
  final String en;
  final String ko;

  const _DistrictData({
    required this.id,
    required this.en,
    required this.ko,
  });
}

class _RegionData {
  final String id;
  final String en;
  final String ko;
  final List<_DistrictData> districts;

  const _RegionData({
    required this.id,
    required this.en,
    required this.ko,
    required this.districts,
  });
}

class _AddressSelection {
  final String regionId;
  final String districtId;
  final String detail;

  const _AddressSelection({
    required this.regionId,
    required this.districtId,
    required this.detail,
  });
}

class _AccountScreenState extends State<AccountScreen> {
  String _username = '';
  String _dob = '';
  String _fullAddress = '';
  String _email = '';

  bool _isEditing = false;

  final _usernameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _usernameStatusText;
  bool? _usernameIsValid;

  // new address state
  List<_RegionData> _regionsData = [];
  String? _regionId;   // region id from JSON
  String? _districtId; // district id from JSON
  String _detailText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;

      if (user != null) {
        setState(() {
          _username = user.fullName ?? '';
          _dob = user.birthDate ?? '';
          _fullAddress = user.location?.city ?? '';
          _email = user.email ?? '';
        });
        _syncControllersFromState();
      }
    });
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

  // --------------------------------------------------
  // LOAD FULL KOREA ADDRESS DATA FROM JSON (NEW FORMAT)
  // --------------------------------------------------
  Future<void> _ensureAddressDataLoaded() async {
    if (_regionsData.isNotEmpty) return;

    final jsonStr = await rootBundle.loadString('assets/data/kr_address.json');
    final Map<String, dynamic> raw =
        json.decode(jsonStr) as Map<String, dynamic>;
    final List<dynamic> regionsRaw =
        (raw['regions'] as List<dynamic>? ?? <dynamic>[]);

    final list = <_RegionData>[];

    for (final r in regionsRaw) {
      final rm = r as Map<String, dynamic>;
      final id = rm['id'] as String;
      final en = rm['en'] as String;
      final ko = rm['ko'] as String;
      final districtsRaw = rm['districts'] as List<dynamic>? ?? <dynamic>[];

      final districts = <_DistrictData>[];
      for (final d in districtsRaw) {
        final dm = d as Map<String, dynamic>;
        districts.add(
          _DistrictData(
            id: dm['id'] as String,
            en: dm['en'] as String,
            ko: dm['ko'] as String,
          ),
        );
      }

      list.add(
        _RegionData(
          id: id,
          en: en,
          ko: ko,
          districts: districts,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _regionsData = list;
    });
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
    final loc = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.accountConfirmSaveTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.accountConfirmSaveCancel,
                  style: TextStyle(color: cs.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.accountConfirmSaveDone,
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
      _fullAddress = _buildAddressDisplay(context);
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
            loc.accountSavedTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.ok,
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
    final loc = AppLocalizations.of(context)!;

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
                  loc.accountDeleteDialogTitle,
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
              child:
                  Text(loc.accountDeleteNo, style: TextStyle(color: cs.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                loc.accountDeleteYes,
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

  Future<void> _onTapLogout() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.logout();

    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/login', (route) => false);
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
    final loc = AppLocalizations.of(context)!;
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
        _usernameStatusText = loc.accountUsernameTaken;
      } else {
        _usernameIsValid = true;
        _usernameStatusText = loc.accountUsernameValid;
      }
    });
  }

  // --------------------------------------------------
  // BILINGUAL ADDRESS PICKER
  // --------------------------------------------------

  String _regionLabel(_RegionData r, Locale locale) {
    return locale.languageCode == 'ko' ? r.ko : r.en;
  }

  String _districtLabel(_DistrictData d, Locale locale) {
    return locale.languageCode == 'ko' ? d.ko : d.en;
  }

  String _buildAddressDisplay(BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (_regionId != null && _regionsData.isNotEmpty) {
      _RegionData? region;
      _DistrictData? district;

      for (final r in _regionsData) {
        if (r.id == _regionId) {
          region = r;
          break;
        }
      }
      if (region != null && _districtId != null) {
        for (final d in region.districts) {
          if (d.id == _districtId) {
            district = d;
            break;
          }
        }
      }

      final parts = <String>[];
      if (region != null) parts.add(_regionLabel(region, locale));
      if (district != null) parts.add(_districtLabel(district, locale));
      if (_detailText.isNotEmpty) parts.add(_detailText);

      if (parts.isNotEmpty) {
        return parts.join(' ');
      }
    }

    return _fullAddress;
  }

  Future<void> _pickAddressLikeSurvey() async {
    await _ensureAddressDataLoaded();
    if (!mounted || _regionsData.isEmpty) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final regions = _regionsData;

    final result = await showModalBottomSheet<_AddressSelection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        _RegionData? selectedRegion;
        _DistrictData? selectedDistrict;
        final detailCtrl = TextEditingController(text: _detailText);

        if (_regionId != null) {
          for (final r in regions) {
            if (r.id == _regionId) {
              selectedRegion = r;
              break;
            }
          }
        }
        if (selectedRegion != null && _districtId != null) {
          for (final d in selectedRegion.districts) {
            if (d.id == _districtId) {
              selectedDistrict = d;
              break;
            }
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              final cityOptions =
                  selectedRegion?.districts ?? const <_DistrictData>[];

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cs.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      loc.accountAddressSelectTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedRegion?.id,
                      decoration: InputDecoration(
                        labelText: loc.accountAddressSidoLabel,
                      ),
                      items: regions
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(_regionLabel(r, locale)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedRegion =
                              regions.firstWhere((r) => r.id == value);
                          selectedDistrict = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedDistrict?.id,
                      decoration: InputDecoration(
                        labelText: loc.accountAddressCityLabel,
                      ),
                      items: cityOptions
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(_districtLabel(d, locale)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedDistrict =
                              cityOptions.firstWhere((d) => d.id == value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: detailCtrl,
                      decoration: InputDecoration(
                        labelText: loc.accountAddressDetailLabel,
                        hintText: loc.accountAddressDetailHint,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedRegion == null ||
                                selectedDistrict == null)
                            ? null
                            : () {
                                Navigator.pop(
                                  ctx,
                                  _AddressSelection(
                                    regionId: selectedRegion!.id,
                                    districtId: selectedDistrict!.id,
                                    detail: detailCtrl.text.trim(),
                                  ),
                                );
                              },
                        child: Text(loc.accountAddressApply),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _regionId = result.regionId;
        _districtId = result.districtId;
        _detailText = result.detail;
        _fullAddress = _buildAddressDisplay(context);
        _addressCtrl.text = _fullAddress;
      });
    }
  }

  // --------------------------------------------------
  // UI BUILDERS
  // --------------------------------------------------

  Widget _buildHeaderBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Row(
        children: [
          IconButton(
           
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: cs.onSurface,
                          ),
                        ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              loc.accountSettingTitle,
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
              _isEditing ? loc.accountDone : loc.accountEdit,
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
    final loc = AppLocalizations.of(context)!;

    final labelStyle =
        theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurface,
      fontWeight: FontWeight.w500,
    );

    if (_isEditing) {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.accountFieldUsername, style: labelStyle),
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
            Text(loc.accountFieldUsername, style: labelStyle),
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
    final loc = AppLocalizations.of(context)!;

    final labelStyle =
        theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final valueStyle = theme.textTheme.bodyMedium
        ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500);

    if (_isEditing) {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.accountFieldDob, style: labelStyle),
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
                  icon: Icon(Icons.calendar_today_outlined,
                      size: 20, color: cs.primary),
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
            Text(loc.accountFieldDob, style: labelStyle),
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
    final loc = AppLocalizations.of(context)!;

    final labelStyle =
        theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final valueStyle = theme.textTheme.bodyMedium
        ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500);

    final displayAddress = _buildAddressDisplay(context);

    if (_isEditing) {
      return _LinedRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.accountFieldAddress, style: labelStyle),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _pickAddressLikeSurvey,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayAddress.isEmpty
                            ? loc.accountAddressTapToSelect
                            : displayAddress,
                        style: valueStyle?.copyWith(
                          color: displayAddress.isEmpty
                              ? (valueStyle?.color ?? cs.onSurface)
                                  .withOpacity(0.5)
                              : cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
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
            Text(loc.accountFieldAddress, style: labelStyle),
            const SizedBox(height: 4),
            Text(displayAddress, style: valueStyle),
          ],
        ),
      );
    }
  }

  Widget _buildMainCard() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
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
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: GestureDetector(
        onTap: _onTapLogout,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              loc.accountLogout,
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
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
              loc.accountDelete,
              style: TextStyle(
                color: cs.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // keep listening for user changes even if not used directly
    context.watch<UserProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(context),
              _sectionTitle(loc.accountYourInfoTitle),
              _buildMainCard(),
              _buildLogoutButton(),
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
