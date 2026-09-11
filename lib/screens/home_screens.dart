import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';
import '../widgets/course_card.dart';
import 'my_courses_screen.dart';
import 'add_course_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _courses = [];
  double _cgpa = 0.00;
  double _totalCredits = 0.0;
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
        _courses = [];
      }
      _calculateResult();
      _isLoading = false;
    });
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedList = _courses.map((c) => c.toMap()).toList();
    await prefs.setString('saved_courses', jsonEncode(mappedList));
  }

  Future<void> _addCourse() async {
    final newCourse = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCourseScreen()),
    );

    if (newCourse != null && newCourse is Course) {
      setState(() {
        _courses.insert(0, newCourse);
        _calculateResult();
      });
    }
  }

  Future<void> _editCourse(Course course) async {
    final updatedCourse = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourseScreen(courseToEdit: course),
      ),
    );

    if (updatedCourse != null && updatedCourse is Course) {
      setState(() {
        final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
        if (index != -1) {
          _courses[index] = updatedCourse;
          _calculateResult();
        }
      });
    }
  }

  void _removeCourse(String id) {
    setState(() {
      _courses.removeWhere((course) => course.id == id);
      _calculateResult();
    });
  }

  void _calculateResult() {
    setState(() {
      _cgpa = CalculatorUtils.calculateCGPA(_courses);
      _totalCredits = _courses.fold(0, (sum, item) => sum + item.credit);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Sojib 👋',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep going! You\'re doing great',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text('MS', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, const Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current CGPA', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            _cgpa.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      height: 115,
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor ?? (isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Total Credits', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(
                            _totalCredits.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _addCourse,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_box_rounded, color: theme.colorScheme.primary, size: 28),
                            const SizedBox(height: 8),
                            Text('Add Course', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyCoursesScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.transparent : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.library_books_rounded, color: Colors.grey, size: 28),
                            SizedBox(height: 8),
                            Text('All Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_courses.length} items', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              _courses.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          'No courses added yet. Add one to get started!',
                          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(
                          key: ValueKey(_courses[index].id),
                          course: _courses[index],
                          onRemove: () => _removeCourse(_courses[index].id),
                          onEdit: () => _editCourse(_courses[index]),
                          onChanged: _calculateResult,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}