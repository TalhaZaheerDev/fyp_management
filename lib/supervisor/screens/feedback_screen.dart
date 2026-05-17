import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatelessWidget {
  final String projectId;

  const FeedbackScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .where('projectId', isEqualTo: projectId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No Feedback"));
          }

          return ListView(
            children: docs.map<Widget>((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['comment']),
                  subtitle: Text(doc['date']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
