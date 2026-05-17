import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../services/student_firestore_service.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController title;
  late TextEditingController desc;
  late TextEditingController tech;

  final service = StudentFirestoreService();

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.project.title);
    desc = TextEditingController(text: widget.project.description);
    tech = TextEditingController(text: widget.project.technologies);
  }

  void update() async {
    widget.project.title = title.text;
    widget.project.description = desc.text;
    widget.project.technologies = tech.text;

    await service.updateProject(widget.project);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    tech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Project")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: title),
            TextField(controller: desc),
            TextField(controller: tech),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: update, child: const Text("Update")),
          ],
        ),
      ),
    );
  }
}
