import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FilterStudentsScreen extends StatefulWidget {
  const FilterStudentsScreen({super.key});

  @override
  State<FilterStudentsScreen> createState() => _FilterStudentsScreenState();
}

class _FilterStudentsScreenState extends State<FilterStudentsScreen> {
  final _minCgpaController = TextEditingController();
  final _maxCgpaController = TextEditingController();
  String? _selectedBloodGroup;
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = false;
  String _searchType = 'cgpa';

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  Future<void> _filterByCgpa() async {
    double? minCgpa = double.tryParse(_minCgpaController.text);
    double? maxCgpa = double.tryParse(_maxCgpaController.text);

    if (minCgpa == null && maxCgpa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one CGPA value'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For supabase_flutter ^2.0.0, we need to use a different approach
      // Let's build the query differently
      
      String query = 'SELECT * FROM students';
      List<String> conditions = [];
      List<dynamic> params = [];

      if (minCgpa != null) {
        conditions.add('cgpa >= ?');
        params.add(minCgpa);
      }
      if (maxCgpa != null) {
        conditions.add('cgpa <= ?');
        params.add(maxCgpa);
      }

      if (conditions.isNotEmpty) {
        query += ' WHERE ' + conditions.join(' AND ');
      }
      
      query += ' ORDER BY cgpa DESC';

      final response = await Supabase.instance.client
          .from('students')
          .select()
          .gte('cgpa', minCgpa ?? 0)
          .lte('cgpa', maxCgpa ?? 10)
          .order('cgpa', ascending: false);

      setState(() {
        _filteredStudents = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      if (_filteredStudents.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No students found in CGPA range'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _filterByBloodGroup() async {
    final selectedGroup = _selectedBloodGroup;
    
    if (selectedGroup == null || selectedGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a blood group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('students')
          .select()
          .eq('blood_group', selectedGroup)
          .order('name');

      setState(() {
        _filteredStudents = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });

      if (_filteredStudents.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No students found with blood group $selectedGroup'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteStudent(String studentId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $studentName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // Delete from all result tables
      await Supabase.instance.client
          .from('student_results_s1')
          .delete()
          .eq('student_id', studentId);
      
      await Supabase.instance.client
          .from('student_results_s2')
          .delete()
          .eq('student_id', studentId);
      
      await Supabase.instance.client
          .from('student_results_s3')
          .delete()
          .eq('student_id', studentId);
      
      await Supabase.instance.client
          .from('student_results_4')
          .delete()
          .eq('student_id', studentId);

      // Delete the student
      await Supabase.instance.client
          .from('students')
          .delete()
          .eq('student_id', studentId);

      // Refresh the filtered list
      if (_searchType == 'cgpa') {
        await _filterByCgpa();
      } else {
        await _filterByBloodGroup();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student $studentName deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting student: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Students'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchTypeButton('cgpa', 'CGPA Range'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSearchTypeButton('blood', 'Blood Group'),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: _searchType == 'cgpa'
                ? _buildCgpaFilter()
                : _buildBloodGroupFilter(),
          ),

          if (_filteredStudents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found ${_filteredStudents.length} students',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  if (_searchType == 'cgpa')
                    Text(
                      'CGPA Range: ${_minCgpaController.text.isNotEmpty ? _minCgpaController.text : '0'} - ${_maxCgpaController.text.isNotEmpty ? _maxCgpaController.text : '10'}',
                      style: TextStyle(color: Colors.blue.shade700),
                    )
                  else
                    Text(
                      'Blood Group: $_selectedBloodGroup',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Use filters above to search',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: Text(
                                  student['name']?[0] ?? 'S',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                student['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${student['student_id']}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getCgpaColor(student['cgpa']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'CGPA: ${student['cgpa']?.toStringAsFixed(2) ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          student['blood_group'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _buildDetailRow(
                                        Icons.confirmation_number,
                                        'Admission No',
                                        student['admission_no'],
                                      ),
                                      _buildDetailRow(
                                        Icons.school,
                                        'Course',
                                        student['course'],
                                      ),
                                      _buildDetailRow(
                                        Icons.phone,
                                        'Phone',
                                        student['phone_no'],
                                      ),
                                      _buildDetailRow(
                                        Icons.email,
                                        'Email',
                                        student['email'],
                                      ),
                                      _buildDetailRow(
                                        Icons.family_restroom,
                                        'Parent',
                                        student['parent_name'],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => _deleteStudent(
                                              student['student_id'],
                                              student['name'],
                                            ),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            label: const Text(
                                              'Delete Student',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeButton(String type, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _searchType = type;
          _filteredStudents = [];
          _minCgpaController.clear();
          _maxCgpaController.clear();
          _selectedBloodGroup = null;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _searchType == type ? Colors.blue.shade900 : Colors.grey.shade300,
        foregroundColor: _searchType == type ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildCgpaFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minCgpaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Min CGPA',
                  hintText: 'e.g., 7.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.trending_down),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _maxCgpaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Max CGPA',
                  hintText: 'e.g., 9.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.trending_up),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _filterByCgpa,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'FILTER BY CGPA',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodGroupFilter() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          decoration: InputDecoration(
            labelText: 'Select Blood Group',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.bloodtype),
          ),
          items: _bloodGroups.map((group) {
            return DropdownMenuItem(
              value: group,
              child: Text(group),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBloodGroup = value;
            });
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _filterByBloodGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'FILTER BY BLOOD GROUP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCgpaColor(dynamic cgpa) {
    if (cgpa == null) return Colors.grey;
    double value = cgpa is double ? cgpa : double.tryParse(cgpa.toString()) ?? 0;
    if (value >= 8.5) return Colors.green.shade700;
    if (value >= 7.0) return Colors.blue.shade700;
    if (value >= 5.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}