import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../student/screens/student_dashboard.dart';
import '../supervisor/screens/supervisor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => checkUser()); // ✅ safe call
  }

  Future<void> checkUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // 🔴 No user → Login
      if (user == null) {
        navigate(const LoginScreen());
        return;
      }

      // 🔴 Get Firestore user
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // 🔴 If doc missing → Login
      if (!doc.exists) {
        navigate(const LoginScreen());
        return;
      }

      final data = doc.data();

      // 🔴 Null safety
      final role = data?['role'];

      if (role == "student") {
        navigate(const StudentDashboard());
      } else if (role == "supervisor") {
        navigate(const SupervisorDashboard());
      } else {
        // fallback
        navigate(const LoginScreen());
      }
    } catch (e) {
      debugPrint("SPLASH ERROR: $e");
      navigate(const LoginScreen());
    }
  }

  // ✅ Safe navigation (prevents context crash)
  void navigate(Widget screen) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
