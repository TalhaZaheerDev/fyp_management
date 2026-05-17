import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp_management/models/project_model.dart';
import '../services/student_firestore_service.dart';
import 'progress_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final techController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.project.title;
    descController.text = widget.project.description;
    techController.text = widget.project.technologies ?? "";
  }

  Future<void> updateProject() async {
    setState(() => isSaving = true);

    await StudentFirestoreService().updateProjectFields(
      widget.project.id,
      titleController.text.trim(),
      descController.text.trim(),
      techController.text.trim(),
    );

    setState(() => isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Updated")));
  }

  Future<void> submitProject() async {
    await StudentFirestoreService().updateStatus(
      widget.project.id,
      "Submitted",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool submitted = widget.project.status == "Submitted";

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Project Details",
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
            _input(titleController, enabled: !submitted),

            const SizedBox(height: 15),

            /// DESCRIPTION
            _label("Description"),
            _input(descController, maxLines: 4, enabled: !submitted),

            const SizedBox(height: 15),

            /// TECHNOLOGIES
            _label("Technologies"),
            _input(techController, enabled: !submitted),

            const SizedBox(height: 15),

            /// SUPERVISOR
            _label("Supervisor"),
            _readonlyBox(widget.project.supervisor ?? "N/A"),

            const SizedBox(height: 15),

            /// STATUS
            _label("Status"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(widget.project.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.project.status,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _statusColor(widget.project.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitted || isSaving ? null : updateProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitted ? null : submitProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit Project",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// PROGRESS BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgressScreen(
                        projectId: widget.project.id,
                        totalWeeks: widget.project.totalWeeks, // ✅ ADD THIS
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View Progress",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 30),
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
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
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

  /// READONLY BOX
  Widget _readonlyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12)),
    );
  }

  Color _statusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.red;
    if (status == "Submitted") return Colors.blue;
    return Colors.orange;
  }
}
