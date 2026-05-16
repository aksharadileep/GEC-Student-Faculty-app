import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SemesterGraph extends StatelessWidget {
  final int semester;
  final Map<String, dynamic> result;

  const SemesterGraph({
    super.key,
    required this.semester,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = _getSubjectsWithGrades();
    
    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 320,
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semester $semester Performance',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Grade Points',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 || value.toInt() >= subjects.length) {
                              return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getShortSubjectName(subjects[value.toInt()].name),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            if (value == 2) return const Text('2');
                            if (value == 4) return const Text('4');
                            if (value == 6) return const Text('6');
                            if (value == 8) return const Text('8');
                            if (value == 10) return const Text('10');
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    minX: 0,
                    maxX: subjects.length.toDouble() - 1,
                    minY: 0,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(subjects.length, (index) {
                          return FlSpot(
                            index.toDouble(),
                            _gradeToValue(subjects[index].grade),
                          );
                        }),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: Colors.blue.shade700,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final grade = subjects[index].grade;
                            return FlDotCirclePainter(
                              radius: 6,
                              color: _getGradeColor(grade),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.shade100.withOpacity(0.3),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade200.withOpacity(0.4),
                              Colors.blue.shade50.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= subjects.length) {
                              return null;
                            }
                            return LineTooltipItem(
                              '${subjects[index].name}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Grade: ${subjects[index].grade}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('S (10.0)', Colors.green.shade700),
                    _buildLegendItem('A+ (9.5)', Colors.green.shade500),
                    _buildLegendItem('A (9.0)', Colors.lightGreen.shade700),
                    _buildLegendItem('B+ (8.0)', Colors.blue.shade600),
                    _buildLegendItem('B (7.0)', Colors.blue.shade400),
                    _buildLegendItem('C+ (6.0)', Colors.orange.shade700),
                    _buildLegendItem('C (5.0)', Colors.orange.shade500),
                    _buildLegendItem('D (4.5)', Colors.amber.shade800),
                    _buildLegendItem('P (4.0)', Colors.amber.shade600),
                    _buildLegendItem('F (1.0)', Colors.red.shade700),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  List<_SubjectGrade> _getSubjectsWithGrades() {
    List<_SubjectGrade> subjects = [];
    final excludeKeys = [
      'student_id', 'student_name', 'earned_credits', 
      'cumulative_credits', 'sgpa', 'semester', 'gender',
      'id', 'created_at'
    ];
    
    result.forEach((key, value) {
      if (!excludeKeys.contains(key) && value != null && value.toString().isNotEmpty) {
        subjects.add(_SubjectGrade(_formatSubjectCode(key), value.toString()));
      }
    });
    
    // Sort subjects by code for consistent display
    subjects.sort((a, b) => a.name.compareTo(b.name));
    
    return subjects;
  }

  String _formatSubjectCode(String code) {
    // Format subject codes for better readability
    switch (code.toLowerCase()) {
      // S1 Subjects
      case 'mat101': return 'MAT101';
      case 'pht100': return 'PHT100';
      case 'est110': return 'EST110';
      case 'est130': return 'EST130';
      case 'hun101': return 'HUN101';
      case 'phl120': return 'PHL120';
      case 'esl130': return 'ESL130';
      
      // S2 Subjects
      case 'mat102': return 'MAT102';
      case 'cyt100': return 'CYT100';
      case 'est100': return 'EST100';
      case 'est120': return 'EST120';
      case 'hun102': return 'HUN102';
      case 'est102': return 'EST102';
      case 'cyl120': return 'CYL120';
      case 'esl120': return 'ESL120';
      
      // S3 Subjects
      case 'mat203': return 'MAT203';
      case 'itt201': return 'ITT201';
      case 'itt203': return 'ITT203';
      case 'itt205': return 'ITT205';
      case 'hut200': return 'HUT200';
      case 'mcn201': return 'MCN201';
      case 'itl201': return 'ITL201';
      case 'itl203': return 'ITL203';
      
      // S4 Subjects
      case 'mat208': return 'MAT208';
      case 'itt202': return 'ITT202';
      case 'itt204': return 'ITT204';
      case 'itt206': return 'ITT206';
      case 'est200': return 'EST200';
      case 'mcn202': return 'MCN202';
      case 'itl202': return 'ITL202';
      case 'itl204': return 'ITL204';
      
      default: return code.toUpperCase();
    }
  }

  String _getShortSubjectName(String fullCode) {
    // Return just the subject code (e.g., "MAT101")
    return fullCode;
  }

  double _gradeToValue(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
        return 10.0;
      case 'A+':
        return 9.5;
      case 'A':
        return 9.0;
      case 'B+':
        return 8.0;
      case 'B':
        return 7.0;
      case 'C+':
        return 6.0;
      case 'C':
        return 5.0;
      case 'D':
        return 4.5;
      case 'P':
        return 4.0;
      case 'F':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'S':
        return Colors.green.shade700;
      case 'A+':
        return Colors.green.shade500;
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
        return Colors.grey;
    }
  }
}

class _SubjectGrade {
  final String name;
  final String grade;

  _SubjectGrade(this.name, this.grade);
}