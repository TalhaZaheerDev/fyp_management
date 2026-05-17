import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';
import 'package:fyp_management/chat/chat_list_screen.dart'; // ✅ NEW
import '../services/supervisor_firestore_service.dart';
import 'project_review_screen.dart';
import 'profile_screen.dart';

class SupervisorDashboard extends StatelessWidget {
  const SupervisorDashboard({super.key});

  Color getStatusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.red;
    if (status == "Submitted") return Colors.blue;
    return Colors.orange;
  }

  double calculateProgress(int count, int totalWeeks) {
    double value = count / totalWeeks;
    if (value > 1) value = 1;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = SupervisorFirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,

      /// ✅ FLOATING CHAT BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatListScreen(isStudent: false),
            ),
          );
        },
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Supervisor Panel",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
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

      body: StreamBuilder<List<Project>>(
        stream: service.getAssignedProjects(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data!;

          if (projects.isEmpty) {
            return Center(
              child: Text(
                "No Assigned Projects",
                style: GoogleFonts.poppins(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectReviewScreen(project: p),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.folder_open, color: Colors.black87),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(p.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: getStatusColor(p.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// TITLE
                      Text(
                        p.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// DESCRIPTION
                      Text(
                        p.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// STUDENT USERNAME
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(p.userId)
                            .get(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text("Student: ...");
                          }

                          final data =
                              snap.data!.data() as Map<String, dynamic>?;

                          final username = data?['username'] ?? "Unknown";

                          return Text(
                            "Student: $username",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      /// PROGRESS
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

                          double progress = calculateProgress(
                            docs.length,
                            p.totalWeeks,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  color: Colors.black,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(progress * 100).toInt()}% completed (${docs.length}/${p.totalWeeks} weeks)",
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                            ],
                          );
                        },
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
