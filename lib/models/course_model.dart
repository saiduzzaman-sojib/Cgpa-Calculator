class Course {
  final String id;
  String name;
  double credit;
  double gradePoint;

  Course({
    required this.id,
    this.name = '',
    this.credit = 3.0,
    this.gradePoint = 4.0,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'credit': credit,
      'gradePoint': gradePoint,
    };
  }

  
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      credit: (map['credit'] as num).toDouble(),
      gradePoint: (map['gradePoint'] as num).toDouble(),
    );
  }
}