
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ecopath/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/language_controller.dart';
import 'core/notification_service.dart';

import 'ui/root_shell.dart';
// import 'ui/screens/intro_screen.dart'; // ❌ not used as home anymore
import 'ui/screens/survey_flow.dart';
import 'ui/screens/intro_loading_screen.dart';
import 'ui/screens/signup_screen.dart'; // ✅ new home

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Theme
  final themeController = ThemeController();
  await themeController.load();

  // Language
  final languageController = LanguageController();
  await languageController.load();

  // (If you still use timezone + notifications somewhere, keep these)
  tz.initializeTimeZones();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: languageController),
      ],
      child: const EcoPathRoot(),
    ),
  );
}

class EcoPathRoot extends StatelessWidget {
  const EcoPathRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final langCtrl = context.watch<LanguageController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // *********** LOCALIZATION SETTINGS ***********
      locale: langCtrl.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      // **********************************************

      theme: AppTheme.themeOf(themeCtrl.themeId, dark: themeCtrl.isDark),

      // ⬅️ NEW USER FLOW STARTS HERE
      // When app opens (for now) → SignUpScreen first
      home: const SignUpScreen(),

      onGenerateRoute: (settings) {
        if (settings.name == '/root') {
          final arg = settings.arguments;
          final int initialIndex = (arg is int) ? arg : 0;
          return MaterialPageRoute(
            builder: (_) => RootShell(initialIndex: initialIndex),
            settings: settings,
          );
        }
        if (settings.name == '/survey') {
          return MaterialPageRoute(
            builder: (_) => const SurveyFlow(),
            settings: settings,
          );
        }
        if (settings.name == '/intro-loading') {
          return MaterialPageRoute(
            builder: (_) => const IntroLoadingScreen(),
            settings: settings,
          );
        }
        if (settings.name == '/signup') {
          return MaterialPageRoute(
            builder: (_) => const SignUpScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
