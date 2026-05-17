import 'package:flutter/material.dart';
import 'package:fyp_management/models/project_model.dart';
import '../services/supervisor_firestore_service.dart';
import 'feedback_screen.dart';

class ProjectReviewScreen extends StatefulWidget {
  final Project project;

  const ProjectReviewScreen({super.key, required this.project});

  @override
  State<ProjectReviewScreen> createState() => _ProjectReviewScreenState();
}

class _ProjectReviewScreenState extends State<ProjectReviewScreen> {
  final feedbackController = TextEditingController();
  final service = SupervisorFirestoreService();

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    bool isFinal = p.status == "Approved" || p.status == "Rejected";

    Color getStatusColor() {
      if (p.status == "Approved") return Colors.green;
      if (p.status == "Rejected") return Colors.red;
      return Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Review Project")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(p.description),

            const SizedBox(height: 12),

            // ✅ STATUS
            Text(
              "Status: ${p.status}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getStatusColor(),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ APPROVE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFinal ? Colors.grey : Colors.green,
              ),
              onPressed: isFinal
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Approval"),
                          content: const Text(
                            "Are you sure you want to approve this project?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Approve"),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      p.status = "Approved";
                      await service.updateProject(p);

                      if (!mounted) return;

                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Project Approved")),
                      );
                    },
              child: const Text("Approve"),
            ),

            const SizedBox(height: 10),

            // ❌ REJECT BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFinal ? Colors.grey : Colors.red,
              ),
              onPressed: isFinal
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Rejection"),
                          content: const Text(
                            "Are you sure you want to reject this project?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Reject"),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      p.status = "Rejected";
                      await service.updateProject(p);

                      if (!mounted) return;

                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Project Rejected")),
                      );
                    },
              child: const Text("Reject"),
            ),

            const SizedBox(height: 20),

            // ✅ FEEDBACK INPUT
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: "Add Feedback",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                if (feedbackController.text.isEmpty) return;

                await service.addFeedback(p.id, feedbackController.text.trim());

                feedbackController.clear();

                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Feedback Added")));
              },
              child: const Text("Submit Feedback"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackScreen(projectId: p.id),
                  ),
                );
              },
              child: const Text("View Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
