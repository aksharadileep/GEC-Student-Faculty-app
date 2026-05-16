import 'package:flutter/material.dart';
import 'admin_students_screen.dart';
import 'admin_faculty_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.blueGrey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      tooltip: 'Exit Admin',
                      onPressed: () {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                    const Spacer(),
                    Icon(Icons.admin_panel_settings,
                        color: Colors.amber.shade400, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        color: Colors.amber.shade400,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a category to manage records',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _AdminCategoryCard(
                        icon: Icons.school,
                        title: 'Students',
                        subtitle:
                            'Add, view, edit, delete student records\nand manage semester data',
                        color: Colors.blue.shade400,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminStudentsScreen()),
                        ),
                        tags: const ['Details', 'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
                      ),
                      const SizedBox(height: 16),
                      _AdminCategoryCard(
                        icon: Icons.person_4,
                        title: 'Faculty',
                        subtitle:
                            'Add, view, edit, delete faculty records\nand manage employee data',
                        color: Colors.green.shade400,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminFacultyScreen()),
                        ),
                        tags: const ['Details', 'Designation', 'Email'],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'GEC Admin • Restricted Access',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final List<String> tags;

  const _AdminCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    color: color.withOpacity(0.6), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}