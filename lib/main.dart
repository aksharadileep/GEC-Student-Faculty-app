import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen_updated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase with error handling
    await Supabase.initialize(
      url: 'https://fiaqxqkkymnrimdgntgv.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpYXF4cWtreW1ucmltZGdudGd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2OTEwMTQsImV4cCI6MjA4ODI2NzAxNH0.19yGbRfWLIepLeSyyi8EILHDWbVyjhas91RaohhOhmg',
      debug: true, // Enable debug mode for development
    );
    
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Handle initialization error appropriately
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEC Sreekrishnapuram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue.shade900,
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Optional: Create a Supabase service class for better organization
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Faculty methods
  static Future<Map<String, dynamic>?> getFaculty(String employeeId) async {
    try {
      final response = await client
          .from('faculty')
          .select()
          .eq('employee_id', employeeId)
          .single();
      
      // In newer versions, response is already the data
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching faculty: $e');
      return null;
    }
  }
  
  // Student methods
  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await client
          .from('students')
          .select();
      
      // In newer versions, response is already the data
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }
}