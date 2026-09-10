import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const CourseCard({
    super.key,
    required this.course,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  late TextEditingController _nameController;
  late TextEditingController _creditController;

  final Map<String, double> _gradeMap = {
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.name);
    // Remove .0 if it's an integer
    String initialCredit = widget.course.credit % 1 == 0
        ? widget.course.credit.toInt().toString()
        : widget.course.credit.toString();
    _creditController = TextEditingController(text: initialCredit);
  }

  @override
  void didUpdateWidget(covariant CourseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent updates the course name (e.g. re-ordering serials), update the controller
    if (_nameController.text != widget.course.name) {
      _nameController.text = widget.course.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String currentGradeLabel = _gradeMap.entries
        .firstWhere((entry) => entry.value == widget.course.gradePoint,
            orElse: () => const MapEntry('A+ (4.0)', 4.0))
        .key;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                    onChanged: (val) => widget.course.name = val,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditController,
                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      widget.course.credit = double.tryParse(val) ?? 0.0;
                      widget.onChanged();
                    },
                    decoration: InputDecoration(
                      labelText: 'Credit',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      isDense: true,
                      // Dropdown menu added directly inside the text field with ONLY 3 and 1
                      suffixIcon: PopupMenuButton<String>(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB)),
                        onSelected: (String value) {
                          setState(() {
                            _creditController.text = value;
                            widget.course.credit = double.tryParse(value) ?? 0.0;
                            widget.onChanged();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return ['3', '1'].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: currentGradeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Grade Point',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      isDense: true,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB), size: 22),
                    items: _gradeMap.keys.map((String gradeKey) {
                      return DropdownMenuItem<String>(
                        value: gradeKey,
                        child: Text(gradeKey),
                      );
                    }).toList(),
                    onChanged: (selectedKey) {
                      if (selectedKey != null && _gradeMap.containsKey(selectedKey)) {
                        setState(() {
                          widget.course.gradePoint = _gradeMap[selectedKey]!;
                          widget.onChanged();
                        });
                      }
                    },
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