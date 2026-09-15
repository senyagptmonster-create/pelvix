import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/pelvix_theme.dart';
import '../painters/plank_posture_painter.dart';

class PlankTimerScreen extends StatefulWidget {
  const PlankTimerScreen({super.key});

  @override
  State<PlankTimerScreen> createState() => _PlankTimerScreenState();
}

class _PlankTimerScreenState extends State<PlankTimerScreen> {
  int _targetSeconds = 60;
  int _secondsLeft = 60;
  bool _isRunning = false;
  Timer? _timer;
  String _selectedVariation = 'Forearm Plank';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (_secondsLeft > 0) {
            setState(() => _secondsLeft--);
          } else {
            t.cancel();
            setState(() => _isRunning = false);
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft = _targetSeconds;
    });
  }

  void _setTarget(int seconds) {
    _timer?.cancel();
    setState(() {
      _targetSeconds = seconds;
      _secondsLeft = seconds;
      _isRunning = false;
    });
  }

  void _showVariationsSheet() {
    final variations = [
      {'name': 'Forearm Plank', 'desc': 'Maximum core engagement, neutral spine'},
      {'name': 'High Plank', 'desc': 'Straight arm push, shoulder girdle stability'},
      {'name': 'Side Plank (L/R)', 'desc': 'Lateral obliques and hip adductors focus'},
      {'name': 'Bird-Dog Isometric', 'desc': 'Posterior chain and deep transverse hold'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: PelvixTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Core Plank Variations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...variations.map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: PelvixTheme.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedVariation == v['name']
                          ? PelvixTheme.accent
                          : PelvixTheme.edge,
                    ),
                  ),
                  child: ListTile(
                    title: Text(v['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(v['desc']!, style: const TextStyle(color: PelvixTheme.muted, fontSize: 12)),
                    onTap: () {
                      setState(() => _selectedVariation = v['name']!);
                      Navigator.pop(ctx);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showFormGuideSheet() {
    final cues = [
      'Lock glutes and quads to create a rigid lever.',
      'Pull belly button towards spine to brace transverse abdominis.',
      'Press through elbows to avoid scapular sagging.',
      'Maintain neutral cervical spine; gaze 6 inches in front of hands.',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: PelvixTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Biomechanic Alignment Cues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...cues.map((cue) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: PelvixTheme.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(cue, style: const TextStyle(color: PelvixTheme.ink, height: 1.4, fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_targetSeconds - _secondsLeft) / _targetSeconds;
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PELVIX ISOMETRIC CORE', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Selected Variation Pill
              InkWell(
                onTap: _showVariationsSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PelvixTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PelvixTheme.accent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedVariation, style: const TextStyle(color: PelvixTheme.accent, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: PelvixTheme.accent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Posture & Ring Visualizer
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(
                    painter: PlankPosturePainter(progress: progress, isActive: _isRunning),
                    child: Center(
                      child: Text(
                        '$mins:${secs.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: PelvixTheme.ink,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Duration Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [30, 60, 90, 120].map((s) {
                  final isSel = _targetSeconds == s;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text('${s}s'),
                      selected: isSel,
                      selectedColor: PelvixTheme.accent,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => _setTarget(s),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Control Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? Colors.redAccent : PelvixTheme.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _toggleTimer,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(
                          _isRunning ? 'PAUSE HOLD' : 'COMMENCE HOLD',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: PelvixTheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Action Sheets Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: _showVariationsSheet,
                      icon: const Icon(Icons.fitness_center, color: PelvixTheme.accentLight, size: 18),
                      label: const Text('Variations', style: TextStyle(color: PelvixTheme.ink)),
                    ),
                    TextButton.icon(
                      onPressed: _showFormGuideSheet,
                      icon: const Icon(Icons.accessibility_new, color: PelvixTheme.accentLight, size: 18),
                      label: const Text('Form Guide', style: TextStyle(color: PelvixTheme.ink)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
