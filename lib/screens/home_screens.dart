import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';
import '../widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];
  double _cgpa = 0.00;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('saved_courses');

    setState(() {
      if (coursesString != null) {
        final List<dynamic> decoded = jsonDecode(coursesString);
        _courses = decoded.map((item) => Course.fromMap(item)).toList();
      } else {
        _courses = [
          Course(id: '1', name: 'Course 1', credit: 3.0, gradePoint: 4.0),
          Course(id: '2', name: 'Course 2', credit: 3.0, gradePoint: 4.0),
          Course(id: '3', name: 'Course 3', credit: 3.0, gradePoint: 4.0),
        ];
      }
      _cgpa = CalculatorUtils.calculateCGPA(_courses);
      _isLoading = false;
    });
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedList = _courses.map((c) => c.toMap()).toList();
    await prefs.setString('saved_courses', jsonEncode(mappedList));
  }

  void _addCourse() {
    setState(() {
      _courses.add(Course(
        id: DateTime.now().toString(),
        name: 'Course ${_courses.length + 1}',
        credit: 3.0,
        gradePoint: 4.0,
      ));
      _calculateResult();
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      for (int i = 0; i < _courses.length; i++) {
        if (_courses[i].name.startsWith('Course ')) {
          _courses[i].name = 'Course ${i + 1}';
        }
      }
      _calculateResult();
    });
  }

  void _calculateResult() {
    setState(() {
      _cgpa = CalculatorUtils.calculateCGPA(_courses);
    });
    _saveCourses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 60, color: theme.colorScheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'No courses added yet',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return CourseCard(
                  key: ValueKey(_courses[index].id),
                  course: _courses[index],
                  onRemove: () => _removeCourse(index),
                  onChanged: _calculateResult,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132F73).withOpacity(0.4) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Current CGPA: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _cgpa.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}