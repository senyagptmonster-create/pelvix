import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_storage_service.dart';
import '../theme/pelvix_theme.dart';

class CoreLibraryScreen extends StatefulWidget {
  final VoidCallback onExerciseSelected;

  const CoreLibraryScreen({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  State<CoreLibraryScreen> createState() => _CoreLibraryScreenState();
}

class _CoreLibraryScreenState extends State<CoreLibraryScreen> {
  String _selectedDifficulty = 'All';

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'beginner':
        return PelvixTheme.neonGreen;
      case 'intermediate':
        return PelvixTheme.accentCyan;
      case 'advanced':
      default:
        return PelvixTheme.alertOrange;
    }
  }

  void _showExerciseDetails(BuildContext context, ExerciseItem ex) {
    final service = context.read<WorkoutStorageService>();
    final diffColor = _getDifficultyColor(ex.difficulty);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: PelvixTheme.cardNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PelvixTheme.borderNavy,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ex.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: diffColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Standard: ${ex.defaultSeconds}s',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PelvixTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ex.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PelvixTheme.textLight,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Target Musculature:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PelvixTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: ex.targetMuscles.map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PelvixTheme.cardNavyElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PelvixTheme.borderNavy),
                    ),
                    child: Text(
                      m,
                      style: const TextStyle(fontSize: 12, color: PelvixTheme.textLight),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Execution & Alignment Cues:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PelvixTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ex.formCue,
                style: const TextStyle(
                  fontSize: 14,
                  color: PelvixTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Critical Errors to Prevent:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PelvixTheme.alertOrange,
                ),
              ),
              const SizedBox(height: 6),
              ...ex.commonErrors.map((err) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.close_rounded,
                          size: 16, color: PelvixTheme.alertOrange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          err,
                          style: const TextStyle(
                            fontSize: 13,
                            color: PelvixTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    service.setSelectedExercise(ex.id);
                    Navigator.pop(ctx);
                    widget.onExerciseSelected();
                  },
                  icon: const Icon(Icons.play_circle_filled_rounded),
                  label: const Text('Load into Isometric Timer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PelvixTheme.neonGreen,
                    foregroundColor: PelvixTheme.darkNavyBg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WorkoutStorageService>();
    final exercises = service.exercises;

    final filtered = exercises.where((ex) {
      if (_selectedDifficulty == 'All') return true;
      return ex.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Core Hold Library'),
      ),
      body: Column(
        children: [
          // Filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((diff) {
                final isSelected = _selectedDifficulty == diff;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(diff),
                    selected: isSelected,
                    selectedColor: PelvixTheme.neonGreenDim,
                    checkmarkColor: PelvixTheme.neonGreen,
                    backgroundColor: PelvixTheme.cardNavy,
                    side: BorderSide(
                      color: isSelected ? PelvixTheme.neonGreen : PelvixTheme.borderNavy,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? PelvixTheme.neonGreen : PelvixTheme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedDifficulty = diff;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final ex = filtered[index];
                final isSelected = service.selectedExerciseId == ex.id;
                final diffColor = _getDifficultyColor(ex.difficulty);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected ? PelvixTheme.neonGreen : PelvixTheme.borderNavy,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showExerciseDetails(context, ex),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ex.difficulty.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: diffColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: PelvixTheme.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${ex.defaultSeconds}s',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: PelvixTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ex.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: PelvixTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ex.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: PelvixTheme.neonLime,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ex.formCue,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: PelvixTheme.textMuted,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  service.setSelectedExercise(ex.id);
                                  widget.onExerciseSelected();
                                },
                                icon: const Icon(Icons.flash_on_rounded, size: 16),
                                label: const Text('Start Hold'),
                                style: TextButton.styleFrom(
                                  foregroundColor: PelvixTheme.neonGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
