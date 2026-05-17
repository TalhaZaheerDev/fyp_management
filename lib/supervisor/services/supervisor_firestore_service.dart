import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';

class SupervisorFirestoreService {
  final _db = FirebaseFirestore.instance;

  // 🔹 Only assigned projects
  Stream<List<Project>> getAssignedProjects(String supervisorId) {
    return _db
        .collection('projects')
        .where('supervisor', isEqualTo: supervisorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Project.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // 🔹 Update status (approve/reject)
  Future<void> updateProject(Project project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  // 🔹 Add feedback
  Future<void> addFeedback(String projectId, String comment) async {
    await _db.collection('feedback').add({
      'projectId': projectId,
      'comment': comment,
      'date': DateTime.now().toString(),
    });
  }
}
