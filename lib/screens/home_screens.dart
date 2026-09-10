import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/calculator_utils.dart';
import '../widgets/course_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Course> _courses = [
    Course(id: '1', name: 'Course 1', credit: 3.0),
    Course(id: '2', name: 'Course 2', credit: 3.0),
    Course(id: '3', name: 'Course 3', credit: 3.0),
  ];
  double _cgpa = 0.00;

  @override
  void initState() {
    super.initState();
    _calculateResult();
  }

  void _addCourse() {
    setState(() {
      _courses.add(Course(
        id: DateTime.now().toString(),
        name: 'Course ${_courses.length + 1}',
        credit: 3.0,
      ));
      _calculateResult();
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _calculateResult();
    });
  }

  void _calculateResult() {
    setState(() {
      _cgpa = CalculatorUtils.calculateCGPA(_courses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 70, color: theme.colorScheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses added yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132F73).withOpacity(0.4) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current CGPA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _cgpa.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}