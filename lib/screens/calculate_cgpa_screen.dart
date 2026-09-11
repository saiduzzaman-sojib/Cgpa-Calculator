import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';

class CalculateCgpaScreen extends StatefulWidget {
  const CalculateCgpaScreen({super.key});

  @override
  State<CalculateCgpaScreen> createState() => _CalculateCgpaScreenState();
}

class _CalculateCgpaScreenState extends State<CalculateCgpaScreen> {
  String _selectedSemester = 'Fall 2026';
  final List<String> _semesters = ['Fall 2026', 'Spring 2026', 'Summer 2025', 'Fall 2025'];
  
  final List<Course> _calcCourses = [
    Course(id: '1', name: 'CSE 101', credit: 3.0, gradePoint: 4.0),
    Course(id: '2', name: 'MAT 101', credit: 3.0, gradePoint: 3.75),
    Course(id: '3', name: 'PHY 101', credit: 3.0, gradePoint: 3.3),
  ];

  double _semesterGpa = 0.00;
  bool _isCalculated = false;

  final Map<String, double> _gradeOptions = {
    'A+ (4.0)': 4.0,
    'A (3.75)': 3.75,
    'A- (3.5)': 3.5,
    'B+ (3.25)': 3.25,
    'B (3.0)': 3.0,
    'B- (2.75)': 2.75,
    'C+ (2.5)': 2.5,
    'C (2.25)': 2.25,
    'D (2.0)': 2.0,
    'F (0.0)': 0.0,
  };

  void _calculateSemesterGpa() {
    setState(() {
      _semesterGpa = CalculatorUtils.calculateCGPA(_calcCourses);
      _isCalculated = true;
    });
  }

  void _addCalcRow() {
    setState(() {
      _calcCourses.add(Course(
        id: DateTime.now().toString(),
        name: 'New Course',
        credit: 3.0,
        gradePoint: 4.0,
      ));
      _isCalculated = false;
    });
  }

  void _removeCalcRow(int index) {
    setState(() {
      _calcCourses.removeAt(index);
      _isCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate GPA', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semester', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSemester,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: _semesters.map((sem) => DropdownMenuItem(value: sem, child: Text(sem))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSemester = val);
              },
            ),
            const SizedBox(height: 24),
            const Text('Course / Grade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _calcCourses.length,
              itemBuilder: (context, index) {
                final course = _calcCourses[index];
                String currentGradeKey = _gradeOptions.entries
                    .firstWhere((e) => e.value == course.gradePoint, orElse: () => _gradeOptions.entries.first)
                    .key;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: TextEditingController(text: course.name),
                          onChanged: (val) => course.name = val,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentGradeKey,
                            isExpanded: true,
                            items: _gradeOptions.keys.map((key) => DropdownMenuItem(value: key, child: Text(key, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  course.gradePoint = _gradeOptions[val]!;
                                  _isCalculated = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: course.credit,
                            isExpanded: true,
                            items: [1.0, 2.0, 3.0, 4.0].map((c) => DropdownMenuItem(value: c, child: Text('${c.toInt()} Cr', style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  course.credit = val;
                                  _isCalculated = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeCalcRow(index),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addCalcRow,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _calculateSemesterGpa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Calculate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_isCalculated) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Semester GPA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _semesterGpa.toStringAsFixed(2),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text('Good job!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}