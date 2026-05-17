import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';
import '../services/student_firestore_service.dart';
import 'add_project_screen.dart';
import 'project_detail_screen.dart';
import 'profile_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  Color getStatusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.red;
    if (status == "Submitted") return Colors.blue;
    return Colors.orange;
  }

  // 🔹 progress = entries / 10 (you can adjust total weeks)
  double calculateProgress(int count) {
    double value = count / 10;
    if (value > 1) value = 1;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = StudentFirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5D6D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5D6D6),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Task List", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProjectScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<Project>>(
        stream: service.getProjects(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!;

          if (projects.isEmpty) {
            return const Center(child: Text("No Projects"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(project: p),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.folder, color: Colors.blue),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(p.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.status,
                              style: TextStyle(
                                color: getStatusColor(p.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🔹 Title
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 🔹 Description
                      Text(
                        p.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 REAL Progress from Firestore
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('progress')
                            .where('projectId', isEqualTo: p.id)
                            .snapshots(),
                        builder: (context, progressSnapshot) {
                          if (!progressSnapshot.hasData) {
                            return const LinearProgressIndicator(value: 0);
                          }

                          final docs = progressSnapshot.data!.docs;
                          double progress = calculateProgress(docs.length);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                color: Colors.black,
                                minHeight: 6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(progress * 100).toInt()}% completed",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // 🔹 Bottom Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Supervisor Assigned",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => service.deleteProject(p.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
