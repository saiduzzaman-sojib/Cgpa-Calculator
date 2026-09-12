import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/database_helper.dart';

class Course {
  String id;
  String name;
  double credit;
  double gradePoint;

  Course({required this.id, required this.name, required this.credit, required this.gradePoint});
}

class CalculateCgpaScreen extends StatefulWidget {
  const CalculateCgpaScreen({super.key});

  @override
  State<CalculateCgpaScreen> createState() => _CalculateCgpaScreenState();
}

class _CalculateCgpaScreenState extends State<CalculateCgpaScreen> {
  final List<Course> _calcCourses = [
    Course(id: '1', name: 'Course 1', credit: 3.0, gradePoint: 4.0),
    Course(id: '2', name: 'Course 2', credit: 3.0, gradePoint: 3.75),
    Course(id: '3', name: 'Course 3', credit: 3.0, gradePoint: 4.0),
  ];

  double _pastCurrentCgpa = 0.00;
  int _pastSemesterCount = 0;
  double _totalPastCredits = 0.0;

  double _currentCalculatedCgpa = 0.00;
  double _currentTotalCredits = 0.00;
  double _estimatedTotalCgpa = 0.00;
  
  bool _isCalculated = false;
  bool _isTotalRevealed = false;

  final Map<String, double> _gradeOptions = {
    'A+ (4.00)': 4.00,
    'A  (3.75)': 3.75,
    'A- (3.50)': 3.50,
    'B+ (3.25)': 3.25,
    'B  (3.00)': 3.00,
    'B- (2.75)': 2.75,
    'C+ (2.50)': 2.50,
    'C  (2.25)': 2.25,
    'D  (2.00)': 2.00,
    'F  (0.00)': 0.00,
  };

  @override
  void initState() {
    super.initState();
    _loadPastSemestersFromDB();
  }

  Future<void> _loadPastSemestersFromDB() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      final dbHelper = DatabaseHelper();
      final semesters = await dbHelper.getSemesters(userId);
      
      double totalPoints = 0.0;
      double totalCredits = 0.0;
      int count = 0;

      for (var sem in semesters) {
        double sgpa = sem['sgpa'] ?? 0.0;
        double creds = sem['total_credits'] ?? 0.0;
        if (sgpa > 0 && creds > 0) {
          totalPoints += (sgpa * creds);
          totalCredits += creds;
          count++;
        }
      }

      setState(() {
        _pastSemesterCount = count;
        _totalPastCredits = totalCredits;
        if (totalCredits > 0) {
          _pastCurrentCgpa = totalPoints / totalCredits;
        }
      });
    }
  }

  void _calculateResult() {
    double totalPoints = 0.0;
    double creditsSum = 0.0;

    for (var course in _calcCourses) {
      if (course.credit > 0) {
        totalPoints += (course.credit * course.gradePoint);
        creditsSum += course.credit;
      }
    }

    setState(() {
      _currentTotalCredits = creditsSum;
      _currentCalculatedCgpa = creditsSum > 0 ? (totalPoints / creditsSum) : 0.0;
      
      if (_totalPastCredits > 0 || creditsSum > 0) {
        double allPoints = (_pastCurrentCgpa * _totalPastCredits) + (_currentCalculatedCgpa * creditsSum);
        double allCredits = _totalPastCredits + creditsSum;
        _estimatedTotalCgpa = allCredits > 0 ? (allPoints / allCredits) : 0.0;
      } else {
        _estimatedTotalCgpa = 0.0;
      }
      
      _isCalculated = true;
    });
  }

  Future<void> _saveSemesterDialog() async {
    TextEditingController semesterNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Semester', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: semesterNameController,
          decoration: InputDecoration(
            labelText: 'Semester Name (e.g. Fall 2026)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (semesterNameController.text.isNotEmpty) {
                Navigator.pop(context);
                await _saveToDatabase(semesterNameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C66A4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToDatabase(String semesterName) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      List<Map<String, dynamic>> coursesData = _calcCourses.map((c) {
        String grade = _gradeOptions.entries.firstWhere((e) => e.value == c.gradePoint, orElse: () => _gradeOptions.entries.first).key.substring(0, 2).trim();
        return {
          'course_name': c.name,
          'credit': c.credit,
          'grade': grade,
          'grade_point': c.gradePoint,
        };
      }).toList();

      final dbHelper = DatabaseHelper();
      await dbHelper.saveSemester(userId, semesterName, _currentCalculatedCgpa, _currentTotalCredits, coursesData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semester saved successfully!'), backgroundColor: Colors.green),
        );
        _loadPastSemestersFromDB();
        setState(() {
          _isCalculated = false;
          _isTotalRevealed = false;
        });
      }
    }
  }

  void _addCalcRow() {
    setState(() {
      int nextNumber = _calcCourses.length + 1;
      _calcCourses.add(Course(
        id: DateTime.now().toString(),
        name: 'Course $nextNumber',
        credit: 3.0,
        gradePoint: 4.0,
      ));
      _isCalculated = false;
      _isTotalRevealed = false;
    });
  }

  void _removeCalcRow(int index) {
    if (_calcCourses.length > 1) {
      setState(() {
        _calcCourses.removeAt(index);
        _isCalculated = false;
        _isTotalRevealed = false;
      });
    }
  }

  void _toggleTotalReveal() {
    if (!_isCalculated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please calculate your current CGPA first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _isTotalRevealed = !_isTotalRevealed;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total CGPA Info', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'This Total CGPA is calculated by combining your past $_pastSemesterCount saved semesters from the database with the current calculated CGPA.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Calculate CGPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C4380),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2C4380).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current SGPA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isCalculated ? _currentCalculatedCgpa.toStringAsFixed(2) : '0.00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleTotalReveal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.transparent : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.grey.shade100,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total CGPA',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showInfoDialog,
                                  child: Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _isTotalRevealed
                                ? Text(
                                    _estimatedTotalCgpa.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF4C66A4),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility_off_rounded,
                                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tap to\nreveal',
                                          style: TextStyle(
                                            color: isDark ? Colors.white30 : Colors.grey.shade400,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _calcCourses.length,
                  itemBuilder: (context, index) {
                    final course = _calcCourses[index];
                    String currentGradeKey = _gradeOptions.entries
                        .firstWhere((e) => e.value == course.gradePoint, orElse: () => _gradeOptions.entries.first)
                        .key;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 1.0),
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Course Name',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_calcCourses.length > 1)
                                GestureDetector(
                                  onTap: () => _removeCalcRow(index),
                                  child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 18),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 32,
                            child: TextFormField(
                              initialValue: course.name,
                              onChanged: (val) {
                                course.name = val;
                                _isCalculated = false;
                                _isTotalRevealed = false;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Credits',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<double>(
                                          value: course.credit,
                                          isExpanded: true,
                                          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade500),
                                          items: [4.0, 3.0, 2.0, 1.5, 1.0].map((c) => DropdownMenuItem(
                                            value: c, 
                                            child: Text(c.toStringAsFixed(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))
                                          )).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                course.credit = val;
                                                _isCalculated = false;
                                                _isTotalRevealed = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Grade',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: currentGradeKey,
                                          isExpanded: true,
                                          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade500),
                                          items: _gradeOptions.keys.map((key) => DropdownMenuItem(
                                            value: key, 
                                            child: Text(key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))
                                          )).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                course.gradePoint = _gradeOptions[val]!;
                                                _isCalculated = false;
                                                _isTotalRevealed = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _addCalcRow,
                  icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary, size: 18),
                  label: Text('Add Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _calculateResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C66A4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Calculate Result', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  if (_isCalculated) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saveSemesterDialog,
                          icon: const Icon(Icons.save_rounded, size: 20),
                          label: const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}