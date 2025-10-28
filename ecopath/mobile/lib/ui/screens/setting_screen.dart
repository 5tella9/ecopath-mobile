import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'termsofservice_screen.dart';
import 'privacypolicy_screen.dart';
import 'feedback_screen.dart';
import 'account_screen.dart'; // ← NEW IMPORT

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const dark = Color(0xFF00221C);
  static const cardBg = Color(0x33E2CECE); // #E2CECE @ 20%
  static const rowBg  = Color(0xFFF1EDED);
  static const divider = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    icon: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 28, height: 28,
                      semanticsLabel: 'Back',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 20),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: dark,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Card 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SettingsCard(children: [
                    _RowItem(
                      icon: 'assets/icons/account.svg',
                      label: 'Account',
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
                      icon: 'assets/icons/settingnoti.svg',
                      label: 'Notification',
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _RowItem(
                      icon: 'assets/icons/buyticket.svg',
                      label: 'Buy Tickets',
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _RowItem(
                      icon: 'assets/icons/mode.svg',
                      label: 'Mode',
                      onTap: () {},
                    ),
                  ]),
                ),

                const SizedBox(height: 32),

                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 14),
                  child: Text(
                    'Help & Feedback',
                    style: TextStyle(
                      color: dark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Card 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SettingsCard(children: [
                    _RowItem(
                      icon: 'assets/icons/helpcenter.svg',
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _RowItem(
                      icon: 'assets/icons/settingfeedback.svg',
                      label: 'Feedback',
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
                      label: 'Privacy Policy',
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
                      label: 'Terms of Service',
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SettingsScreen.cardBg,
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: SettingsScreen.divider,
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
    return Material(
      color: SettingsScreen.rowBg,
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
                colorFilter: const ColorFilter.mode(
                  SettingsScreen.dark,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: SettingsScreen.dark,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: SettingsScreen.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
