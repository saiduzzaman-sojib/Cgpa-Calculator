import '../models/course_model.dart';

class CalculatorUtils {
  static double calculateCGPA(List<Course> courses) {
    if (courses.isEmpty) return 0.0;
    
    double totalPoints = 0;
    double totalCredits = 0;

    for (var course in courses) {
      totalPoints += course.credit * course.gradePoint;
      totalCredits += course.credit;
    }

    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }
}