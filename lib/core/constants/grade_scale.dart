class GradeScale {
  GradeScale._();

  static const Map<String, double> gradePoints = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'D': 1.0,
    'F': 0.0,
  };

  static const List<String> gradeLetters = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'];

  static String getLetterGrade(double score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 65) return 'B-';
    if (score >= 60) return 'C+';
    if (score >= 55) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  static double getGradePoint(String letter) => gradePoints[letter] ?? 0.0;

  static double calculateGPA(List<MapEntry<double, int>> gradeCredits) {
    if (gradeCredits.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final entry in gradeCredits) {
      totalPoints += entry.key * entry.value;
      totalCredits += entry.value;
    }
    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }
}
