import 'package:flutter/material.dart';
import '../theme/pelvix_theme.dart';

class FormGuideScreen extends StatefulWidget {
  const FormGuideScreen({super.key});

  @override
  State<FormGuideScreen> createState() => _FormGuideScreenState();
}

class _FormGuideScreenState extends State<FormGuideScreen> {
  final Map<int, bool> _formChecklist = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spine & Alignment Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Coaching Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PelvixTheme.cardNavyElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PelvixTheme.borderNavy),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.accessibility_new_rounded,
                  color: PelvixTheme.neonGreen,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biomechanical Integrity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'An active isometric hold is not passive resting. Full tension prevents disc shear.',
                        style: TextStyle(
                          fontSize: 12,
                          color: PelvixTheme.textMuted.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Pre-Hold Form Audit Checklist
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist_rounded,
                          color: PelvixTheme.accentCyan, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        '5-Point Pre-Ignition Audit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PelvixTheme.textLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_formChecklist.values.where((v) => v).length}/5 Checked',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: PelvixTheme.neonGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem(0, 'Elbows directly perpendicular below shoulder joints.'),
                  _buildChecklistItem(1, 'Shoulder blades actively pushed apart (scapular protraction).'),
                  _buildChecklistItem(2, 'Pelvis rotated into slight posterior tuck (belt buckle to ribs).'),
                  _buildChecklistItem(3, 'Quads, calves, and glutes actively squeezed at 80% tension.'),
                  _buildChecklistItem(4, 'Gaze down between fists; neck completely neutral with spine.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Core Alignment Principles',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PelvixTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildPillarCard(
            title: '1. Scapular Protraction vs Winging',
            badge: 'UPPER SPINE',
            badgeColor: PelvixTheme.accentCyan,
            doText: 'Push into the floor through your forearms until your upper back fills out smoothly.',
            dontText: 'Do not collapse into your shoulder blades and let your chest sink to the mat.',
            icon: Icons.shield_outlined,
          ),
          _buildPillarCard(
            title: '2. Posterior Pelvic Tilt vs Lumbar Sag',
            badge: 'LUMBAR / PELVIS',
            badgeColor: PelvixTheme.neonGreen,
            doText: 'Tuck your tailbone toward your heels. This locks the rectus abdominis in tight contraction.',
            dontText: 'Never let your lower back hammock or sag down. Sagging shifts all weight onto passive vertebrae.',
            icon: Icons.fitness_center_rounded,
          ),
          _buildPillarCard(
            title: '3. Cervical Neutrality',
            badge: 'NECK INTEGRITY',
            badgeColor: PelvixTheme.alertOrange,
            doText: 'Look straight down at your thumbs. Keep the neck lengthened like an arrow.',
            dontText: 'Avoid cranking your head back to look at a wall clock or phone timer.',
            icon: Icons.visibility_outlined,
          ),
          _buildPillarCard(
            title: '4. Intra-Abdominal Breathing Bracing',
            badge: 'PRESSURE CONTROL',
            badgeColor: PelvixTheme.neonLime,
            doText: 'Take steady diaphragmatic breaths while maintaining 360-degree cylindrical abdominal rigidity.',
            dontText: 'Do not perform a prolonged Valsalva maneuver (holding your breath until dizzy).',
            icon: Icons.air_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index, String label) {
    final checked = _formChecklist[index] ?? false;
    return InkWell(
      onTap: () {
        setState(() {
          _formChecklist[index] = !checked;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: checked ? PelvixTheme.neonGreen : PelvixTheme.textDark,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: checked ? PelvixTheme.textLight : PelvixTheme.textMuted,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String doText,
    required String dontText,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: badgeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: PelvixTheme.textLight,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: PelvixTheme.neonGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doText,
                    style: const TextStyle(fontSize: 13, color: PelvixTheme.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cancel_rounded,
                    color: PelvixTheme.alertOrange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dontText,
                    style: const TextStyle(fontSize: 13, color: PelvixTheme.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
