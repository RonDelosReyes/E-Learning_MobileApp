class CommunityPost {
  final int postId;
  final int userNo;
  final String title;
  final String content;
  final String? imageUrl;
  final String category;
  final bool isVerified;
  final bool isPinned;
  final int statusNo;
  final DateTime createdAt;
  final String authorName;
  final String? authorProfilePic;
  final int upvoteCount;
  final int downvoteCount;
  final int commentCount;
  final bool isEdited;
  final String? userReaction;

  CommunityPost({
    required this.postId,
    required this.userNo,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.category,
    required this.isVerified,
    required this.isPinned,
    required this.statusNo,
    required this.createdAt,
    required this.authorName,
    this.authorProfilePic,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.commentCount = 0,
    this.isEdited = false,
    this.userReaction,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map, {int? currentUserIdNo}) {
    final user = map['tbl_user'];
    final authorName = user != null 
        ? "${user['firstName']} ${user['lastName']}" 
        : 'Unknown Author';
    
    final profilePic = (user != null && user['tbl_profile'] != null) 
        ? user['tbl_profile']['filePath'] 
        : null;

    int getCount(dynamic data) {
      if (data == null) return 0;
      if (data is List) {
        if (data.isNotEmpty && data[0] is Map && data[0].containsKey('count')) {
          return data[0]['count'] ?? 0;
        }
        return data.length;
      }
      if (data is Map && data['count'] != null) return data['count'];
      return 0;
    }

    final reactions = map['tbl_reaction'] as List? ?? [];
    int upvotes = 0;
    int downvotes = 0;
    String? userReact;

    for (var r in reactions) {
      if (r['reaction_type'] == 'upvote') upvotes++;
      if (r['reaction_type'] == 'downvote') downvotes++;
      if (currentUserIdNo != null && r['user_no'] == currentUserIdNo) {
        userReact = r['reaction_type'];
      }
    }

    String categoryName = 'General';
    if (map['tbl_community_category'] != null) {
      categoryName = map['tbl_community_category']['category'] ?? 'General';
    }

    return CommunityPost(
      postId: map['post_id'],
      userNo: map['user_no'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      category: categoryName,
      isVerified: map['is_verified'] ?? false,
      isPinned: map['is_pinned'] ?? false,
      statusNo: map['status_no'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
      authorName: authorName,
      authorProfilePic: profilePic,
      upvoteCount: upvotes,
      downvoteCount: downvotes,
      commentCount: getCount(map['tbl_comment']),
      isEdited: map['is_edited'] ?? false,
      userReaction: userReact,
    );
  }
}

class CommunityCategory {
  final int id;
  final String name;

  CommunityCategory({required this.id, required this.name});

  factory CommunityCategory.fromJson(Map<String, dynamic> json) {
    return CommunityCategory(
      id: json['comcat_id'],
      name: json['category'],
    );
  }
}

class PostComment {
  final int id;
  final int postId;
  final int userNo;
  final String content;
  final bool isSolution;
  final DateTime createdAt;
  final String authorName;
  final String? authorProfilePic;

  PostComment({
    required this.id,
    required this.postId,
    required this.userNo,
    required this.content,
    required this.isSolution,
    required this.createdAt,
    required this.authorName,
    this.authorProfilePic,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final author = json['tbl_user'];
    return PostComment(
      id: json['com_id'],
      postId: json['post_no'],
      userNo: json['user_no'],
      content: json['content'],
      isSolution: json['is_solution'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      authorName: author != null ? "${author['firstName']} ${author['lastName']}" : 'Unknown',
      authorProfilePic: (author != null && author['tbl_profile'] != null) ? author['tbl_profile']['filePath'] : null,
    );
  }
}
