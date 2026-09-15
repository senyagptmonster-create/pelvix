import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/core_library_screen.dart';
import 'screens/form_guide_screen.dart';
import 'screens/plank_timer_screen.dart';
import 'screens/streak_records_screen.dart';
import 'services/workout_storage_service.dart';
import 'theme/pelvix_theme.dart';

class PelvixCoreApp extends StatelessWidget {
  const PelvixCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutStorageService()..init(),
      child: MaterialApp(
        title: 'Pelvix Isometric Core',
        debugShowCheckedModeBanner: false,
        theme: PelvixTheme.themeData(),
        home: const PelvixMainShell(),
      ),
    );
  }
}

class PelvixMainShell extends StatefulWidget {
  const PelvixMainShell({super.key});

  @override
  State<PelvixMainShell> createState() => _PelvixMainShellState();
}

class _PelvixMainShellState extends State<PelvixMainShell> {
  int _currentIndex = 0;

  void _navigateToTimer() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const PlankTimerScreen(),
      CoreLibraryScreen(onExerciseSelected: _navigateToTimer),
      const StreakRecordsScreen(),
      const FormGuideScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Hold Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_folder_outlined),
            selectedIcon: Icon(Icons.rule_folder_rounded),
            label: 'Form Guide',
          ),
        ],
      ),
    );
  }
}
