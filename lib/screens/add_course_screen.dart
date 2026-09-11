import 'package:flutter/material.dart';
import '../models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? courseToEdit;
  const AddCourseScreen({super.key, this.courseToEdit});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  
  double _selectedCredit = 3.0;
  double _selectedGradePoint = 4.0;
  String _selectedSemester = 'Fall 2026';

  final List<String> _semesters = ['Fall 2026', 'Spring 2026', 'Summer 2025', 'Fall 2025'];

  final Map<String, double> _gradeMap = {
    'A+ (4.0)': 4.0, 'A (3.75)': 3.75, 'A- (3.5)': 3.5,
    'B+ (3.25)': 3.25, 'B (3.0)': 3.0, 'B- (2.75)': 2.75,
    'C+ (2.5)': 2.5, 'C (2.25)': 2.25, 'D (2.0)': 2.0, 'F (0.0)': 0.0,
  };

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _nameController.text = widget.courseToEdit!.name;
      _selectedCredit = widget.courseToEdit!.credit;
      _selectedGradePoint = widget.courseToEdit!.gradePoint;
      
      if (_semesters.contains(widget.courseToEdit!.semester)) {
        _selectedSemester = widget.courseToEdit!.semester;
      }
    }
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        id: widget.courseToEdit?.id ?? DateTime.now().toString(),
        name: _nameController.text.trim(),
        credit: _selectedCredit,
        gradePoint: _selectedGradePoint,
        semester: _selectedSemester,
      );
      Navigator.pop(context, updatedCourse);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.courseToEdit != null;
    
    String currentGradeLabel = _gradeMap.entries.firstWhere((entry) => entry.value == _selectedGradePoint).key;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add New Course', style: const TextStyle(fontWeight: FontWeight.bold)), 
        centerTitle: true, elevation: 0
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Course Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Data Structures & Algorithms',
                  filled: true, fillColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a course name' : null,
              ),
              const SizedBox(height: 24),
              
              const Text('Semester', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  filled: true, fillColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF2563EB)),
                items: _semesters.map((String sem) => DropdownMenuItem(value: sem, child: Text(sem, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedSemester = val); },
              ),
              const SizedBox(height: 24),

              const Text('Grade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: currentGradeLabel,
                decoration: InputDecoration(
                  filled: true, fillColor: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF2563EB)),
                items: _gradeMap.keys.map((String key) => DropdownMenuItem(value: key, child: Text(key, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedGradePoint = _gradeMap[val]!); },
              ),
              const SizedBox(height: 24),
              
              const Text('Credits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                      child: Text(_selectedCredit.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: Icon(Icons.remove, color: theme.colorScheme.primary), onPressed: () { if (_selectedCredit > 1.0) setState(() => _selectedCredit -= 0.5); }),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: Icon(Icons.add, color: theme.colorScheme.primary), onPressed: () { if (_selectedCredit < 6.0) setState(() => _selectedCredit += 0.5); }),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  child: Text(isEditing ? 'Update Course' : 'Add Course', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}