import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';

class SemesterReportScreen extends StatefulWidget {
  const SemesterReportScreen({super.key});

  @override
  State<SemesterReportScreen> createState() => _SemesterReportScreenState();
}

class _SemesterReportScreenState extends State<SemesterReportScreen> {
  List<Course> _allCourses = [];
  List<Course> _semesterCourses = [];
  List<String> _semesters = ['Fall 2026'];
  String _selectedSemester = 'Fall 2026';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('saved_courses');

    if (coursesString != null) {
      final List<dynamic> decoded = jsonDecode(coursesString);
      _allCourses = decoded.map((item) => Course.fromMap(item)).toList();
      
      // Extract unique semesters from saved courses
      final Set<String> uniqueSemesters = _allCourses.map((c) => c.semester).toSet();
      if (uniqueSemesters.isNotEmpty) {
        _semesters = uniqueSemesters.toList()..sort();
        if (!_semesters.contains(_selectedSemester)) {
          _selectedSemester = _semesters.first;
        }
      }
    }

    _filterBySemester();
    setState(() => _isLoading = false);
  }

  void _filterBySemester() {
    setState(() {
      _semesterCourses = _allCourses.where((c) => c.semester == _selectedSemester).toList();
    });
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    double totalCredits = _semesterCourses.fold(0, (sum, item) => sum + item.credit);
    double semesterGpa = CalculatorUtils.calculateCGPA(_semesterCourses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Report', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Semester', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSemester,
                      items: _semesters.map((sem) => DropdownMenuItem(value: sem, child: Text(sem, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedSemester = val;
                          _filterBySemester();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedSemester, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(semesterGpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Semester GPA', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.assessment_rounded, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Summary Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${totalCredits.toStringAsFixed(0)} Total Credits', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            
            _semesterCourses.isEmpty 
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No courses added for this semester.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))))
              : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _semesterCourses.length,
              itemBuilder: (context, index) {
                final course = _semesterCourses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${course.credit} Credits', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${_getLetterGrade(course.gradePoint)} (${course.gradePoint})',
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}