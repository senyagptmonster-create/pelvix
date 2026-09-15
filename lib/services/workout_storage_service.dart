import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSession {
  final String id;
  final String exerciseName;
  final int durationSeconds;
  final int targetDurationSeconds;
  final DateTime completedAt;

  WorkoutSession({
    required this.id,
    required this.exerciseName,
    required this.durationSeconds,
    required this.targetDurationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'durationSeconds': durationSeconds,
      'targetDurationSeconds': targetDurationSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String? ?? '',
      exerciseName: map['exerciseName'] as String? ?? 'Plank Hold',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      targetDurationSeconds: (map['targetDurationSeconds'] as num?)?.toInt() ?? 60,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ExerciseItem {
  final String id;
  final String name;
  final String category;
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  final List<String> targetMuscles;
  final String formCue;
  final List<String> commonErrors;
  final int defaultSeconds;

  const ExerciseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    required this.formCue,
    required this.commonErrors,
    this.defaultSeconds = 60,
  });
}

class StreakBadge {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
  final String icon;

  const StreakBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.icon,
  });
}

class WorkoutStorageService extends ChangeNotifier {
  static const String _prefsSessionsKey = 'pelvix_workout_sessions_v1';
  static const String _prefsPersonalBestKey = 'pelvix_personal_best_v1';
  static const String _prefsSoundKey = 'pelvix_sound_cues_v1';
  static const String _prefsTargetDurationKey = 'pelvix_target_duration_v1';

  final List<WorkoutSession> _sessions = [];
  int _personalBestSeconds = 60;
  int _targetDurationSeconds = 60;
  bool _soundCuesEnabled = true;
  String _selectedExerciseId = 'std_plank';
  bool _isInitialized = false;

  final List<ExerciseItem> _exercises = const [
    ExerciseItem(
      id: 'std_plank',
      name: 'Standard Forearm Plank',
      category: 'Isometric Core',
      difficulty: 'Beginner',
      targetMuscles: ['Rectus Abdominis', 'Transverse Abdominis', 'Shoulders'],
      formCue: 'Elbows under shoulders, pull belly button inward, brace glutes firmly to lock pelvis.',
      commonErrors: [
        'Sagging hips putting shear load on lower lumbar spine.',
        'Winging shoulder blades with neck dropping down.',
        'Holding breath instead of controlled abdominal breathing.',
      ],
      defaultSeconds: 60,
    ),
    ExerciseItem(
      id: 'side_plank_left',
      name: 'Side Plank (Lateral Hold)',
      category: 'Oblique Stability',
      difficulty: 'Intermediate',
      targetMuscles: ['Internal & External Obliques', 'Quadratus Lumborum', 'Glute Medius'],
      formCue: 'Stack feet or scissor one foot front. Keep ribcage high away from the mat.',
      commonErrors: [
        'Hips dropping toward floor.',
        'Rotating upper shoulder forward.',
        'Neck dropping out of line with spine.',
      ],
      defaultSeconds: 45,
    ),
    ExerciseItem(
      id: 'hollow_body_hold',
      name: 'Gymnastic Hollow Body Hold',
      category: 'Anterior Chain',
      difficulty: 'Advanced',
      targetMuscles: ['Transverse Abdominis', 'Hip Flexors', 'Rectus Abdominis'],
      formCue: 'Press lower back flat into the ground without any air gap. Point toes and reach arms overhead.',
      commonErrors: [
        'Lower back arching off the ground.',
        'Straining the neck by pulling chin to chest aggressively.',
      ],
      defaultSeconds: 40,
    ),
    ExerciseItem(
      id: 'bird_dog_hold',
      name: 'Bird-Dog Isometric Hold',
      category: 'Posterior & Anti-Rotation',
      difficulty: 'Beginner',
      targetMuscles: ['Erector Spinae', 'Gluteus Maximus', 'Multifidus'],
      formCue: 'Reach opposite arm and leg parallel to floor. Keep pelvis perfectly level like a table.',
      commonErrors: [
        'Over-arching lumbar spine to lift leg too high.',
        'Hips tilting to one side.',
      ],
      defaultSeconds: 45,
    ),
    ExerciseItem(
      id: 'extended_plank',
      name: 'Extended Arm Long-Lever Plank',
      category: 'High Torque Stability',
      difficulty: 'Advanced',
      targetMuscles: ['Full Core Complex', 'Latissimus Dorsi', 'Serratus Anterior'],
      formCue: 'Hands placed 6 inches in front of shoulders, creating maximum anti-extension leverage.',
      commonErrors: [
        'Lower back sagging immediately under longer lever arm.',
        'Lifting glutes into an inverted V shape.',
      ],
      defaultSeconds: 35,
    ),
    ExerciseItem(
      id: 'reverse_plank',
      name: 'Reverse Plank Hold',
      category: 'Posterior Chain',
      difficulty: 'Intermediate',
      targetMuscles: ['Glutes', 'Hamstrings', 'Posterior Deltoids', 'Core'],
      formCue: 'Hands behind hips, fingers forward or outward. Drive heels down and lift hips to form straight line.',
      commonErrors: [
        'Hips sagging downward.',
        'Dropping the head backward uncontrollably.',
      ],
      defaultSeconds: 45,
    ),
  ];

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  List<ExerciseItem> get exercises => _exercises;
  int get personalBestSeconds => _personalBestSeconds;
  int get targetDurationSeconds => _targetDurationSeconds;
  bool get soundCuesEnabled => _soundCuesEnabled;
  String get selectedExerciseId => _selectedExerciseId;
  bool get isInitialized => _isInitialized;

  ExerciseItem get currentExercise {
    return _exercises.firstWhere(
      (e) => e.id == _selectedExerciseId,
      orElse: () => _exercises.first,
    );
  }

  int get totalHoldTimeSeconds {
    return _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  int get totalSessionsCompleted => _sessions.length;

  int get currentStreakDays {
    if (_sessions.isEmpty) return 0;
    final dates = _sessions.map((s) {
      final dt = s.completedAt;
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<StreakBadge> get badges {
    final streak = currentStreakDays;
    final maxHold = _personalBestSeconds;
    final totalCount = _sessions.length;

    return [
      StreakBadge(
        id: 'b_starter',
        title: 'First Ignition',
        description: 'Completed your first timed core hold session.',
        isUnlocked: totalCount >= 1,
        icon: 'flash',
      ),
      StreakBadge(
        id: 'b_60s',
        title: '60s Foundation',
        description: 'Held a solid continuous plank for at least 60 seconds.',
        isUnlocked: maxHold >= 60,
        icon: 'timer',
      ),
      StreakBadge(
        id: 'b_3day',
        title: '3-Day Consistency',
        description: 'Achieved an unbroken 3-day workout cadence.',
        isUnlocked: streak >= 3,
        icon: 'calendar',
      ),
      StreakBadge(
        id: 'b_90s',
        title: 'Iron Core 90s',
        description: 'Exceeded 90 seconds in a single isometric hold.',
        isUnlocked: maxHold >= 90,
        icon: 'shield',
      ),
      StreakBadge(
        id: 'b_7day',
        title: '7-Day Titan',
        description: 'Completed core holds for 7 consecutive calendar days.',
        isUnlocked: streak >= 7,
        icon: 'trophy',
      ),
      StreakBadge(
        id: 'b_120s',
        title: '2-Minute Champion',
        description: 'Reached the elite 120-second continuous hold barrier.',
        isUnlocked: maxHold >= 120,
        icon: 'award',
      ),
    ];
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _personalBestSeconds = prefs.getInt(_prefsPersonalBestKey) ?? 60;
      _targetDurationSeconds = prefs.getInt(_prefsTargetDurationKey) ?? 60;
      _soundCuesEnabled = prefs.getBool(_prefsSoundKey) ?? true;

      final rawSessions = prefs.getString(_prefsSessionsKey);
      if (rawSessions != null && rawSessions.isNotEmpty) {
        final decoded = jsonDecode(rawSessions) as List<dynamic>;
        _sessions.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _sessions.add(WorkoutSession.fromMap(item));
          }
        }
        _sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      } else {
        _populateSampleHistory();
      }
    } catch (e) {
      debugPrint('WorkoutStorageService init error: $e');
      if (_sessions.isEmpty) {
        _populateSampleHistory();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  void _populateSampleHistory() {
    final now = DateTime.now();
    _sessions.addAll([
      WorkoutSession(
        id: 'sess_sample_1',
        exerciseName: 'Standard Forearm Plank',
        durationSeconds: 65,
        targetDurationSeconds: 60,
        completedAt: now.subtract(const Duration(hours: 3)),
      ),
      WorkoutSession(
        id: 'sess_sample_2',
        exerciseName: 'Side Plank (Lateral Hold)',
        durationSeconds: 45,
        targetDurationSeconds: 45,
        completedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      WorkoutSession(
        id: 'sess_sample_3',
        exerciseName: 'Gymnastic Hollow Body Hold',
        durationSeconds: 40,
        targetDurationSeconds: 40,
        completedAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
    ]);
  }

  void setSelectedExercise(String id) {
    _selectedExerciseId = id;
    final ex = _exercises.firstWhere((e) => e.id == id, orElse: () => _exercises.first);
    _targetDurationSeconds = ex.defaultSeconds;
    notifyListeners();
  }

  void setTargetDuration(int seconds) {
    if (seconds >= 15 && seconds <= 600) {
      _targetDurationSeconds = seconds;
      notifyListeners();
      _saveSettings();
    }
  }

  void toggleSoundCues(bool enabled) {
    _soundCuesEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  Future<void> recordSession({
    required String exerciseName,
    required int durationSeconds,
    required int targetSeconds,
  }) async {
    final session = WorkoutSession(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: exerciseName,
      durationSeconds: durationSeconds,
      targetDurationSeconds: targetSeconds,
      completedAt: DateTime.now(),
    );
    _sessions.insert(0, session);

    if (durationSeconds > _personalBestSeconds) {
      _personalBestSeconds = durationSeconds;
    }

    notifyListeners();
    await _saveSessions();
    await _saveSettings();
  }

  Future<void> clearHistory() async {
    _sessions.clear();
    _personalBestSeconds = 60;
    notifyListeners();
    await _saveSessions();
    await _saveSettings();
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapped = _sessions.map((s) => s.toMap()).toList();
      await prefs.setString(_prefsSessionsKey, jsonEncode(mapped));
    } catch (e) {
      debugPrint('Error saving workout sessions: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsPersonalBestKey, _personalBestSeconds);
      await prefs.setInt(_prefsTargetDurationKey, _targetDurationSeconds);
      await prefs.setBool(_prefsSoundKey, _soundCuesEnabled);
    } catch (e) {
      debugPrint('Error saving workout settings: $e');
    }
  }
}
