class ResourceModel {
  final int id;
  final String title;
  final String type;
  final String category;
  final String fileUrl;
  final String uploaderName;
  final DateTime dateUploaded;

  ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.fileUrl,
    required this.uploaderName,
    required this.dateUploaded,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    final user = map['tbl_user'];
    final uploader = user != null ? "${user['firstName']} ${user['lastName']}" : "Unknown";
    
    return ResourceModel(
      id: map['resource_id'],
      title: map['title'],
      type: map['tbl_type']?['type'] ?? "Unknown",
      category: map['tbl_category']?['category'] ?? "General",
      fileUrl: map['file_url'],
      uploaderName: uploader,
      dateUploaded: DateTime.parse(map['date_uploaded']),
    );
  }
}

class ResourceType {
  final int id;
  final String type;

  ResourceType({required this.id, required this.type});

  factory ResourceType.fromMap(Map<String, dynamic> map) {
    return ResourceType(
      id: map['type_id'],
      type: map['type'],
    );
  }
}
