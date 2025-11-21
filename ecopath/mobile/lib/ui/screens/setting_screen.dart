// lib/ui/screens/setting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'mybag_screen.dart';
import 'termsofservice_screen.dart';
import 'privacypolicy_screen.dart';
import 'feedback_screen.dart';
import 'account_screen.dart';
import 'theme_screen.dart'; // Theme settings

import 'package:ecopath/theme/language_controller.dart';
import 'package:ecopath/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguageSheet(BuildContext context) {
    final langCtrl = context.read<LanguageController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        final textTheme = Theme.of(sheetCtx).textTheme;
        final l10n = AppLocalizations.of(sheetCtx)!;
        final currentCode = langCtrl.locale.languageCode;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.languageOption,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                value: 'en',
                groupValue: currentCode,
                title: Text(l10n.languageEnglish),
                onChanged: (value) {
                  langCtrl.setLocale(const Locale('en'));
                  Navigator.pop(sheetCtx);
                },
              ),
              RadioListTile<String>(
                value: 'ko',
                groupValue: currentCode,
                title: Text(l10n.languageKorean),
                onChanged: (value) {
                  langCtrl.setLocale(const Locale('ko'));
                  Navigator.pop(sheetCtx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // DYNAMIC BACKGROUND
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // Slight tint over background using surfaceVariant
            color: cs.surfaceVariant.withOpacity(0.12),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title row
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      // Back button like other pages (no back.svg)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.settingsTitle, // localized
                        style: textTheme.headlineMedium?.copyWith(
                          color: cs.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card 1 : Account / Premium / Theme / Language / My Plastic Bag
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SettingsCard(
                    children: [
                      _RowItem(
                        icon: 'assets/icons/account.svg',
                        label: l10n.account,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const AccountScreen(),
                            ),
                          );
                        },
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/premium.svg',
                        label: l10n.premium,
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/theme.svg',
                        label: l10n.theme,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const ThemeScreen(),
                            ),
                          );
                        },
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/language.svg',
                        label: l10n.languageOption,
                        onTap: () => _showLanguageSheet(context),
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/mybag.svg',
                        label: l10n.myPlasticBag,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const MyBagScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Help & Feedback title
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 14),
                  child: Text(
                    l10n.helpAndFeedback,
                    style: textTheme.titleMedium?.copyWith(
                      color: cs.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Card 2 : Help center / Feedback / Privacy Policy / Terms
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SettingsCard(
                    children: [
                      _RowItem(
                        icon: 'assets/icons/helpcenter.svg',
                        label: l10n.helpCenter,
                        onTap: () {},
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/settingfeedback.svg',
                        label: l10n.feedback,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const FeedbackScreen(),
                            ),
                          );
                        },
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/privacypolicy.svg',
                        label: l10n.privacyPolicy,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      const _RowDivider(),
                      _RowItem(
                        icon: 'assets/icons/termofservice.svg',
                        label: l10n.termsOfService,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServiceScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface, // dynamic card background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: cs.outlineVariant, // dynamic divider color
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _RowItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceVariant.withOpacity(0.65), // dynamic row background
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  cs.primary, // use primary color for icons
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontSize: 14,
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
    );
  }
}
