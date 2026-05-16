import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../student/student_profile.dart';
import '../student/semester_result_card.dart';
import '../student/semester_graph.dart';

class SearchStudentScreen extends StatefulWidget {
  const SearchStudentScreen({super.key});

  @override
  State<SearchStudentScreen> createState() => _SearchStudentScreenState();
}

class _SearchStudentScreenState extends State<SearchStudentScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _studentData;
  Map<int, Map<String, dynamic>> _semesterResults = {};
  int? _selectedSemester;
  bool _isLoading = false;
  bool _isSearching = false;

  Future<void> _searchStudent() async {
    final studentId = _searchController.text.trim();
    if (studentId.isEmpty) return;

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _studentData = null;
      _semesterResults = {};
      _selectedSemester = null;
    });

    try {
      // Search student
      final student = await Supabase.instance.client
          .from('students')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      if (student != null) {
        setState(() {
          _studentData = student;
          _isSearching = false;
        });
        
        // Load all semester results
        await _loadAllResults(studentId);
      } else {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAllResults(String studentId) async {
    try {
      final results = <int, Map<String, dynamic>>{};
      
      print('🔍 Loading results for student: $studentId');
      
      // Load S1 results
      try {
        final s1Result = await Supabase.instance.client
            .from('student_results_s1')
            .select()
            .eq('student_id', studentId)
            .maybeSingle();
        if (s1Result != null) {
          s1Result['semester'] = 1;
          results[1] = s1Result;
          print('✅ S1 loaded');
        } else {
          print('⚠️ No S1 result');
        }
      } catch (e) {
        print('❌ S1 error: $e');
      }

      // Load S2 results
      try {
        final s2Result = await Supabase.instance.client
            .from('student_results_s2')
            .select()
            .eq('student_id', studentId)
            .maybeSingle();
        if (s2Result != null) {
          s2Result['semester'] = 2;
          results[2] = s2Result;
          print('✅ S2 loaded');
        } else {
          print('⚠️ No S2 result');
        }
      } catch (e) {
        print('❌ S2 error: $e');
      }

      // Load S3 results
      try {
        final s3Result = await Supabase.instance.client
            .from('student_results_s3')
            .select()
            .eq('student_id', studentId)
            .maybeSingle();
        if (s3Result != null) {
          s3Result['semester'] = 3;
          results[3] = s3Result;
          print('✅ S3 loaded');
        } else {
          print('⚠️ No S3 result');
        }
      } catch (e) {
        print('❌ S3 error: $e');
      }

      // Load S4 results - from 'student_results_4' table (FIXED)
      try {
        print('🔍 Attempting to load S4 from student_results_4 table');
        final s4Result = await Supabase.instance.client
            .from('student_results_4')  // CHANGED: from 'student_results' to 'student_results_4'
            .select()
            .eq('student_id', studentId)
            .maybeSingle();
        
        if (s4Result != null) {
          print('✅ S4 loaded successfully');
          print('📊 S4 Data: $s4Result');
          s4Result['semester'] = 4;
          results[4] = s4Result;
        } else {
          print('⚠️ No S4 result found in student_results_4 table');
        }
      } catch (e) {
        print('❌ S4 error: $e');
      }

      print('📊 Total semesters loaded: ${results.length}');
      if (results.containsKey(4)) {
        print('🎉 S4 is available!');
      }

      setState(() {
        _semesterResults = results;
      });
    } catch (e) {
      print('❌ Error loading results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter Student ID (e.g., PKD23IT001)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _searchStudent(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isSearching ? null : _searchStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_studentData != null)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Student Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue.shade900,
                            child: Text(
                              _studentData!['name']?.substring(0, 1) ?? 'S',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _studentData!['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'CGPA: ${_studentData!['cgpa'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Personal Information
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Admission No', _studentData!['admission_no']),
                          _buildDivider(),
                          _buildInfoRow('Course', _studentData!['course']),
                          _buildDivider(),
                          _buildInfoRow('Email', _studentData!['email']),
                          _buildDivider(),
                          _buildInfoRow('Date of Birth', _studentData!['date_of_birth']),
                          _buildDivider(),
                          _buildInfoRow('Blood Group', _studentData!['blood_group']),
                          _buildDivider(),
                          _buildInfoRow('Phone', _studentData!['phone_no']),
                          _buildDivider(),
                          _buildInfoRow('Parent Name', _studentData!['parent_name']),
                          _buildDivider(),
                          _buildInfoRow('Address', _studentData!['permanent_address']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Academic Results
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Academic Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  if (_semesterResults.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No results found for this student'),
                      ),
                    )
                  else ...[
                    Wrap(
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
                    if (_selectedSemester != null) ...[
                      const SizedBox(height: 10),
                      SemesterGraph(
                        semester: _selectedSemester!,
                        result: _semesterResults[_selectedSemester]!,
                      ),
                      const SizedBox(height: 10),
                      SemesterResultCard(
                        semester: _selectedSemester!,
                        result: _semesterResults[_selectedSemester]!,
                      ),
                      
                      // Debug info - remove after testing
                      if (_selectedSemester == 4)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.green.shade50,
                            child: Text(
                              'S4 Data Loaded: ${_semesterResults[4]?.keys.join(', ')}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.grey);
  }
}