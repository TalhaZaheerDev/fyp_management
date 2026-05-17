import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_management/models/project_model.dart';
import '../services/supervisor_firestore_service.dart';
import 'project_review_screen.dart';
import 'profile_screen.dart';

class SupervisorDashboard extends StatelessWidget {
  const SupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = SupervisorFirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: service.getAssignedProjects(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!;

          if (projects.isEmpty) {
            return const Center(child: Text("No Assigned Projects"));
          }

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];

              return Card(
                child: ListTile(
                  title: Text(p.title),
                  subtitle: Text("Status: ${p.status}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectReviewScreen(project: p),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
