import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';

class StudentFirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> addProject(Project project) async {
    await _db.collection('projects').add(project.toMap());
  }

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

  Future<void> updateProject(Project project) async {
    await _db.collection('projects').doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String id) async {
    await _db.collection('projects').doc(id).delete();
  }
}
