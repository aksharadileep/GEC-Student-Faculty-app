import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Details', 'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];

  String _tableFor(int index) {
    switch (index) {
      case 0: return 'students';
      case 1: return 'student_results_s1';
      case 2: return 'student_results_s2';
      case 3: return 'student_results_s3';
      case 4: return 'student_results_4';   // ← fixed (was 'student_results')
      default: return 'students';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        title: const Text('Student Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue.shade400,
          labelColor: Colors.blue.shade300,
          unselectedLabelColor: Colors.white54,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          _tabs.length,
          (i) => _StudentTableTab(
            tableName: _tableFor(i),
            tabIndex: i,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Semester field definitions
// ─────────────────────────────────────────────────────────
Map<String, List<String>> _semesterSubjectFields = {
  'student_results_s1': ['mat101','pht100','est110','est130','hun101','phl120','esl130'],
  'student_results_s2': ['mat102','cyt100','est100','est120','hun102','est102','cyl120','esl120'],
  'student_results_s3': ['mat203','itt201','itt203','itt205','hut200','mcn201','itl201','itl203'],
  'student_results_4':  ['mat208','itt202','itt204','itt206','est200','mcn202','itl202','itl204','hut200'],
};

// ─────────────────────────────────────────────────────────
// Generic tab widget
// ─────────────────────────────────────────────────────────
class _StudentTableTab extends StatefulWidget {
  final String tableName;
  final int tabIndex;

  const _StudentTableTab({required this.tableName, required this.tabIndex});

  bool get isMainTable => tabIndex == 0;

  @override
  State<_StudentTableTab> createState() => _StudentTableTabState();
}

class _StudentTableTabState extends State<_StudentTableTab> {
  List<Map<String, dynamic>> _rows = [];
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
      // ── order by correct column per table ──
      final orderCol = widget.isMainTable ? 'sl_no' : 'student_id';
      final data = await Supabase.instance.client
          .from(widget.tableName)
          .select()
          .order(orderCol, ascending: true);
      setState(() {
        _rows = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Delete ────────────────────────────────────────────
  Future<void> _deleteRow(Map<String, dynamic> row) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete record for ${row['student_name'] ?? row['name'] ?? row['student_id'] ?? 'this entry'}?',
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
      if (widget.isMainTable) {
        await Supabase.instance.client
            .from(widget.tableName)
            .delete()
            .eq('admission_no', row['admission_no']);
      } else {
        await Supabase.instance.client
            .from(widget.tableName)
            .delete()
            .eq('student_id', row['student_id']);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted'), backgroundColor: Colors.green),
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

  // ── Edit ─────────────────────────────────────────────
  void _editRow(Map<String, dynamic> row) {
    widget.isMainTable ? _showEditStudentDialog(row) : _showEditSemesterDialog(row);
  }

  void _showEditStudentDialog(Map<String, dynamic> row) {
    final controllers = {
      'sl_no': TextEditingController(text: '${row['sl_no'] ?? ''}'),
      'name': TextEditingController(text: row['name'] ?? ''),
      'admission_no': TextEditingController(text: row['admission_no'] ?? ''),
      'course': TextEditingController(text: row['course'] ?? ''),
      'permanent_address': TextEditingController(text: row['permanent_address'] ?? ''),
      'parent_name': TextEditingController(text: row['parent_name'] ?? ''),
      'phone_no': TextEditingController(text: row['phone_no'] ?? ''),
      'blood_group': TextEditingController(text: row['blood_group'] ?? ''),
      'email': TextEditingController(text: row['email'] ?? ''),
      'date_of_birth': TextEditingController(text: row['date_of_birth'] ?? ''),
      'password': TextEditingController(text: row['password'] ?? ''),
      'cgpa': TextEditingController(text: '${row['cgpa'] ?? ''}'),
    };

    final fields = [
      ('sl_no', 'Serial No', TextInputType.number),
      ('name', 'Full Name', TextInputType.name),
      ('admission_no', 'Admission No', TextInputType.text),
      ('course', 'Course', TextInputType.text),
      ('permanent_address', 'Permanent Address', TextInputType.streetAddress),
      ('parent_name', 'Parent Name', TextInputType.name),
      ('phone_no', 'Phone No', TextInputType.phone),
      ('blood_group', 'Blood Group', TextInputType.text),
      ('email', 'Email', TextInputType.emailAddress),
      ('date_of_birth', 'Date of Birth (YYYY-MM-DD)', TextInputType.text),
      ('password', 'Password', TextInputType.visiblePassword),
      ('cgpa', 'CGPA', TextInputType.number),
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
              Row(children: [
                const Text('Edit Student', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(Icons.edit, color: Colors.blue.shade300, size: 20),
              ]),
              const SizedBox(height: 16),
              ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _darkTextField(controllers[f.$1]!, f.$2, keyboardType: f.$3),
              )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.from('students').update({
                        'sl_no': int.tryParse(controllers['sl_no']!.text) ?? row['sl_no'],
                        'name': controllers['name']!.text.trim(),
                        'course': controllers['course']!.text.trim(),
                        'permanent_address': controllers['permanent_address']!.text.trim(),
                        'parent_name': controllers['parent_name']!.text.trim(),
                        'phone_no': controllers['phone_no']!.text.trim(),
                        'blood_group': controllers['blood_group']!.text.trim(),
                        'email': controllers['email']!.text.trim(),
                        'date_of_birth': controllers['date_of_birth']!.text.trim(),
                        'password': controllers['password']!.text,
                        'cgpa': double.tryParse(controllers['cgpa']!.text) ?? row['cgpa'],
                      }).eq('admission_no', row['admission_no']);
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Student updated!'), backgroundColor: Colors.green),
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
                  },
                  child: const Text('UPDATE STUDENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSemesterDialog(Map<String, dynamic> row) {
    final subjectFields = _semesterSubjectFields[widget.tableName] ?? [];

    // Build controllers for all editable fields
    final nameCtrl = TextEditingController(text: row['student_name'] ?? '');
    final earnedCtrl = TextEditingController(text: '${row['earned_credits'] ?? ''}');
    final cumCtrl = TextEditingController(text: '${row['cumulative_credits'] ?? ''}');
    final sgpaCtrl = TextEditingController(text: '${row['sgpa'] ?? ''}');
    final subjectCtrls = {
      for (var s in subjectFields) s: TextEditingController(text: row[s] ?? ''),
    };
    // S3 has gender field
    final genderCtrl = TextEditingController(text: row['gender'] ?? '');

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
              Row(children: [
                Text('Edit ${widget.tableName}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(Icons.edit, color: Colors.green.shade300, size: 20),
              ]),
              const SizedBox(height: 4),
              Text('ID: ${row['student_id']}',
                  style: TextStyle(color: Colors.blue.shade300, fontSize: 13)),
              const SizedBox(height: 16),

              // Student name
              _darkTextField(nameCtrl, 'Student Name'),
              const SizedBox(height: 12),

              // Gender (S3 only)
              if (widget.tableName == 'student_results_s3') ...[
                _darkTextField(genderCtrl, 'Gender'),
                const SizedBox(height: 12),
              ],

              // Subject grades
              ...subjectFields.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _darkTextField(subjectCtrls[s]!, s.toUpperCase()),
              )),

              // Summary fields
              _darkTextField(earnedCtrl, 'Earned Credits', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _darkTextField(cumCtrl, 'Cumulative Credits', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _darkTextField(sgpaCtrl, 'SGPA', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      final updateData = <String, dynamic>{
                        'student_name': nameCtrl.text.trim(),
                        'earned_credits': int.tryParse(earnedCtrl.text.trim()),
                        'cumulative_credits': double.tryParse(cumCtrl.text.trim()),
                        'sgpa': double.tryParse(sgpaCtrl.text.trim()),
                        for (var s in subjectFields)
                          s: subjectCtrls[s]!.text.trim().isEmpty ? null : subjectCtrls[s]!.text.trim(),
                      };
                      if (widget.tableName == 'student_results_s3') {
                        updateData['gender'] = genderCtrl.text.trim();
                      }

                      await Supabase.instance.client
                          .from(widget.tableName)
                          .update(updateData)
                          .eq('student_id', row['student_id']);

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Result updated!'), backgroundColor: Colors.green),
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
                  },
                  child: const Text('UPDATE RESULT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
    widget.isMainTable ? _showAddStudentDialog() : _showAddSemesterDialog();
  }

  void _showAddStudentDialog() {
    final controllers = {
      'sl_no': TextEditingController(),
      'name': TextEditingController(),
      'admission_no': TextEditingController(),
      'course': TextEditingController(),
      'permanent_address': TextEditingController(),
      'parent_name': TextEditingController(),
      'phone_no': TextEditingController(),
      'blood_group': TextEditingController(),
      'email': TextEditingController(),
      'date_of_birth': TextEditingController(),
      'password': TextEditingController(),
      'cgpa': TextEditingController(),
    };

    final fields = [
      ('sl_no', 'Serial No', TextInputType.number),
      ('name', 'Full Name', TextInputType.name),
      ('admission_no', 'Admission No', TextInputType.text),
      ('course', 'Course', TextInputType.text),
      ('permanent_address', 'Permanent Address', TextInputType.streetAddress),
      ('parent_name', 'Parent Name', TextInputType.name),
      ('phone_no', 'Phone No', TextInputType.phone),
      ('blood_group', 'Blood Group', TextInputType.text),
      ('email', 'Email', TextInputType.emailAddress),
      ('date_of_birth', 'Date of Birth (YYYY-MM-DD)', TextInputType.text),
      ('password', 'Password', TextInputType.visiblePassword),
      ('cgpa', 'CGPA', TextInputType.number),
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
              const Text('Add New Student',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _darkTextField(controllers[f.$1]!, f.$2, keyboardType: f.$3),
              )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client.from('students').insert({
                        'sl_no': int.tryParse(controllers['sl_no']!.text) ?? 0,
                        'name': controllers['name']!.text.trim(),
                        'admission_no': controllers['admission_no']!.text.trim(),
                        'course': controllers['course']!.text.trim(),
                        'permanent_address': controllers['permanent_address']!.text.trim(),
                        'parent_name': controllers['parent_name']!.text.trim(),
                        'phone_no': controllers['phone_no']!.text.trim(),
                        'blood_group': controllers['blood_group']!.text.trim(),
                        'email': controllers['email']!.text.trim(),
                        'date_of_birth': controllers['date_of_birth']!.text.trim(),
                        'password': controllers['password']!.text,
                        'cgpa': double.tryParse(controllers['cgpa']!.text) ?? 0.0,
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Student added!'), backgroundColor: Colors.green),
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
                  },
                  child: const Text('SAVE STUDENT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSemesterDialog() {
    final subjectFields = _semesterSubjectFields[widget.tableName] ?? [];
    final studentIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final earnedCtrl = TextEditingController();
    final cumCtrl = TextEditingController();
    final sgpaCtrl = TextEditingController();
    final genderCtrl = TextEditingController();
    final subjectCtrls = {for (var s in subjectFields) s: TextEditingController()};

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
              Text('Add Result — ${widget.tableName}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _darkTextField(studentIdCtrl, 'Student ID'),
              const SizedBox(height: 12),
              _darkTextField(nameCtrl, 'Student Name'),
              const SizedBox(height: 12),
              if (widget.tableName == 'student_results_s3') ...[
                _darkTextField(genderCtrl, 'Gender'),
                const SizedBox(height: 12),
              ],
              ...subjectFields.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _darkTextField(subjectCtrls[s]!, s.toUpperCase()),
              )),
              _darkTextField(earnedCtrl, 'Earned Credits', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _darkTextField(cumCtrl, 'Cumulative Credits', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _darkTextField(sgpaCtrl, 'SGPA', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    try {
                      final insertData = <String, dynamic>{
                        'student_id': studentIdCtrl.text.trim(),
                        'student_name': nameCtrl.text.trim(),
                        'earned_credits': int.tryParse(earnedCtrl.text.trim()),
                        'cumulative_credits': double.tryParse(cumCtrl.text.trim()),
                        'sgpa': double.tryParse(sgpaCtrl.text.trim()),
                        for (var s in subjectFields)
                          s: subjectCtrls[s]!.text.trim().isEmpty ? null : subjectCtrls[s]!.text.trim(),
                      };
                      if (widget.tableName == 'student_results_s3') {
                        insertData['gender'] = genderCtrl.text.trim();
                      }

                      await Supabase.instance.client
                          .from(widget.tableName)
                          .insert(insertData);

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Record added!'), backgroundColor: Colors.green),
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
                  },
                  child: const Text('SAVE RESULT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewRow(Map<String, dynamic> row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2333),
        title: Text(row['name'] ?? row['student_name'] ?? row['student_id'] ?? 'Record',
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
                            style: TextStyle(color: Colors.blue.shade300,
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          TextSpan(
                            text: '${e.value}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
            child: const Text('CLOSE', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white60),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: const Color(0xFF161B22),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.table_rows, color: Colors.blue.shade300, size: 18),
              const SizedBox(width: 8),
              Text('${_rows.length} records in ${widget.tableName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('ADD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _rows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox, color: Colors.white24, size: 60),
                      const SizedBox(height: 12),
                      const Text('No records found',
                          style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final row = _rows[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2333),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.07)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade900.withOpacity(0.6),
                            child: Text(
                              widget.isMainTable
                                  ? '${row['sl_no'] ?? i + 1}'
                                  : '${i + 1}',
                              style: TextStyle(color: Colors.blue.shade300,
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            row['name'] ?? row['student_name'] ?? row['student_id'] ?? 'Record ${i + 1}',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            widget.isMainTable
                                ? (row['admission_no'] ?? '')
                                : 'ID: ${row['student_id'] ?? ''}  |  SGPA: ${row['sgpa'] ?? '-'}',
                            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility, color: Colors.blue.shade300, size: 20),
                                onPressed: () => _viewRow(row),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green.shade400, size: 20),
                                onPressed: () => _editRow(row),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                                onPressed: () => _deleteRow(row),
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
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
    ),
  );
}