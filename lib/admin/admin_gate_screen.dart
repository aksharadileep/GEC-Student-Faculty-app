import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';

class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen> {
  final _codeController = TextEditingController();
  bool _obscureCode = true;
  bool _isLoading = false;
  int _attempts = 0;

  static const String _secretCode = '0987654321';

  void _verify() {
    if (_codeController.text.trim() == _secretCode) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        }
      });
    } else {
      setState(() => _attempts++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid admin code. Attempt $_attempts.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      _codeController.clear();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

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
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.amber.shade700,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 48,
                            color: Colors.amber.shade400,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'ADMIN ACCESS',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter secret admin code to continue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          color: Colors.white.withOpacity(0.07),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _codeController,
                                  obscureText: _obscureCode,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '••••••••••',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      letterSpacing: 8,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureCode
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () => setState(
                                          () => _obscureCode = !_obscureCode),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.amber.shade400,
                                          width: 2),
                                    ),
                                  ),
                                  onSubmitted: (_) => _verify(),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _verify,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Icon(Icons.lock_open,
                                            color: Colors.black),
                                    label: Text(
                                      _isLoading ? 'VERIFYING...' : 'ENTER',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_attempts > 0) ...[
                          const SizedBox(height: 16),
                          Text(
                            '$_attempts failed attempt${_attempts > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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