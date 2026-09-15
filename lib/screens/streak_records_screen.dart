import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_storage_service.dart';
import '../theme/pelvix_theme.dart';

class StreakRecordsScreen extends StatelessWidget {
  const StreakRecordsScreen({super.key});

  String _formatHoldDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    if (mins == 0) return '${secs}s';
    return '${mins}m ${secs}s';
  }

  String _formatSessionDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, ${dt.year} • $h:$min';
  }

  IconData _getBadgeIcon(String icon) {
    switch (icon) {
      case 'flash':
        return Icons.bolt_rounded;
      case 'timer':
        return Icons.timer_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'award':
      default:
        return Icons.military_tech_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WorkoutStorageService>();
    final personalBest = service.personalBestSeconds;
    final streak = service.currentStreakDays;
    final badges = service.badges;
    final sessions = service.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak & Personal Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear History',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: PelvixTheme.cardNavy,
                  title: const Text('Clear Workout Log?'),
                  content: const Text(
                    'Are you sure you want to reset all recorded plank sessions and records?',
                    style: TextStyle(color: PelvixTheme.textMuted),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        service.clearHistory();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Records reset')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PelvixTheme.alertOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Personal Best Trophy Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PelvixTheme.neonGreen.withValues(alpha: 0.15),
                  PelvixTheme.cardNavy,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PelvixTheme.neonGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: PelvixTheme.neonGreenDim,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: PelvixTheme.neonGreen,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ALL-TIME PERSONAL BEST',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.neonGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatHoldDuration(personalBest),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: PelvixTheme.textLight,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'Continuous isometric tension held',
                        style: TextStyle(
                          fontSize: 12,
                          color: PelvixTheme.textMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Streak & Lifetime Stats Strip
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PelvixTheme.cardNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PelvixTheme.borderNavy),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              color: PelvixTheme.alertOrange, size: 20),
                          SizedBox(width: 6),
                          Text('Current Streak',
                              style: TextStyle(fontSize: 12, color: PelvixTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$streak Days',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PelvixTheme.cardNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PelvixTheme.borderNavy),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fitness_center_rounded,
                              color: PelvixTheme.accentCyan, size: 20),
                          SizedBox(width: 6),
                          Text('Total Holds',
                              style: TextStyle(fontSize: 12, color: PelvixTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${service.totalSessionsCompleted}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Badges Grid
          const Text(
            'Core Mastery Badges',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PelvixTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badge.isUnlocked
                      ? PelvixTheme.cardNavyElevated
                      : PelvixTheme.cardNavy.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: badge.isUnlocked
                        ? PelvixTheme.neonGreen.withValues(alpha: 0.5)
                        : PelvixTheme.borderNavy,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          _getBadgeIcon(badge.icon),
                          color: badge.isUnlocked
                              ? PelvixTheme.neonGreen
                              : PelvixTheme.textDark,
                          size: 24,
                        ),
                        if (badge.isUnlocked)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: PelvixTheme.neonGreen,
                          )
                        else
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            color: PelvixTheme.textDark,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      badge.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: badge.isUnlocked
                            ? PelvixTheme.textLight
                            : PelvixTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: badge.isUnlocked
                            ? PelvixTheme.textMuted
                            : PelvixTheme.textDark,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // Session Log History
          const Text(
            'Session History',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PelvixTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No sessions logged yet. Complete a hold timer round!',
                  style: TextStyle(color: PelvixTheme.textMuted.withValues(alpha: 0.8)),
                ),
              ),
            )
          else
            ...sessions.map((sess) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PelvixTheme.neonGreenDim,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: PelvixTheme.neonGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sess.exerciseName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PelvixTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatSessionDate(sess.completedAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: PelvixTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${sess.durationSeconds}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.neonGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
