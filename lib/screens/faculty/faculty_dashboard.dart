import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_student_screen.dart';
import 'search_student_screen.dart';
import 'filter_students_screen.dart';
import 'remove_student_screen.dart';

class FacultyDashboard extends StatefulWidget {
  final Map<String, dynamic> facultyData;

  const FacultyDashboard({super.key, required this.facultyData});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      FacultyHome(facultyData: widget.facultyData, onNavigate: _onNavigate),
      const AddStudentScreen(),
      const SearchStudentScreen(),
      const FilterStudentsScreen(),
      const RemoveStudentScreen(),
    ];
  }

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _deleteFacultyAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your faculty account? '
          'This action cannot be undone!'
        ),
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

    try {
      await Supabase.instance.client
          .from('faculty')
          .delete()
          .eq('employee_id', widget.facultyData['employee_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
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
        title: const Text(
          'Faculty',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteFacultyAccount();
              } else if (value == 'logout') {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Account'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_alt),
            label: 'Filter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline),
            label: 'Remove',
          ),
        ],
      ),
    );
  }
}

// ============== YOUR UPDATED FACULTY HOME WIDGET ==============
class FacultyHome extends StatelessWidget {
  final Map<String, dynamic> facultyData;
  final Function(int) onNavigate;

  const FacultyHome({
    super.key, 
    required this.facultyData,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Faculty Details Card - NOW WITH FULL NAME
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Circle
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          facultyData['name']?.substring(0, 1).toUpperCase() ?? 'F',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // FULL NAME as main heading
                    Text(
                      facultyData['name'] ?? 'Faculty Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    
                    // Designation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        facultyData['designation'] ?? 'Faculty',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // All Details in rows
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Employee ID
                          Row(
                            children: [
                              Icon(Icons.badge, size: 14, color: Colors.white70),
                              const SizedBox(width: 8),
                              const Text(
                                'Employee ID:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  facultyData['employee_id'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Email
                          Row(
                            children: [
                              Icon(Icons.email, size: 14, color: Colors.white70),
                              const SizedBox(width: 8),
                              const Text(
                                'Email:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  facultyData['email'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Actions Title
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // ICON BUTTONS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.person_add,
                    label: 'Add',
                    color: Colors.green,
                    index: 1,
                  ),
                  _buildIconButton(
                    icon: Icons.search,
                    label: 'Search',
                    color: Colors.blue,
                    index: 2,
                  ),
                  _buildIconButton(
                    icon: Icons.filter_alt,
                    label: 'Filter',
                    color: Colors.orange,
                    index: 3,
                  ),
                  _buildIconButton(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    color: Colors.red,
                    index: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ICON BUTTON - Small circular buttons with icons
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onNavigate(index),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}