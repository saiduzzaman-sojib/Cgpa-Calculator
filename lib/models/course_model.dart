class Course {
  String id;
  String name;
  double credit;
  double gradePoint;
  String semester;

  Course({
    required this.id,
    required this.name,
    required this.credit,
    required this.gradePoint,
    this.semester = 'Fall 2026', 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credit': credit,
      'gradePoint': gradePoint,
      'semester': semester,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      credit: (map['credit'] ?? 0.0).toDouble(),
      gradePoint: (map['gradePoint'] ?? 0.0).toDouble(),
      semester: map['semester'] ?? 'Fall 2026', 
    );
  }
}