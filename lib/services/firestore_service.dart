import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Create
  Future<void> addProject(Project project) async {
    await _db.collection('projects').add(project.toMap());
  }

  // Read (user-specific)
  Stream<List<Project>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Project.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Update
  Future<void> updateProject(Project project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  // Delete
  Future<void> deleteProject(String id) async {
    await _db.collection('projects').doc(id).delete();
  }
}
