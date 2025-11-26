// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecopath/core/progress_tracker.dart';
import 'package:ecopath/core/recycle_history.dart';
import 'notifications_screen.dart';
import 'setting_screen.dart';
import 'edit_avatar_screen.dart';
import 'package:ecopath/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/userProvider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // NEW: picker + avatar file for camera/gallery
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;

  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;
  int _firstWeekdayOfMonth(DateTime d) =>
      DateTime(d.year, d.month, 1).weekday % 7;

  String get _monthLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void _prevMonth() => setState(
      () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  void _nextMonth() => setState(
      () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  // ===== Avatar picking helpers =====
  Future<void> _pickAvatarFromCamera() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _avatarFile = File(picked.path);
    });
    if (mounted) {
      Navigator.pop(context); // close bottom sheet
    }
  }

  Future<void> _pickAvatarFromGallery() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _avatarFile = File(picked.path);
    });
    if (mounted) {
      Navigator.pop(context); // close bottom sheet
    }
  }

  void _showAvatarActionSheet() {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: cs.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 1),
                ),
              ),
              child: Center(
                child: Text(
                  l10n.changeAvatarTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            _ActionSheetItem(
              text: l10n.changeAvatarTakePhoto,
              onTap: _pickAvatarFromCamera,
            ),
            _ActionSheetItem(
              text: l10n.changeAvatarChooseAlbum,
              onTap: _pickAvatarFromGallery,
            ),
            _ActionSheetItem(
              text: l10n.changeAvatarChooseCharacter,
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditAvatarScreen()),
                );
                setState(() {}); // refresh after coming back
              },
            ),
            const SizedBox(height: 8),
            _ActionSheetItem(
              isCancel: true,
              text: l10n.cancel,
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showRecycleInfo() {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: cs.scrim.withOpacity(0.4),
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.recycleInfoText,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.gotIt, style: TextStyle(color: cs.onPrimary)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDayInfo(int day, int points) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierColor: cs.scrim.withOpacity(0.4),
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_monthLabel.split(' ')[0]} $day, ${_focusedMonth.year}",
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.dayPointsMessagePrefix} $points ${l10n.dayPointsMessageSuffix}',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.gotIt, style: TextStyle(color: cs.onPrimary)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    setState(() {});
  }

  Future<void> _openSettings() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tracker = ProgressTracker.instance;
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Container(
          color: cs.surface,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top right icons
                Padding(
                  padding:
                      const EdgeInsets.only(top: 64, right: 18, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _HeaderIcon(
                        asset: 'assets/icons/bell.svg',
                        onTap: _openNotifications,
                        isBold: true,
                      ),
                      const SizedBox(width: 8),
                      _HeaderIcon(
                        asset: 'assets/icons/setting.svg',
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 29, bottom: 10),
                  child: Text(
                    l10n.profileTitle,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // avatar
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // background circle
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: user?.avatarBackground != null
                                    ? AssetImage(user!.avatarBackground!)
                                    : const AssetImage('assets/images/green.png'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.shadow.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          // avatar image (file > asset > default)
                          ClipOval(
                            child: _avatarFile != null
                                ? Image.file(
                                    _avatarFile!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : (user?.profileImage != null
                                    ? Image.asset(
                                        user!.profileImage!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        'assets/images/profileimg.png',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.contain,
                                      )),
                          ),

                          // edit button
                          Positioned(
                            right: -4,
                            top: -4,
                            child: GestureDetector(
                              onTap: _showAvatarActionSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.shadow.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '...',
                                  style: TextStyle(
                                    color: cs.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        user?.fullName ?? '',
                        style: TextStyle(color: cs.onSurface, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBlock(
                        value: tracker.totalPoints.toString(),
                        label: l10n.pointsEarnedLabel,
                      ),
                      _StatBlock(
                        value: tracker.progressDone.toString(),
                        label: l10n.progressDoneLabel,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // recycle history header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        l10n.recycleHistoryTitle,
                        style: TextStyle(
                            color: cs.onSurface, fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _showRecycleInfo,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '?',
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(8, 10, 8, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _prevMonth,
                              icon: Icon(
                                Icons.chevron_left,
                                color: cs.onSurface,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _monthLabel,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              icon: Icon(
                                Icons.chevron_right,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _Weekday(AppLocalizations.of(context)!.weekdayShortSun),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortMon),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortTue),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortWed),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortThu),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortFri),
                            _Weekday(AppLocalizations.of(context)!.weekdayShortSat),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildDaysGrid(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final history = RecycleHistory.instance;

    final firstWeekday = _firstWeekdayOfMonth(_focusedMonth);
    final totalDays = _daysInMonth(_focusedMonth);
    final today = DateTime.now();

    final leading = firstWeekday;
    final cells = leading + totalDays;
    final padded =
        (cells % 7 == 0) ? cells : cells + (7 - cells % 7);

    return Column(
      children: List.generate(padded ~/ 7, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > totalDays) {
                return const SizedBox(width: 32, height: 28);
              }

              final isToday = today.year == _focusedMonth.year &&
                  today.month == _focusedMonth.month &&
                  today.day == dayNum;

              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayNum);
              final recyclePoints = history.pointsFor(date);

              if (recyclePoints != null && recyclePoints > 0) {
                return GestureDetector(
                  onTap: () =>
                      _showDayInfo(dayNum, recyclePoints),
                  child: Image.asset(
                    'assets/images/recycle.png',
                    width: 22,
                    height: 22,
                  ),
                );
              }

              return Container(
                width: 32,
                height: 28,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: cs.primary, width: 1),
                      )
                    : null,
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                      color: cs.onSurface, fontSize: 13),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ======== Helper Widgets ========

class _HeaderIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final bool isBold;

  const _HeaderIcon({
    required this.asset,
    required this.onTap,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isBold)
                SvgPicture.asset(
                  asset,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    cs.onSurface.withOpacity(0.4),
                    BlendMode.srcIn,
                  ),
                ),
              SvgPicture.asset(
                asset,
                width: isBold ? 26 : 20,
                height: isBold ? 26 : 20,
                colorFilter:
                    ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheetItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isCancel;

  const _ActionSheetItem({
    required this.text,
    required this.onTap,
    this.isCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = isCancel ? cs.primary : cs.onSurface;

    return Material(
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCancel ? 16 : 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: isCancel
                  ? BorderSide.none
                  : BorderSide(
                      color: cs.outlineVariant, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isCancel ? 18 : 17,
                fontWeight:
                    isCancel ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: cs.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }
}

class _Weekday extends StatelessWidget {
  final String text;
  const _Weekday(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
