import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title: ${project.title}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text("Description: ${project.description}"),
            const SizedBox(height: 10),
            Text("Technologies: ${project.technologies}"),
            const SizedBox(height: 10),
            Text("Supervisor: ${project.supervisor}"),
            const SizedBox(height: 10),
            Text("Status: ${project.status}"),
          ],
        ),
      ),
    );
  }
}
