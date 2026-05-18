import 'package:flutter/material.dart';

class SemesterResultCard extends StatelessWidget {
  final int semester;
  final Map<String, dynamic> result;

  const SemesterResultCard({
    super.key,
    required this.semester,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semester header with SGPA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    semester == 4 ? Colors.amber.shade800 : Colors.blue.shade800,
                    semester == 4 ? Colors.amber.shade600 : Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semester $semester Results',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SGPA: ${_formatSGPA(result['sgpa'])}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: semester == 4 ? Colors.amber.shade800 : Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Credits info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCreditInfo(
                    'Earned Credits',
                    _formatCredit(result['earned_credits']),
                    Icons.star,
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.shade400),
                  _buildCreditInfo(
                    'Cumulative Credits',
                    _formatCredit(result['cumulative_credits']),
                    Icons.trending_up,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subjects and Grades
            const Text(
              'Subject Grades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._buildSubjectGrades(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Returns the attempt count for a subject in S1, or null if not S1 / no attempt key.
  int? _getAttemptCount(String subjectCode) {
    if (semester != 1) return null;
    final attemptKey = '${subjectCode.toLowerCase()}_attempt';
    final value = result[attemptKey];
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  /// Builds a small attempt badge widget.
  Widget _buildAttemptBadge(int attempts) {
    final isFirstAttempt = attempts <= 1;
    final color = isFirstAttempt ? Colors.green.shade600 : Colors.orange.shade700;
    final label = isFirstAttempt
        ? '1st attempt'
        : 'Attempt $attempts';

    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFirstAttempt ? Icons.check_circle_outline : Icons.replay,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubjectGrades() {
    List<Widget> subjects = [];

    // Define the order of subjects for S4 based on your table structure
    final List<String> s4SubjectOrder = [
      'mat208', 'itt202', 'itt204', 'itt206',
      'est200', 'mcn202', 'itl202', 'itl204', 'hut200'
    ];

    // S1 subjects in order
    final List<String> s1SubjectOrder = [
      'mat101', 'pht100', 'est110', 'est130',
      'hun101', 'phl120', 'esl130'
    ];

    final excludeKeys = [
      'student_id', 'student_name', 'earned_credits',
      'cumulative_credits', 'sgpa', 'semester', 'gender',
      'id', 'created_at',
      // Exclude attempt columns from grade display
      'mat101_attempt', 'pht100_attempt', 'est110_attempt', 'est130_attempt',
      'hun101_attempt', 'phl120_attempt', 'esl130_attempt',
    ];

    Iterable<String> subjectKeys;

    if (semester == 4) {
      subjectKeys = s4SubjectOrder.where((key) =>
          result.containsKey(key) &&
          result[key] != null &&
          result[key].toString().isNotEmpty);
    } else if (semester == 1) {
      subjectKeys = s1SubjectOrder.where((key) =>
          result.containsKey(key) &&
          result[key] != null &&
          result[key].toString().isNotEmpty);
    } else {
      subjectKeys = result.keys.where((key) =>
          !excludeKeys.contains(key) &&
          result[key] != null &&
          result[key].toString().isNotEmpty).toList()
        ..sort();
    }

    for (String key in subjectKeys) {
      final value = result[key].toString();
      final isBacklog = value == 'F';
      final attemptCount = _getAttemptCount(key);

      subjects.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isBacklog ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isBacklog ? Colors.red.shade200 : Colors.grey.shade300,
              width: isBacklog ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSubjectCode(key, semester),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isBacklog)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'BACKLOG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    // Show attempt badge for S1 subjects
                    if (attemptCount != null && attemptCount > 0)
                      _buildAttemptBadge(attemptCount),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isBacklog ? Colors.red : _getGradeColor(value),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (isBacklog ? Colors.red : _getGradeColor(value))
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (subjects.isEmpty) {
      subjects.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No subject grades found'),
          ),
        ),
      );
    }

    return subjects;
  }

  String _formatSubjectCode(String code, int semester) {
    if (semester == 4) {
      switch (code.toLowerCase()) {
        case 'mat208': return 'MAT208 - Transform Techniques & PDE';
        case 'itt202': return 'ITT202 - Computer Organization';
        case 'itt204': return 'ITT204 - Object Oriented Programming';
        case 'itt206': return 'ITT206 - Database Management Systems';
        case 'est200': return 'EST200 - Design & Engineering';
        case 'mcn202': return 'MCN202 - Constitution of India';
        case 'itl202': return 'ITL202 - OOP Lab';
        case 'itl204': return 'ITL204 - DBMS Lab';
        case 'hut200': return 'HUT200 - Professional Ethics';
        default: return code.toUpperCase();
      }
    } else {
      switch (code.toLowerCase()) {
        // S1 Subjects
        case 'mat101': return 'MAT101 - Linear Algebra & Calculus';
        case 'pht100': return 'PHT100 - Engineering Physics A';
        case 'est110': return 'EST110 - Engineering Mechanics';
        case 'est130': return 'EST130 - Basics of Electrical Engg';
        case 'hun101': return 'HUN101 - Life Skills';
        case 'phl120': return 'PHL120 - Physics Lab';
        case 'esl130': return 'ESL130 - Electrical Engg Lab';

        // S2 Subjects
        case 'mat102': return 'MAT102 - Vector Calculus & ODE';
        case 'cyt100': return 'CYT100 - Engineering Chemistry';
        case 'est100': return 'EST100 - Engineering Mechanics';
        case 'est120': return 'EST120 - Basics of Civil Engg';
        case 'hun102': return 'HUN102 - Professional Communication';
        case 'est102': return 'EST102 - Programming in C';
        case 'cyl120': return 'CYL120 - Chemistry Lab';
        case 'esl120': return 'ESL120 - Civil Engg Lab';

        // S3 Subjects
        case 'mat203': return 'MAT203 - Discrete Mathematical Structures';
        case 'itt201': return 'ITT201 - Data Structures';
        case 'itt203': return 'ITT203 - Digital System Design';
        case 'itt205': return 'ITT205 - Problem Solving using Python';
        case 'hut200': return 'HUT200 - Professional Ethics';
        case 'mcn201': return 'MCN201 - Sustainable Engineering';
        case 'itl201': return 'ITL201 - Data Structures Lab';
        case 'itl203': return 'ITL203 - Programming & System Utilities Lab';

        default: return code.toUpperCase();
      }
    }
  }

  String _formatSGPA(dynamic sgpa) {
    if (sgpa == null) return 'N/A';
    if (sgpa is double) return sgpa.toStringAsFixed(2);
    if (sgpa is int) return sgpa.toString();
    return sgpa.toString();
  }

  String _formatCredit(dynamic credit) {
    if (credit == null) return 'N/A';
    if (credit is double) return credit.toStringAsFixed(1);
    if (credit is int) return credit.toString();
    return credit.toString();
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
      case 'A+':
        return Colors.green.shade700;
      case 'A':
        return Colors.lightGreen.shade700;
      case 'B+':
        return Colors.blue.shade600;
      case 'B':
        return Colors.blue.shade400;
      case 'C+':
        return Colors.orange.shade700;
      case 'C':
        return Colors.orange.shade500;
      case 'D':
        return Colors.amber.shade800;
      case 'P':
        return Colors.amber.shade600;
      case 'F':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}