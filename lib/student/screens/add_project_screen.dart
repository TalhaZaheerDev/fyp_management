import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/project_model.dart';
import '../services/student_firestore_service.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final tech = TextEditingController();

  String? selectedSupervisor;
  int selectedWeeks = 24;

  List<Map<String, dynamic>> supervisors = [];
  final service = StudentFirestoreService();

  @override
  void initState() {
    super.initState();
    loadSupervisors();
  }

  Future<void> loadSupervisors() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'supervisor')
        .get();

    if (!mounted) return;

    setState(() {
      supervisors = snapshot.docs
          .map(
            (doc) => {'id': doc.id, 'username': doc['username'] ?? 'No Name'},
          )
          .toList();
    });
  }

  void save() async {
    final user = FirebaseAuth.instance.currentUser!;

    if (selectedSupervisor == null || title.text.isEmpty || desc.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    final project = Project(
      id: '',
      title: title.text.trim(),
      description: desc.text.trim(),
      technologies: tech.text.trim(),
      supervisor: selectedSupervisor!,
      status: "Pending",
      userId: user.uid,
      totalWeeks: selectedWeeks,
    );

    /// ✅ STEP 1: CREATE PROJECT
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .add(project.toMap());

    /// ✅ STEP 2: CREATE CHAT ROOM
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(doc.id) // 🔥 IMPORTANT: projectId
        .set({
          'participants': [user.uid, selectedSupervisor],
        });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Project Created")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Add Project",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// TITLE
            _label("Project Title"),
            _input(title, hint: "Enter project title"),

            const SizedBox(height: 15),

            /// DESCRIPTION
            _label("Description"),
            _input(desc, hint: "Enter description", maxLines: 4),

            const SizedBox(height: 15),

            /// TECHNOLOGIES
            _label("Technologies"),
            _input(tech, hint: "Flutter, Firebase, ML..."),

            const SizedBox(height: 15),

            /// SUPERVISOR
            _label("Select Supervisor"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSupervisor,
                  isExpanded: true,
                  hint: Text(
                    "Choose supervisor",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  items: supervisors.map((sup) {
                    return DropdownMenuItem<String>(
                      value: sup['id'],
                      child: Text(
                        sup['username'],
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => selectedSupervisor = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// DURATION
            _label("Project Duration"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedWeeks,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 24, child: Text("6 Months")),
                    DropdownMenuItem(value: 48, child: Text("12 Months")),
                  ],
                  onChanged: (v) {
                    setState(() => selectedWeeks = v!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Create Project",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
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
  Widget _input(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
