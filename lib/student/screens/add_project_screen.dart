import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';
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

    setState(() {
      supervisors = snapshot.docs
          .map((doc) => {'id': doc.id, 'email': doc['email']})
          .toList();
    });
  }

  void save() async {
    final user = FirebaseAuth.instance.currentUser!;

    final project = Project(
      id: '',
      title: title.text,
      description: desc.text,
      technologies: tech.text,
      supervisor: selectedSupervisor!,
      status: "Pending",
      userId: user.uid,
    );

    await service.addProject(project);

    if (!mounted) return; // ✅ FIX

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Project")),
      body: Column(
        children: [
          TextField(controller: title),
          TextField(controller: desc),
          TextField(controller: tech),

          DropdownButton<String>(
            value: selectedSupervisor,
            hint: const Text("Select Supervisor"),
            items: supervisors.map<DropdownMenuItem<String>>((sup) {
              return DropdownMenuItem<String>(
                value: sup['id'] as String,
                child: Text(sup['email'] as String),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                selectedSupervisor = v;
              });
            },
          ),

          ElevatedButton(onPressed: save, child: const Text("Save")),
        ],
      ),
    );
  }
}
