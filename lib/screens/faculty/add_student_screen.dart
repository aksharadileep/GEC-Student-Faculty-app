import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _admissionNoController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController(text: 'pass123');
  final _cgpaController = TextEditingController(text: '0.0');
  
  bool _isLoading = false;
  String? _selectedBloodGroup;
  int? _nextSlNo;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _getNextSlNo();
  }

  Future<void> _getNextSlNo() async {
    try {
      // Get the maximum sl_no from students table
      final response = await Supabase.instance.client
          .from('students')
          .select('sl_no')
          .order('sl_no', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && response['sl_no'] != null) {
        setState(() {
          _nextSlNo = (response['sl_no'] as int) + 1;
        });
      } else {
        setState(() {
          _nextSlNo = 1; // Start from 1 if no records
        });
      }
    } catch (e) {
      print('Error getting next sl_no: $e');
      setState(() {
        _nextSlNo = 1; // Default to 1 on error
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime(2010),
    );
    
    if (picked != null) {
      // Format date as YYYY-MM-DD for Supabase
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Validate date format
      final dateParts = _dobController.text.split('-');
      if (dateParts.length != 3) {
        throw Exception('Invalid date format. Please use YYYY-MM-DD');
      }

      final year = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final day = int.tryParse(dateParts[2]);

      if (year == null || month == null || day == null) {
        throw Exception('Invalid date format. Please use YYYY-MM-DD');
      }

      // Create proper date string
      final formattedDate = "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

      // Get the next sl_no if not already fetched
      if (_nextSlNo == null) {
        await _getNextSlNo();
      }

      final studentData = {
        'sl_no': _nextSlNo,  // Add the sl_no field
        'name': _nameController.text.trim(),
        'admission_no': _admissionNoController.text.trim(),
        'student_id': _studentIdController.text.trim(),
        'course': _courseController.text.trim(),
        'permanent_address': _addressController.text.trim(),
        'parent_name': _parentNameController.text.trim(),
        'phone_no': _phoneController.text.trim(),
        'blood_group': _selectedBloodGroup ?? _bloodGroupController.text.trim(),
        'email': _emailController.text.trim(),
        'date_of_birth': formattedDate,
        'password': _passwordController.text.trim(),
        'cgpa': double.tryParse(_cgpaController.text) ?? 0.0,
      };

      print('Inserting student with sl_no: $_nextSlNo'); // For debugging

      final response = await Supabase.instance.client
          .from('students')
          .insert(studentData)
          .select();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student added successfully with SL No: $_nextSlNo'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _nameController.clear();
        _admissionNoController.clear();
        _studentIdController.clear();
        _courseController.clear();
        _addressController.clear();
        _parentNameController.clear();
        _phoneController.clear();
        _bloodGroupController.clear();
        _emailController.clear();
        _dobController.clear();
        setState(() {
          _selectedBloodGroup = null;
          _nextSlNo = (_nextSlNo ?? 0) + 1; // Increment for next student
        });
      }
    } catch (e) {
      print('Error details: $e'); // For debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding student: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Show next SL No if available
            if (_nextSlNo != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.numbers, color: Colors.blue.shade900),
                    const SizedBox(width: 8),
                    Text(
                      'Next Student SL No: $_nextSlNo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            
            // Name
            _buildTextField(
              _nameController, 
              'Full Name', 
              Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter name';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Admission No
            _buildTextField(
              _admissionNoController, 
              'Admission No', 
              Icons.confirmation_number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter admission no';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Student ID
            _buildTextField(
              _studentIdController, 
              'Student ID', 
              Icons.badge,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter student ID';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Course
            _buildTextField(
              _courseController, 
              'Course (e.g., B.Tech IT)', 
              Icons.school,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter course';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Address
            _buildTextField(
              _addressController, 
              'Permanent Address', 
              Icons.home, 
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter address';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Parent Name
            _buildTextField(
              _parentNameController, 
              'Parent Name', 
              Icons.family_restroom,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter parent name';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Phone
            _buildTextField(
              _phoneController, 
              'Phone Number', 
              Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter phone number';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Blood Group - Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: const Icon(Icons.bloodtype),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _bloodGroups.map((bloodGroup) {
                return DropdownMenuItem(
                  value: bloodGroup,
                  child: Text(bloodGroup),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select blood group';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Email
            _buildTextField(
              _emailController, 
              'Email', 
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter email';
                if (!value.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 10),
            
            // Date of Birth - with date picker
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  _dobController, 
                  'Date of Birth (YYYY-MM-DD)', 
                  Icons.cake,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter date of birth';
                    // Validate format YYYY-MM-DD
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return 'Use format: YYYY-MM-DD';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isLoading || _nextSlNo == null) ? null : _addStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'ADD STUDENT (SL No: ${_nextSlNo ?? "..."})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}