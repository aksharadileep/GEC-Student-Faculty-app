import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'semester_result_card.dart';
import 'semester_graph.dart';

class StudentResultView extends StatefulWidget {
  final String studentId;

  const StudentResultView({super.key, required this.studentId});

  @override
  State<StudentResultView> createState() => _StudentResultViewState();
}

class _StudentResultViewState extends State<StudentResultView> {
  int? _selectedSemester;
  Map<int, Map<String, dynamic>> _semesterResults = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllResults();
  }

  Future<void> _loadAllResults() async {
    setState(() => _isLoading = true);

    try {
      final results = <int, Map<String, dynamic>>{};
      
      // Load S1 results
      try {
        final s1Result = await Supabase.instance.client
            .from('student_results_s1')
            .select()
            .eq('student_id', widget.studentId)
            .maybeSingle();
        if (s1Result != null) {
          s1Result['semester'] = 1;
          results[1] = s1Result;
          print('✅ S1 loaded for ${widget.studentId}');
        }
      } catch (e) {
        print('❌ S1 error: $e');
      }

      // Load S2 results
      try {
        final s2Result = await Supabase.instance.client
            .from('student_results_s2')
            .select()
            .eq('student_id', widget.studentId)
            .maybeSingle();
        if (s2Result != null) {
          s2Result['semester'] = 2;
          results[2] = s2Result;
          print('✅ S2 loaded for ${widget.studentId}');
        }
      } catch (e) {
        print('❌ S2 error: $e');
      }

      // Load S3 results
      try {
        final s3Result = await Supabase.instance.client
            .from('student_results_s3')
            .select()
            .eq('student_id', widget.studentId)
            .maybeSingle();
        if (s3Result != null) {
          s3Result['semester'] = 3;
          results[3] = s3Result;
          print('✅ S3 loaded for ${widget.studentId}');
        }
      } catch (e) {
        print('❌ S3 error: $e');
      }

      // Load S4 results - from 'student_results_4' table (CORRECTED)
      try {
        print('🔍 Attempting to load S4 for ${widget.studentId} from student_results_4 table');
        final s4Result = await Supabase.instance.client
            .from('student_results_4')  // CHANGED: from 'student_results' to 'student_results_4'
            .select()
            .eq('student_id', widget.studentId)
            .maybeSingle();
        
        if (s4Result != null) {
          print('✅ S4 loaded successfully for ${widget.studentId}');
          print('📊 S4 Data: $s4Result');
          s4Result['semester'] = 4;
          results[4] = s4Result;
        } else {
          print('⚠️ No S4 result found for ${widget.studentId} in student_results_4 table');
        }
      } catch (e) {
        print('❌ S4 error: $e');
      }

      print('📊 Total semesters loaded: ${results.length}');
      if (results.containsKey(4)) {
        print('🎉 S4 is available!');
      } else {
        print('❌ S4 is NOT available');
      }

      setState(() {
        _semesterResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Fatal error in _loadAllResults: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading results: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_semesterResults.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _semesterResults.keys.map((semester) {
              bool isS4 = semester == 4;
              return FilterChip(
                label: Text(
                  'Semester $semester',
                  style: TextStyle(
                    fontWeight: isS4 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: _selectedSemester == semester,
                onSelected: (selected) {
                  setState(() {
                    _selectedSemester = selected ? semester : null;
                  });
                },
                backgroundColor: isS4 ? Colors.amber.shade100 : Colors.grey.shade200,
                selectedColor: isS4 ? Colors.amber.shade800 : Colors.blue.shade900,
                labelStyle: TextStyle(
                  color: _selectedSemester == semester 
                      ? Colors.white 
                      : (isS4 ? Colors.amber.shade900 : Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedSemester != null) ...[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SemesterGraph(
                    semester: _selectedSemester!,
                    result: _semesterResults[_selectedSemester]!,
                  ),
                  SemesterResultCard(
                    semester: _selectedSemester!,
                    result: _semesterResults[_selectedSemester]!,
                  ),
                ],
              ),
            ),
          ),
        ] else
          const Expanded(
            child: Center(
              child: Text('Select a semester to view results'),
            ),
          ),
      ],
    );
  }
}