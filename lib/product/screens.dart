import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/brand.dart';

class PelvixMain extends StatefulWidget {
  const PelvixMain({super.key});
  @override
  State<PelvixMain> createState() => _PelvixMainState();
}

class _PelvixMainState extends State<PelvixMain> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    PlankRoutineTimerScreen(),
    CoreWorkoutLibraryScreen(),
    StreakRecordsScreen(),
    FormGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pelvix', style: AppTheme.display(cSurface)),
        backgroundColor: cAccent,
      ),
      drawer: Drawer(
        backgroundColor: cBg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: cAccent),
              child: Text('Pelvix Menu', style: AppTheme.display(cSurface)),
            ),
            ListTile(
              title: Text('Plank Timer', style: AppTheme.text(cInk)),
              onTap: () {
                setState(() { _currentIndex = 0; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Workout Library', style: AppTheme.text(cInk)),
              onTap: () {
                setState(() { _currentIndex = 1; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Streak Records', style: AppTheme.text(cInk)),
              onTap: () {
                setState(() { _currentIndex = 2; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Form Guide', style: AppTheme.text(cInk)),
              onTap: () {
                setState(() { _currentIndex = 3; });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}

class PlankRoutineTimerScreen extends StatelessWidget {
  const PlankRoutineTimerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Plank Routine Timer', style: AppTheme.display(cInk)));
  }
}

class CoreWorkoutLibraryScreen extends StatelessWidget {
  const CoreWorkoutLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Core Workout Library', style: AppTheme.display(cInk)));
  }
}

class StreakRecordsScreen extends StatelessWidget {
  const StreakRecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Streak Records', style: AppTheme.display(cInk)));
  }
}

class FormGuideScreen extends StatelessWidget {
  const FormGuideScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Form Guide', style: AppTheme.display(cInk)));
  }
}
