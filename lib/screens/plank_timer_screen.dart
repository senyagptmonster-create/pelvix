import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../components/timer_dial_widget.dart';
import '../services/workout_storage_service.dart';
import '../theme/pelvix_theme.dart';

class PlankTimerScreen extends StatefulWidget {
  const PlankTimerScreen({super.key});

  @override
  State<PlankTimerScreen> createState() => _PlankTimerScreenState();
}

class _PlankTimerScreenState extends State<PlankTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 60;
  int _targetSeconds = 60;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<WorkoutStorageService>(context, listen: false);
    _targetSeconds = service.targetDurationSeconds;
    _remainingSeconds = _targetSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        // 3-2-1 countdown cue
        if (_remainingSeconds <= 3) {
          HapticFeedback.mediumImpact();
        }
      } else {
        t.cancel();
        _onHoldCompleted();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    final service = Provider.of<WorkoutStorageService>(context, listen: false);
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _targetSeconds = service.targetDurationSeconds;
      _remainingSeconds = _targetSeconds;
    });
  }

  void _adjustTime(int deltaSeconds) {
    if (_isRunning) return;
    final newTime = (_targetSeconds + deltaSeconds).clamp(15, 600);
    setState(() {
      _targetSeconds = newTime;
      _remainingSeconds = newTime;
    });
    context.read<WorkoutStorageService>().setTargetDuration(newTime);
  }

  void _onHoldCompleted() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
      _remainingSeconds = 0;
    });

    final service = context.read<WorkoutStorageService>();
    final exercise = service.currentExercise;
    service.recordSession(
      exerciseName: exercise.name,
      durationSeconds: _targetSeconds,
      targetSeconds: _targetSeconds,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PelvixTheme.cardNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: PelvixTheme.neonGreen),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: PelvixTheme.neonGreen, size: 28),
            SizedBox(width: 10),
            Text(
              'Hold Conquered!',
              style: TextStyle(color: PelvixTheme.textLight, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flawless isometric tension held for $_targetSeconds seconds in ${exercise.name}.',
              style: const TextStyle(color: PelvixTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PelvixTheme.darkNavyBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Personal Best:', style: TextStyle(fontSize: 13, color: PelvixTheme.textMuted)),
                  Text(
                    '${service.personalBestSeconds}s',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: PelvixTheme.neonGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PelvixTheme.neonGreen,
              foregroundColor: PelvixTheme.darkNavyBg,
            ),
            child: const Text('Continue Next Round'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WorkoutStorageService>();
    final currentEx = service.currentExercise;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Isometric Hold Timer'),
        actions: [
          IconButton(
            icon: Icon(
              service.soundCuesEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: service.soundCuesEnabled
                  ? PelvixTheme.neonGreen
                  : PelvixTheme.textMuted,
            ),
            tooltip: 'Audio Cues',
            onPressed: () {
              service.toggleSoundCues(!service.soundCuesEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    service.soundCuesEnabled
                        ? 'Sound & haptic cues active'
                        : 'Sound cues muted',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Exercise selector pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: PelvixTheme.cardNavy,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PelvixTheme.borderNavy),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: service.selectedExerciseId,
                  dropdownColor: PelvixTheme.cardNavyElevated,
                  icon: const Icon(Icons.arrow_drop_down_rounded,
                      color: PelvixTheme.neonGreen),
                  items: service.exercises.map((ex) {
                    return DropdownMenuItem(
                      value: ex.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: PelvixTheme.neonGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            ex.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: PelvixTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null && !_isRunning) {
                      service.setSelectedExercise(id);
                      setState(() {
                        _targetSeconds = service.targetDurationSeconds;
                        _remainingSeconds = _targetSeconds;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // The Circular Timer Dial Widget
            TimerDialWidget(
              remainingSeconds: _remainingSeconds,
              targetSeconds: _targetSeconds,
              isRunning: _isRunning,
              isCompleted: _isCompleted,
            ),
            const SizedBox(height: 20),
            // Quick Duration Adjustments
            if (!_isRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => _adjustTime(-15),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PelvixTheme.textLight,
                      side: const BorderSide(color: PelvixTheme.borderNavy),
                    ),
                    child: const Text('-15s'),
                  ),
                  const SizedBox(width: 12),
                  ...[45, 60, 90].map((dur) {
                    final isSel = _targetSeconds == dur;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text('${dur}s'),
                        backgroundColor: isSel
                            ? PelvixTheme.neonGreenDim
                            : PelvixTheme.cardNavy,
                        side: BorderSide(
                          color: isSel
                              ? PelvixTheme.neonGreen
                              : PelvixTheme.borderNavy,
                        ),
                        labelStyle: TextStyle(
                          color: isSel
                              ? PelvixTheme.neonGreen
                              : PelvixTheme.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                        onPressed: () {
                          setState(() {
                            _targetSeconds = dur;
                            _remainingSeconds = dur;
                          });
                          service.setTargetDuration(dur);
                        },
                      ),
                    );
                  }),
                  OutlinedButton(
                    onPressed: () => _adjustTime(15),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PelvixTheme.textLight,
                      side: const BorderSide(color: PelvixTheme.borderNavy),
                    ),
                    child: const Text('+15s'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Timer Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 26,
                    ),
                    label: Text(
                      _isRunning ? 'PAUSE HOLD' : 'IGNITE TIMER',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning
                          ? PelvixTheme.alertOrange
                          : PelvixTheme.neonGreen,
                      foregroundColor: PelvixTheme.darkNavyBg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: PelvixTheme.cardNavyElevated,
                    foregroundColor: PelvixTheme.textLight,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Form coaching reminder banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PelvixTheme.cardNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PelvixTheme.borderNavy),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    color: PelvixTheme.neonGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Primary Form Cue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: PelvixTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentEx.formCue,
                          style: const TextStyle(
                            fontSize: 13,
                            color: PelvixTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
