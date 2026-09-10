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
}