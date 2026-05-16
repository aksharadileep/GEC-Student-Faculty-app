import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFacultyScreen extends StatefulWidget {
  const AdminFacultyScreen({super.key});

  @override
  State<AdminFacultyScreen> createState() => _AdminFacultyScreenState();
}

class _AdminFacultyScreenState extends State<AdminFacultyScreen> {
  List<Map<String, dynamic>> _faculty = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await Supabase.instance.client
          .from('faculty')
          .select()
          .order('employee_id', ascending: true);
      setState(() {
        _faculty = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Delete ───────────────────────────────────────────
  Future<void> _deleteRow(Map<String, dynamic> row) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Confirm Delete',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete faculty record for ${row['name'] ?? row['employee_id']}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('faculty')
          .delete()
          .eq('employee_id', row['employee_id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Faculty deleted'),
              backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── View ─────────────────────────────────────────────
  void _viewRow(Map<String, dynamic> row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: Text(row['name'] ?? 'Faculty Record',
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${e.key}: ',
                            style: TextStyle(
                                color: Colors.green.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          TextSpan(
                            text: '${e.value}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ]),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // ── Edit ─────────────────────────────────────────────
  void _editRow(Map<String, dynamic> row) {
    final controllers = {
      'name': TextEditingController(text: row['name'] ?? ''),
      'email': TextEditingController(text: row['email'] ?? ''),
      'designation': TextEditingController(text: row['designation'] ?? ''),
      'password': TextEditingController(text: row['password'] ?? ''),
    };

    final fields = [
      ('name', 'Full Name', TextInputType.name),
      ('email', 'Email', TextInputType.emailAddress),
      ('designation', 'Designation', TextInputType.text),
      ('password', 'Password', TextInputType.visiblePassword),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2333),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Edit Faculty',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(Icons.edit, color: Colors.green.shade300, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${row['employee_id']}',
                style: TextStyle(color: Colors.green.shade300, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...fields.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _darkTextField(
                      controllers[f.$1]!,
                      f.$2,
                      keyboardType: f.$3,
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client
                          .from('faculty')
                          .update({
                        'name': controllers['name']!.text.trim(),
                        'email': controllers['email']!.text.trim(),
                        'designation': controllers['designation']!.text.trim(),
                        'password': controllers['password']!.text,
                      }).eq('employee_id', row['employee_id']);

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Faculty updated!'),
                              backgroundColor: Colors.green),
                        );
                        _loadData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('UPDATE FACULTY',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add ──────────────────────────────────────────────
  void _showAddDialog() {
    final controllers = {
      'employee_id': TextEditingController(),
      'name': TextEditingController(),
      'email': TextEditingController(),
      'designation': TextEditingController(),
      'password': TextEditingController(),
    };

    final fields = [
      ('employee_id', 'Employee ID', TextInputType.text),
      ('name', 'Full Name', TextInputType.name),
      ('email', 'Email', TextInputType.emailAddress),
      ('designation', 'Designation', TextInputType.text),
      ('password', 'Password', TextInputType.visiblePassword),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2333),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Faculty',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...fields.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _darkTextField(
                      controllers[f.$1]!,
                      f.$2,
                      keyboardType: f.$3,
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.from('faculty').insert({
                        'employee_id':
                            controllers['employee_id']!.text.trim(),
                        'name': controllers['name']!.text.trim(),
                        'email': controllers['email']!.text.trim(),
                        'designation':
                            controllers['designation']!.text.trim(),
                        'password': controllers['password']!.text,
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Faculty added!'),
                              backgroundColor: Colors.green),
                        );
                        _loadData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('SAVE FACULTY',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        title: const Text('Faculty Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF161B22),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.green.shade300, size: 18),
                const SizedBox(width: 8),
                Text('${_faculty.length} faculty records',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('ADD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Colors.green))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade400, size: 48),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: const TextStyle(
                                      color: Colors.white60),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : _faculty.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox,
                                    color: Colors.white24, size: 60),
                                const SizedBox(height: 12),
                                const Text('No faculty records',
                                    style:
                                        TextStyle(color: Colors.white38)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _faculty.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final row = _faculty[i];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C2333),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.07)),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors
                                          .green.shade900
                                          .withOpacity(0.6),
                                      child: Text(
                                        (row['name'] as String? ?? 'F')
                                            .substring(0, 1),
                                        style: TextStyle(
                                            color: Colors.green.shade300,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      row['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      '${row['employee_id'] ?? ''} • ${row['designation'] ?? ''}',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.45),
                                          fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.visibility,
                                              color:
                                                  Colors.green.shade300,
                                              size: 20),
                                          onPressed: () => _viewRow(row),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color:
                                                  Colors.amber.shade400,
                                              size: 20),
                                          onPressed: () => _editRow(row),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red.shade400,
                                              size: 20),
                                          onPressed: () =>
                                              _deleteRow(row),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared helper
// ─────────────────────────────────────────────────────────
Widget _darkTextField(
  TextEditingController ctrl,
  String label, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: Colors.green.shade400, width: 1.5),
      ),
    ),
  );
}