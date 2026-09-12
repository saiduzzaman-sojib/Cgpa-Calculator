import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/database_helper.dart'; 

class SemesterReportScreen extends StatefulWidget {
  const SemesterReportScreen({super.key});

  @override
  State<SemesterReportScreen> createState() => _SemesterReportScreenState();
}

class _SemesterReportScreenState extends State<SemesterReportScreen> {
  List<Map<String, dynamic>> _semesterRecords = [];
  int? _userId;

  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _creditControllers = [];
  final List<TextEditingController> _cgpaControllers = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _initControllers() {
    for (var ctrl in _nameControllers) { ctrl.dispose(); }
    for (var ctrl in _creditControllers) { ctrl.dispose(); }
    for (var ctrl in _cgpaControllers) { ctrl.dispose(); }
    
    _nameControllers.clear();
    _creditControllers.clear();
    _cgpaControllers.clear();

    for (var record in _semesterRecords) {
      _nameControllers.add(TextEditingController(text: record['semester_name']));
      
      double cred = record['total_credits'] ?? 14.0;
      _creditControllers.add(TextEditingController(text: cred == 0.0 ? '' : (cred == cred.toInt() ? cred.toInt().toString() : cred.toString())));
      
      double cg = record['sgpa'] ?? 0.0;
      _cgpaControllers.add(TextEditingController(text: cg == 0.0 ? '' : cg.toString()));
    }
  }

  @override
  void dispose() {
    for (var ctrl in _nameControllers) { ctrl.dispose(); }
    for (var ctrl in _creditControllers) { ctrl.dispose(); }
    for (var ctrl in _cgpaControllers) { ctrl.dispose(); }
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');

    if (_userId != null) {
      final dbHelper = DatabaseHelper();
      final records = await dbHelper.getSemesters(_userId!);
      
      setState(() {
        _semesterRecords = List<Map<String, dynamic>>.from(records);
        _initControllers();
      });
    }
  }

  Future<void> _addSemesterRecord() async {
    if (_userId == null) return;
    
    final db = await DatabaseHelper().database;
    await db.insert('semesters', {
      'user_id': _userId,
      'semester_name': 'Semester ${_semesterRecords.length + 1}',
      'sgpa': 0.00,
      'total_credits': 14.0,
    });
    
    _loadRecords(); 
  }

  Future<void> _removeSemesterRecord(int index) async {
    final int semesterId = _semesterRecords[index]['id'];
    final db = await DatabaseHelper().database;
    
    await db.delete('semesters', where: 'id = ?', whereArgs: [semesterId]);
    await db.delete('courses', where: 'semester_id = ?', whereArgs: [semesterId]); 
    
    _loadRecords(); 
  }

  Future<void> _updateRecord(int id, String key, dynamic value) async {
    final db = await DatabaseHelper().database;
    await db.update('semesters', {key: value}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isPushed = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFFAFAFA),
      appBar: isPushed
          ? AppBar(
              title: const Text('Semester Report', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isPushed) ...[
                const Text(
                  'Past Semester Records',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Keep track of your past semesters to calculate your overall CGPA accurately.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _semesterRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No semesters found.\nAdd one or calculate from CGPA screen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _semesterRecords.length,
                        itemBuilder: (context, index) {
                          final int recordId = _semesterRecords[index]['id'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: _nameControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Semester Name',
                                      labelStyle: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.transparent : Colors.grey.shade200,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.transparent : Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    onChanged: (value) {
                                      _updateRecord(recordId, 'semester_name', value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _creditControllers[index],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Credits',
                                      labelStyle: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.transparent : Colors.grey.shade200,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark ? Colors.transparent : Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    onChanged: (value) {
                                      double cred = double.tryParse(value) ?? 0.0;
                                      _updateRecord(recordId, 'total_credits', cred);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _cgpaControllers[index],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'CGPA',
                                      labelStyle: TextStyle(
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                      filled: true,
                                      fillColor: isDark ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.08),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                    onChanged: (value) {
                                      double cgpa = double.tryParse(value) ?? 0.0;
                                      _updateRecord(recordId, 'sgpa', cgpa);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeSemesterRecord(index),
                                  splashRadius: 20,
                                  padding: const EdgeInsets.only(left: 4),
                                  constraints: const BoxConstraints(),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _addSemesterRecord,
                  icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
                  label: Text(
                    'Add Semester',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}