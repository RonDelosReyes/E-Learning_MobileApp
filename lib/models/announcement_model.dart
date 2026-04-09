class AnnouncementModel {
  final int postId;
  final int userNo;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isPinned;
  final DateTime createdAt;
  final String? authorName;

  AnnouncementModel({
    required this.postId,
    required this.userNo,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.isPinned,
    required this.createdAt,
    this.authorName,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Handling join data for author name if available
    String? author;
    if (json['tbl_user'] != null) {
      final user = json['tbl_user'];
      author = "${user['firstName']} ${user['lastName']}";
    }

    return AnnouncementModel(
      postId: json['post_id'],
      userNo: json['user_no'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      isPinned: json['is_pinned'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      authorName: author,
    );
  }
}
