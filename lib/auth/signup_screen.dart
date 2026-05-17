import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  String role = "student";
  bool isLoading = false;
  bool showPassword = false;

  String usernameStatus = "";
  Color statusColor = Colors.grey;
  bool isChecking = false;

  List<String> suggestions = [];
  Timer? _debounce;

  /// LOGIC (UNCHANGED)
  Future<void> checkUsername(String username) async {
    username = username.toLowerCase();

    if (username.length < 4) {
      setState(() {
        usernameStatus = "Too short";
        statusColor = Colors.orange;
        suggestions = [];
      });
      return;
    }

    setState(() {
      isChecking = true;
      usernameStatus = "Checking...";
      statusColor = Colors.grey;
    });

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (!mounted) return;

    if (query.docs.isEmpty) {
      setState(() {
        usernameStatus = "Username available";
        statusColor = Colors.green;
        isChecking = false;
        suggestions = [];
      });
    } else {
      List<String> temp = [
        "${username}_01",
        "${username}_dev",
        "${username}123",
        "${username}_${DateTime.now().second}",
      ];

      setState(() {
        usernameStatus = "Username taken";
        statusColor = Colors.red;
        isChecking = false;
        suggestions = temp;
      });
    }
  }

  Future<void> signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim().toLowerCase();

    if (email.isEmpty || password.isEmpty || username.isEmpty) return;

    try {
      setState(() => isLoading = true);

      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existing.docs.isNotEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Username already taken")));
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'role': role,
      });

      if (!mounted) return;

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                /// HEADLINE
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                /// SUBTEXT
                Text(
                  "Register to manage your Final Year Project efficiently.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                /// USERNAME
                _label("Username"),
                _inputField(
                  controller: usernameController,
                  hint: "username123",
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();

                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      checkUsername(value.trim());
                    });
                  },
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    if (isChecking)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      usernameStatus,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),

                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: suggestions.map((s) {
                      return GestureDetector(
                        onTap: () {
                          usernameController.text = s;
                          checkUsername(s);
                        },
                        child: Chip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          backgroundColor: const Color(0xFFF1F3F6),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 15),

                /// EMAIL
                _label("Email"),
                _inputField(
                  controller: emailController,
                  hint: "john.doe@gmail.com",
                ),

                const SizedBox(height: 15),

                /// PASSWORD
                _label("Password"),
                _inputField(
                  controller: passwordController,
                  hint: "Enter password",
                  isPassword: true,
                ),

                const SizedBox(height: 15),

                /// ROLE
                _label("Select Role"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: role,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: "student",
                          child: Text("Student"),
                        ),
                        DropdownMenuItem(
                          value: "supervisor",
                          child: Text("Supervisor"),
                        ),
                      ],
                      onChanged: (v) => setState(() => role = v!),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Account",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                /// LOGIN NAV
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// LABEL
  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: const Color.fromARGB(221, 123, 123, 123),
      ),
    );
  }

  /// INPUT
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !showPassword : false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onPressed: () => setState(() => showPassword = !showPassword),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
