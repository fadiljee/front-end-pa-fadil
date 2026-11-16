import 'package:flutter/material.dart';
import 'core/navigation/navigator_key.dart';
import 'features/onboarding/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayo Berhitung',
      navigatorKey: appNavigatorKey,
      home: const WelcomeScreen(),
    );
  }
}
