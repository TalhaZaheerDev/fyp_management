import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatefulWidget {
  final String projectId;

  const ProgressScreen({super.key, required this.projectId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final weekController = TextEditingController();
  final taskController = TextEditingController();

  void addProgress() async {
    if (weekController.text.isEmpty || taskController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('progress').add({
      'projectId': widget.projectId,
      'week': weekController.text.trim(),
      'task': taskController.text.trim(),
      'date': FieldValue.serverTimestamp(), // ✅ FIX
    });

    weekController.clear();
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress Tracking")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: weekController,
              decoration: const InputDecoration(labelText: "Week"),
            ),
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: "Task"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addProgress,
              child: const Text("Add Progress"),
            ),

            const SizedBox(height: 10),

            // ✅ IMPORTANT
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('progress')
                    .where('projectId', isEqualTo: widget.projectId)
                    .snapshots(), // ✅ no orderBy (safe)
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No progress yet"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d = docs[i];
                      return Card(
                        child: ListTile(
                          title: Text("Week ${d['week']}"),
                          subtitle: Text(d['task']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
