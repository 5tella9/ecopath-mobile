import 'package:flutter/material.dart';
import 'ui/root_shell.dart';
import 'ui/screens/intro_screen.dart';
import 'ui/screens/survey_flow.dart'; 

void main() {
  runApp(const EcoPathRoot());
}

class EcoPathRoot extends StatelessWidget {
  const EcoPathRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPath',
      theme: ThemeData(useMaterial3: true),
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
