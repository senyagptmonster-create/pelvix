import 'package:flutter/material.dart';
import 'theme/pelvix_theme.dart';
import 'screens/plank_timer_screen.dart';

void main() {
  runApp(const PelvixApp());
}

class PelvixApp extends StatelessWidget {
  const PelvixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelvix Core',
      debugShowCheckedModeBanner: false,
      theme: PelvixTheme.themeData,
      home: const PlankTimerScreen(),
    );
  }
}
