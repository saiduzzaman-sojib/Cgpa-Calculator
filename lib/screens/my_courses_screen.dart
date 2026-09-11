import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', '1 Credit', '3 Credits'];

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
      setState(() {
        _allCourses = decoded.map((item) => Course.fromMap(item)).toList();
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        // Search filter
        final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Chip filter
        bool matchesChip = true;
        if (_selectedFilter == '1 Credit') {
          matchesChip = course.credit == 1.0;
        } else if (_selectedFilter == '3 Credits') {
          matchesChip = course.credit == 3.0;
        }

        return matchesSearch && matchesChip;
      }).toList();
    });
  }

  // Helper method to get color based on grade point
  Color _getGradeColor(double gradePoint) {
    if (gradePoint >= 3.75) return Colors.green;
    if (gradePoint >= 3.0) return Colors.orange;
    if (gradePoint >= 2.0) return Colors.deepOrangeAccent;
    return Colors.red;
  }

  // Helper method to get letter grade
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      filter == 'All' ? 'All (${_allCourses.length})' : filter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade200,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _applyFilters();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Course List
          Expanded(
            child: _filteredCourses.isEmpty
                ? const Center(child: Text('No courses found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      final letterGrade = _getLetterGrade(course.gradePoint);
                      final gradeColor = _getGradeColor(course.gradePoint);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.transparent : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: isDark ? [] : [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${course.credit.toStringAsFixed(0)} Credits',
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            // Grade Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: gradeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: gradeColor.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    letterGrade,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor),
                                  ),
                                  Text(
                                    '(${course.gradePoint})',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gradeColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                          ],
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