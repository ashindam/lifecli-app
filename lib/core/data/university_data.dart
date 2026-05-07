// ─── Grading System Model ──────────────────────────────────────────────────

class GradeEntry {
  final String grade;
  final double points;
  final int minPercent;
  final int maxPercent;

  const GradeEntry({
    required this.grade,
    required this.points,
    required this.minPercent,
    required this.maxPercent,
  });
}

class GradingSystem {
  final String name;
  final List<GradeEntry> grades;

  const GradingSystem({required this.name, required this.grades});

  double percentToGPA(double percent) {
    for (final g in grades) {
      if (percent >= g.minPercent) return g.points;
    }
    return 0.0;
  }

  String percentToGrade(double percent) {
    for (final g in grades) {
      if (percent >= g.minPercent) return g.grade;
    }
    return 'F';
  }
}

// ─── Common Grading Systems ────────────────────────────────────────────────

/// Most public universities (DU, CU, RU, JU, KU, etc.)
const GradingSystem publicUniversityGrading = GradingSystem(
  name: 'Public University (4.00 Scale)',
  grades: [
    GradeEntry(grade: 'A+',  points: 4.00, minPercent: 80, maxPercent: 100),
    GradeEntry(grade: 'A',   points: 3.75, minPercent: 75, maxPercent: 79),
    GradeEntry(grade: 'A-',  points: 3.50, minPercent: 70, maxPercent: 74),
    GradeEntry(grade: 'B+',  points: 3.25, minPercent: 65, maxPercent: 69),
    GradeEntry(grade: 'B',   points: 3.00, minPercent: 60, maxPercent: 64),
    GradeEntry(grade: 'B-',  points: 2.75, minPercent: 55, maxPercent: 59),
    GradeEntry(grade: 'C+',  points: 2.50, minPercent: 50, maxPercent: 54),
    GradeEntry(grade: 'C',   points: 2.25, minPercent: 45, maxPercent: 49),
    GradeEntry(grade: 'D',   points: 2.00, minPercent: 40, maxPercent: 44),
    GradeEntry(grade: 'F',   points: 0.00, minPercent: 0,  maxPercent: 39),
  ],
);

/// BUET grading system
const GradingSystem buetGrading = GradingSystem(
  name: 'BUET (4.00 Scale)',
  grades: [
    GradeEntry(grade: 'A+',  points: 4.00, minPercent: 75, maxPercent: 100),
    GradeEntry(grade: 'A',   points: 3.75, minPercent: 70, maxPercent: 74),
    GradeEntry(grade: 'A-',  points: 3.50, minPercent: 65, maxPercent: 69),
    GradeEntry(grade: 'B+',  points: 3.25, minPercent: 60, maxPercent: 64),
    GradeEntry(grade: 'B',   points: 3.00, minPercent: 55, maxPercent: 59),
    GradeEntry(grade: 'B-',  points: 2.75, minPercent: 50, maxPercent: 54),
    GradeEntry(grade: 'C+',  points: 2.50, minPercent: 45, maxPercent: 49),
    GradeEntry(grade: 'C',   points: 2.25, minPercent: 40, maxPercent: 44),
    GradeEntry(grade: 'D',   points: 2.00, minPercent: 35, maxPercent: 39),
    GradeEntry(grade: 'F',   points: 0.00, minPercent: 0,  maxPercent: 34),
  ],
);

/// NSU, BRAC, EWU, UIU and most top private universities
const GradingSystem privateStandardGrading = GradingSystem(
  name: 'Private Standard (4.00 Scale)',
  grades: [
    GradeEntry(grade: 'A',   points: 4.00, minPercent: 90, maxPercent: 100),
    GradeEntry(grade: 'A-',  points: 3.70, minPercent: 85, maxPercent: 89),
    GradeEntry(grade: 'B+',  points: 3.30, minPercent: 80, maxPercent: 84),
    GradeEntry(grade: 'B',   points: 3.00, minPercent: 75, maxPercent: 79),
    GradeEntry(grade: 'B-',  points: 2.70, minPercent: 70, maxPercent: 74),
    GradeEntry(grade: 'C+',  points: 2.30, minPercent: 65, maxPercent: 69),
    GradeEntry(grade: 'C',   points: 2.00, minPercent: 60, maxPercent: 64),
    GradeEntry(grade: 'D',   points: 1.00, minPercent: 50, maxPercent: 59),
    GradeEntry(grade: 'F',   points: 0.00, minPercent: 0,  maxPercent: 49),
  ],
);

/// AIUB, DIU, BUBT and similar private universities
const GradingSystem privateExtendedGrading = GradingSystem(
  name: 'Private Extended (4.00 Scale)',
  grades: [
    GradeEntry(grade: 'A+',  points: 4.00, minPercent: 90, maxPercent: 100),
    GradeEntry(grade: 'A',   points: 3.70, minPercent: 85, maxPercent: 89),
    GradeEntry(grade: 'A-',  points: 3.30, minPercent: 80, maxPercent: 84),
    GradeEntry(grade: 'B+',  points: 3.00, minPercent: 75, maxPercent: 79),
    GradeEntry(grade: 'B',   points: 2.70, minPercent: 70, maxPercent: 74),
    GradeEntry(grade: 'B-',  points: 2.30, minPercent: 65, maxPercent: 69),
    GradeEntry(grade: 'C+',  points: 2.00, minPercent: 60, maxPercent: 64),
    GradeEntry(grade: 'C',   points: 1.70, minPercent: 55, maxPercent: 59),
    GradeEntry(grade: 'D',   points: 1.30, minPercent: 50, maxPercent: 54),
    GradeEntry(grade: 'F',   points: 0.00, minPercent: 0,  maxPercent: 49),
  ],
);

/// National University affiliated colleges
const GradingSystem nationalUniversityGrading = GradingSystem(
  name: 'National University (4.00 Scale)',
  grades: [
    GradeEntry(grade: 'A+',  points: 4.00, minPercent: 80, maxPercent: 100),
    GradeEntry(grade: 'A',   points: 3.50, minPercent: 70, maxPercent: 79),
    GradeEntry(grade: 'A-',  points: 3.25, minPercent: 65, maxPercent: 69),
    GradeEntry(grade: 'B+',  points: 3.00, minPercent: 60, maxPercent: 64),
    GradeEntry(grade: 'B',   points: 2.75, minPercent: 55, maxPercent: 59),
    GradeEntry(grade: 'B-',  points: 2.50, minPercent: 50, maxPercent: 54),
    GradeEntry(grade: 'C+',  points: 2.25, minPercent: 45, maxPercent: 49),
    GradeEntry(grade: 'C',   points: 2.00, minPercent: 40, maxPercent: 44),
    GradeEntry(grade: 'D',   points: 1.00, minPercent: 33, maxPercent: 39),
    GradeEntry(grade: 'F',   points: 0.00, minPercent: 0,  maxPercent: 32),
  ],
);

/// BMDC Medical College grading (MBBS/BDS — Bangladesh Medical & Dental Council)
const GradingSystem medicalCollegeGrading = GradingSystem(
  name: 'BMDC Medical (Percentage Scale)',
  grades: [
    GradeEntry(grade: 'Distinction', points: 4.00, minPercent: 75, maxPercent: 100),
    GradeEntry(grade: 'Credit',      points: 3.50, minPercent: 60, maxPercent: 74),
    GradeEntry(grade: 'Pass',        points: 2.00, minPercent: 50, maxPercent: 59),
    GradeEntry(grade: 'Fail',        points: 0.00, minPercent: 0,  maxPercent: 49),
  ],
);

// ─── University Model ──────────────────────────────────────────────────────

class BdUniversity {
  final String name;
  final String shortName;
  final String type; // 'Public' | 'Private'
  final String category; // 'University' | 'Medical' | 'Engineering'
  final String location;
  final GradingSystem gradingSystem;

  const BdUniversity({
    required this.name,
    required this.shortName,
    required this.type,
    this.category = 'University',
    required this.location,
    required this.gradingSystem,
  });
}

// ─── Top 50 Bangladeshi Universities ──────────────────────────────────────

const List<BdUniversity> bangladeshiUniversities = [
  // ── Public Universities ─────────────────────────────────────────────────
  BdUniversity(
    name: 'University of Dhaka',
    shortName: 'DU',
    type: 'Public',
    location: 'Dhaka',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangladesh University of Engineering & Technology',
    shortName: 'BUET',
    type: 'Public',
    location: 'Dhaka',
    gradingSystem: buetGrading,
  ),
  BdUniversity(
    name: 'University of Chittagong',
    shortName: 'CU',
    type: 'Public',
    location: 'Chittagong',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'University of Rajshahi',
    shortName: 'RU',
    type: 'Public',
    location: 'Rajshahi',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Jahangirnagar University',
    shortName: 'JU',
    type: 'Public',
    location: 'Savar, Dhaka',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangladesh Agricultural University',
    shortName: 'BAU',
    type: 'Public',
    location: 'Mymensingh',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Khulna University',
    shortName: 'KU',
    type: 'Public',
    location: 'Khulna',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Shahjalal University of Science & Technology',
    shortName: 'SUST',
    type: 'Public',
    location: 'Sylhet',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Rajshahi University of Engineering & Technology',
    shortName: 'RUET',
    type: 'Public',
    location: 'Rajshahi',
    gradingSystem: buetGrading,
  ),
  BdUniversity(
    name: 'Chittagong University of Engineering & Technology',
    shortName: 'CUET',
    type: 'Public',
    location: 'Chittagong',
    gradingSystem: buetGrading,
  ),
  BdUniversity(
    name: 'Khulna University of Engineering & Technology',
    shortName: 'KUET',
    type: 'Public',
    location: 'Khulna',
    gradingSystem: buetGrading,
  ),
  BdUniversity(
    name: 'Dhaka University of Engineering & Technology',
    shortName: 'DUET',
    type: 'Public',
    location: 'Gazipur',
    gradingSystem: buetGrading,
  ),
  BdUniversity(
    name: 'Islamic University, Kushtia',
    shortName: 'IU',
    type: 'Public',
    location: 'Kushtia',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Comilla University',
    shortName: 'CoU',
    type: 'Public',
    location: 'Comilla',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Noakhali Science and Technology University',
    shortName: 'NSTU',
    type: 'Public',
    location: 'Noakhali',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Hajee Mohammad Danesh Science & Technology University',
    shortName: 'HSTU',
    type: 'Public',
    location: 'Dinajpur',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Mawlana Bhashani Science & Technology University',
    shortName: 'MBSTU',
    type: 'Public',
    location: 'Tangail',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Jashore University of Science & Technology',
    shortName: 'JUST',
    type: 'Public',
    location: 'Jashore',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangabandhu Sheikh Mujibur Rahman Science & Technology University',
    shortName: 'BSMRSTU',
    type: 'Public',
    location: 'Gopalganj',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Begum Rokeya University',
    shortName: 'BRUR',
    type: 'Public',
    location: 'Rangpur',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Patuakhali Science and Technology University',
    shortName: 'PSTU',
    type: 'Public',
    location: 'Patuakhali',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Sher-e-Bangla Agricultural University',
    shortName: 'SAU',
    type: 'Public',
    location: 'Dhaka',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangabandhu Sheikh Mujibur Rahman Agricultural University',
    shortName: 'BSMRAU',
    type: 'Public',
    location: 'Gazipur',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangladesh University of Professionals',
    shortName: 'BUP',
    type: 'Public',
    location: 'Dhaka',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Sylhet Agricultural University',
    shortName: 'SylAU',
    type: 'Public',
    location: 'Sylhet',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Chittagong Veterinary and Animal Sciences University',
    shortName: 'CVASU',
    type: 'Public',
    location: 'Chittagong',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'National University',
    shortName: 'NU',
    type: 'Public',
    location: 'Gazipur',
    gradingSystem: nationalUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangladesh Open University',
    shortName: 'BOU',
    type: 'Public',
    location: 'Gazipur',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'University of Barisal',
    shortName: 'BU',
    type: 'Public',
    location: 'Barisal',
    gradingSystem: publicUniversityGrading,
  ),
  BdUniversity(
    name: 'Bangabandhu Sheikh Mujib Medical University',
    shortName: 'BSMMU',
    type: 'Public',
    location: 'Dhaka',
    gradingSystem: publicUniversityGrading,
  ),

  // ── Private Universities ────────────────────────────────────────────────
  BdUniversity(
    name: 'North South University',
    shortName: 'NSU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'BRAC University',
    shortName: 'BRACU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'Independent University, Bangladesh',
    shortName: 'IUB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'East West University',
    shortName: 'EWU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'United International University',
    shortName: 'UIU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'American International University - Bangladesh',
    shortName: 'AIUB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Daffodil International University',
    shortName: 'DIU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Ahsanullah University of Science & Technology',
    shortName: 'AUST',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Southeast University',
    shortName: 'SEU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Bangladesh University of Business & Technology',
    shortName: 'BUBT',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Stamford University Bangladesh',
    shortName: 'SUB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Green University of Bangladesh',
    shortName: 'GUB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'University of Liberal Arts Bangladesh',
    shortName: 'ULAB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateStandardGrading,
  ),
  BdUniversity(
    name: 'Manarat International University',
    shortName: 'MIU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Primeasia University',
    shortName: 'PAU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'World University of Bangladesh',
    shortName: 'WUB',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Uttara University',
    shortName: 'UU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Metropolitan University',
    shortName: 'MU',
    type: 'Private',
    location: 'Sylhet',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'BGMEA University of Fashion & Technology',
    shortName: 'BUFT',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),
  BdUniversity(
    name: 'Central Women\'s University',
    shortName: 'CWU',
    type: 'Private',
    location: 'Dhaka',
    gradingSystem: privateExtendedGrading,
  ),

  // ── Public Medical Colleges ────────────────────────────────────────────
  BdUniversity(
    name: 'Dhaka Medical College',
    shortName: 'DMC',
    type: 'Public',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Sir Salimullah Medical College',
    shortName: 'SSMC',
    type: 'Public',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Chittagong Medical College',
    shortName: 'CMC',
    type: 'Public',
    category: 'Medical',
    location: 'Chittagong',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Rajshahi Medical College',
    shortName: 'RMC',
    type: 'Public',
    category: 'Medical',
    location: 'Rajshahi',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Mymensingh Medical College',
    shortName: 'MMC',
    type: 'Public',
    category: 'Medical',
    location: 'Mymensingh',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Sylhet MAG Osmani Medical College',
    shortName: 'SOMC',
    type: 'Public',
    category: 'Medical',
    location: 'Sylhet',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Sher-E-Bangla Medical College',
    shortName: 'SBMC',
    type: 'Public',
    category: 'Medical',
    location: 'Barisal',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Rangpur Medical College',
    shortName: 'RpMC',
    type: 'Public',
    category: 'Medical',
    location: 'Rangpur',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Shaheed Ziaur Rahman Medical College',
    shortName: 'SZRMC',
    type: 'Public',
    category: 'Medical',
    location: 'Bogura',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Khulna Medical College',
    shortName: 'KMC',
    type: 'Public',
    category: 'Medical',
    location: 'Khulna',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Faridpur Medical College',
    shortName: 'FMC',
    type: 'Public',
    category: 'Medical',
    location: 'Faridpur',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Mugda Medical College',
    shortName: 'MugMC',
    type: 'Public',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Abdul Malek Ukil Medical College',
    shortName: 'AMUMC',
    type: 'Public',
    category: 'Medical',
    location: 'Noakhali',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'M Abdur Rahim Medical College',
    shortName: 'MARMC',
    type: 'Public',
    category: 'Medical',
    location: 'Dinajpur',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Sheikh Hasina Medical College',
    shortName: 'SHMC',
    type: 'Public',
    category: 'Medical',
    location: 'Tangail',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Colonel Malek Medical College',
    shortName: 'CMMC',
    type: 'Public',
    category: 'Medical',
    location: 'Manikganj',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Shaheed Tajuddin Ahmad Medical College',
    shortName: 'STAMC',
    type: 'Public',
    category: 'Medical',
    location: 'Gazipur',
    gradingSystem: medicalCollegeGrading,
  ),

  // ── Private Medical Colleges ───────────────────────────────────────────
  BdUniversity(
    name: 'Ibrahim Medical College (BIRDEM)',
    shortName: 'IMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Holy Family Red Crescent Medical College',
    shortName: 'HFRCMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Enam Medical College & Hospital',
    shortName: 'EMCH',
    type: 'Private',
    category: 'Medical',
    location: 'Savar, Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Popular Medical College',
    shortName: 'PMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Delta Medical College',
    shortName: 'DMCol',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Uttara Adhunik Medical College',
    shortName: 'UAMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Green Life Medical College',
    shortName: 'GLMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Ad-Din Women\'s Medical College',
    shortName: 'AWMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Z H Sikder Women\'s Medical College',
    shortName: 'ZHSWMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Labaid Medical College & Hospital',
    shortName: 'LMCH',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Bangladesh Medical College',
    shortName: 'BMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Marks Medical College & Hospital',
    shortName: 'MarMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Kumudini Women\'s Medical College',
    shortName: 'KWMC',
    type: 'Private',
    category: 'Medical',
    location: 'Tangail',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Tairunnessa Memorial Medical College',
    shortName: 'TMMC',
    type: 'Private',
    category: 'Medical',
    location: 'Gazipur',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'National Medical College',
    shortName: 'NMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Ibn Sina Medical College',
    shortName: 'ISMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Islami Bank Medical College',
    shortName: 'IBMC',
    type: 'Private',
    category: 'Medical',
    location: 'Rajshahi',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Central Medical College',
    shortName: 'CentMC',
    type: 'Private',
    category: 'Medical',
    location: 'Comilla',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Parkview Medical College',
    shortName: 'PvMC',
    type: 'Private',
    category: 'Medical',
    location: 'Sylhet',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Shaheed Monsur Ali Medical College',
    shortName: 'SMAMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
  BdUniversity(
    name: 'Anwer Khan Modern Medical College',
    shortName: 'AKMMC',
    type: 'Private',
    category: 'Medical',
    location: 'Dhaka',
    gradingSystem: medicalCollegeGrading,
  ),
];
