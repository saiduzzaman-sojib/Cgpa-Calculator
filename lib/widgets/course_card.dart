import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onRemove;
  final VoidCallback onEdit;
  final VoidCallback onChanged;

  const CourseCard({
    super.key,
    required this.course,
    required this.onRemove,
    required this.onEdit,
    required this.onChanged,
  });

  Color _getGradeColor(double gradePoint) {
    if (gradePoint >= 3.75) return Colors.green;
    if (gradePoint >= 3.0) return Colors.orange;
    if (gradePoint >= 2.0) return Colors.deepOrangeAccent;
    return Colors.red;
  }

  String _getLetterGrade(double gradePoint) {
    if (gradePoint >= 4.0) return 'A+';
    if (gradePoint >= 3.75) return 'A';
    if (gradePoint >= 3.5) return 'A-';
    if (gradePoint >= 3.25) return 'B+';
    if (gradePoint >= 3.0) return 'B';
    if (gradePoint >= 2.75) return 'B-';
    if (gradePoint >= 2.5) return 'C+';
    if (gradePoint >= 2.25) return 'C';
    if (gradePoint >= 2.0) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradeColor = _getGradeColor(course.gradePoint);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${course.semester} • ${course.credit} Credits', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: gradeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${_getLetterGrade(course.gradePoint)} (${course.gradePoint})',
              style: TextStyle(fontWeight: FontWeight.bold, color: gradeColor),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 22),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}