class Project {
  String id;
  String title;
  String description;
  String technologies;
  String supervisor;
  String status;
  String userId;
  int totalWeeks; // ✅ NEW

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.supervisor,
    required this.status,
    required this.userId,
    required this.totalWeeks, // ✅ NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'technologies': technologies,
      'supervisor': supervisor,
      'status': status,
      'userId': userId,
      'totalWeeks': totalWeeks, // ✅ NEW
    };
  }

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technologies: map['technologies'] ?? '',
      supervisor: map['supervisor'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      totalWeeks: map['totalWeeks'] ?? 24, // default 6 months
    );
  }
}
