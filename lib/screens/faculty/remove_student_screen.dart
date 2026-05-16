import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoveStudentScreen extends StatefulWidget {
  const RemoveStudentScreen({super.key});

  @override
  State<RemoveStudentScreen> createState() => _RemoveStudentScreenState();
}

class _RemoveStudentScreenState extends State<RemoveStudentScreen> {
  final _studentIdController = TextEditingController();
  Map<String, dynamic>? _studentData;
  bool _isLoading = false;
  bool _isSearching = false;

  Future<void> _searchStudent() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Student ID'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _studentData = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('students')
          .select('sl_no, student_id, name, admission_no, course, email, phone_no, parent_name, blood_group, cgpa')
          .eq('student_id', studentId)
          .maybeSingle();

      setState(() {
        _studentData = response != null ? Map<String, dynamic>.from(response) : null;
        _isLoading = false;
        _isSearching = false;
      });

      if (response == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No student found with ID: $studentId'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching student: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteStudent() async {
    if (_studentData == null) return;

    final studentId = _studentData!['student_id'];
    final studentName = _studentData!['name'];

    // Show confirmation dialog with student details
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '⚠️ Delete Student',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this student?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student ID: $studentId'),
                  Text('Name: $studentName'),
                  if (_studentData!['admission_no'] != null)
                    Text('Admission No: ${_studentData!['admission_no']}'),
                  if (_studentData!['course'] != null)
                    Text('Course: ${_studentData!['course']}'),
                  if (_studentData!['cgpa'] != null)
                    Text('CGPA: ${_studentData!['cgpa']}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone! All results data will also be deleted.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE PERMANENTLY'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // First delete from all result tables (maintain referential integrity)
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

      // Then delete the student
      await Supabase.instance.client
          .from('students')
          .delete()
          .eq('student_id', studentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Student "$studentName" (ID: $studentId) deleted successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Clear the form
        setState(() {
          _studentData = null;
          _studentIdController.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting student: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Student'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade900,
              Colors.red.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with warning icon
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remove Student',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Permanently delete student records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Enter Student ID',
                        hintText: 'e.g., PKD23IT001',
                        prefixIcon: const Icon(Icons.search, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _searchStudent(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _searchStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                            : const Text(
                                'SEARCH STUDENT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Student Details (if found)
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_studentData != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Student Avatar
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.red.shade100,
                                child: Text(
                                  _studentData!['name']?[0].toUpperCase() ?? '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Student Name
                              Text(
                                _studentData!['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Student ID Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'ID: ${_studentData!['student_id']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Details Grid
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      Icons.confirmation_number,
                                      'Admission No',
                                      _studentData!['admission_no'],
                                    ),
                                    _buildDetailRow(
                                      Icons.school,
                                      'Course',
                                      _studentData!['course'],
                                    ),
                                    _buildDetailRow(
                                      Icons.email,
                                      'Email',
                                      _studentData!['email'],
                                    ),
                                    _buildDetailRow(
                                      Icons.phone,
                                      'Phone',
                                      _studentData!['phone_no'],
                                    ),
                                    _buildDetailRow(
                                      Icons.family_restroom,
                                      'Parent',
                                      _studentData!['parent_name'],
                                    ),
                                    _buildDetailRow(
                                      Icons.bloodtype,
                                      'Blood Group',
                                      _studentData!['blood_group'],
                                    ),
                                    _buildDetailRow(
                                      Icons.grade,
                                      'CGPA',
                                      _studentData!['cgpa']?.toString(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Delete Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: _deleteStudent,
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text(
                                    'PERMANENTLY DELETE STUDENT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This will delete all results and personal data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }
}