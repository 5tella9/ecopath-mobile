import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'ui/root_shell.dart';
import 'ui/screens/intro_screen.dart';
import 'ui/screens/survey_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load(); // restore saved theme before building

  runApp(
    ChangeNotifierProvider.value(
      value: themeController,
      child: const EcoPathRoot(),
    ),
  );
}

class EcoPathRoot extends StatelessWidget {
  const EcoPathRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPath',
      theme: AppTheme.themeOf(ctrl.themeId, dark: ctrl.isDark),
      // Start on the Intro screen
      home: const IntroScreen(),
      // Route into RootShell or Survey
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
        return null;
      },
    );
  }
}
