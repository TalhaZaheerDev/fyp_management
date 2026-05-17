import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_management/models/project_model.dart';

class StudentFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// =========================
  /// PROJECT CRUD
  /// =========================

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

  /// =========================
  /// PARTIAL UPDATE
  /// =========================

  Future<void> updateProjectFields(
    String id,
    String title,
    String description,
    String technologies,
  ) async {
    await _db.collection('projects').doc(id).update({
      'title': title,
      'description': description,
      'technologies': technologies,
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _db.collection('projects').doc(id).update({'status': status});
  }

  /// =========================
  /// USER (USERNAME SUPPORT)
  /// =========================

  // ✅ Get username by UID
  Future<String?> getUsername(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['username'];
  }

  // ✅ Get full user data (username + email + role)
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  // ✅ Get email from username (CRITICAL for login logic)
  Future<String?> getEmailFromUsername(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();

    if (query.docs.isEmpty) return null;

    return query.docs.first.data()['email'];
  }
}
