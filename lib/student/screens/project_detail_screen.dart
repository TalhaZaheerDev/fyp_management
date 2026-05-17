import 'package:flutter/material.dart';
import 'package:fyp_management/models/project_model.dart';
import 'package:fyp_management/student/screens/edit_project_screen.dart';
import '../services/student_firestore_service.dart';
import 'progress_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final service = StudentFirestoreService();
    bool submitted = project.status == "Submitted";

    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Column(
        children: [
          Text(project.title),
          Text(project.description),

          ElevatedButton(
            onPressed: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProjectScreen(project: project),
                      ),
                    );
                  },
            child: const Text("Edit"),
          ),

          ElevatedButton(
            onPressed: submitted
                ? null
                : () async {
                    project.status = "Submitted";
                    await service.updateProject(project);
                    Navigator.pop(context);
                  },
            child: const Text("Submit"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressScreen(projectId: project.id),
                ),
              );
            },
            child: const Text("Progress"),
          ),
        ],
      ),
    );
  }
}
