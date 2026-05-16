import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/project_model.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final tech = TextEditingController();
  final supervisor = TextEditingController();

  final service = FirestoreService();
  bool isLoading = false;

  void save() async {
    print("SAVE CLICKED");

    try {
      if (title.text.isEmpty ||
          desc.text.isEmpty ||
          tech.text.isEmpty ||
          supervisor.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      setState(() => isLoading = true);

      final project = Project(
        id: '',
        title: title.text.trim(),
        description: desc.text.trim(),
        technologies: tech.text.trim(),
        supervisor: supervisor.text.trim(),
        status: "Pending",
        userId: user.uid,
      );

      print("Before Firestore");

      await service.addProject(project);

      print("After Firestore");

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Project Saved")));

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);

      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    tech.dispose();
    supervisor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Project")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: tech,
                decoration: const InputDecoration(labelText: "Technologies"),
              ),
              TextField(
                controller: supervisor,
                decoration: const InputDecoration(labelText: "Supervisor"),
              ),
              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: save, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
