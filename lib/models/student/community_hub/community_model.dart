import 'package:flutter/foundation.dart';

class CommunityMember {
  final int userId;
  final String firstName;
  final String lastName;
  final String? middleInitial;
  final String contactNo;
  final String role;
  final String? studentNum;
  final String? yearLevel;
  final String? department;
  final String? specialization;
  final String status;
  final DateTime dateCreated;

  CommunityMember({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.middleInitial,
    required this.contactNo,
    required this.role,
    this.studentNum,
    this.yearLevel,
    this.department,
    this.specialization,
    required this.status,
    required this.dateCreated,
  });

  String get fullName => "$lastName, $firstName${middleInitial != null && middleInitial!.isNotEmpty ? ' $middleInitial.' : ''}";

  factory CommunityMember.fromMap(Map<String, dynamic> map) {
    String role = 'User';
    if (map['tbl_student'] != null && (map['tbl_student'] as List).isNotEmpty) {
      role = 'Student';
    } else if (map['tbl_faculty'] != null && (map['tbl_faculty'] as List).isNotEmpty) {
      role = 'Faculty';
    } else if (map['tbl_admin'] != null && (map['tbl_admin'] as List).isNotEmpty) {
      role = 'Admin';
    }

    final studentData = (map['tbl_student'] != null && (map['tbl_student'] as List).isNotEmpty) 
        ? map['tbl_student'][0] : null;
    final facultyData = (map['tbl_faculty'] != null && (map['tbl_faculty'] as List).isNotEmpty) 
        ? map['tbl_faculty'][0] : null;

    return CommunityMember(
      userId: map['user_id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      middleInitial: map['middleInitial'],
      contactNo: map['contact_no'] ?? '',
      role: role,
      studentNum: studentData?['student_num'],
      yearLevel: studentData?['year_level'],
      department: facultyData?['department'],
      specialization: facultyData?['specialization'],
      status: map['tbl_status']?['status'] ?? 'Unknown',
      dateCreated: DateTime.parse(map['date_created']),
    );
  }
}

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

  // Mobile Getters
  String get categoryName => category;
  int get reactionCount => upvoteCount - downvoteCount;

  factory CommunityPost.fromMap(Map<String, dynamic> map, {int? currentUserId}) {
    dynamic getData(dynamic data) {
      if (data == null) return null;
      if (data is List) return data.isEmpty ? null : data[0];
      return data;
    }

    final user = getData(map['tbl_user']);
    final authorName = user != null 
        ? "${user['lastName']}, ${user['firstName']}" 
        : 'Unknown Author';
    
    final profile = getData(user?['tbl_profile']);
    final profilePic = profile?['filePath'];

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
      if (currentUserId != null && r['user_no'] == currentUserId) {
        userReact = r['reaction_type'];
      }
    }

    final categoryData = getData(map['tbl_community_category']);
    String categoryName = categoryData != null ? categoryData['category'] : 'General';

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

class AddPostModel {
  final String title;
  final String content;
  final int categoryId;
  final String? imageUrl;
  final int userNo;
  final bool isPinned;
  final bool isVerified;
  final String postType;

  AddPostModel({
    required this.title,
    required this.content,
    required this.categoryId,
    this.imageUrl,
    required this.userNo,
    this.isPinned = false,
    this.isVerified = false,
    this.postType = 'community',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category_id': categoryId,
      'image_url': imageUrl,
      'user_no': userNo,
      'is_pinned': isPinned,
      'is_verified': isVerified,
      'status_no': 1, 
      'post_type': postType,
    };
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
  final int upvoteCount;
  final int downvoteCount;
  final String? userReaction;

  PostComment({
    required this.id,
    required this.postId,
    required this.userNo,
    required this.content,
    required this.isSolution,
    required this.createdAt,
    required this.authorName,
    this.authorProfilePic,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.userReaction,
  });

  factory PostComment.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    dynamic getData(dynamic data) {
      if (data == null) return null;
      if (data is List) return data.isEmpty ? null : data[0];
      return data;
    }

    final author = getData(json['tbl_user']);
    final profile = getData(author?['tbl_profile']);

    // Attempt to handle comment reactions if they exist in the join
    int upvotes = json['upvote_count'] ?? 0;
    int downvotes = json['downvote_count'] ?? 0;
    String? userReact;

    if (json['tbl_comment_reaction'] != null && json['tbl_comment_reaction'] is List) {
      final reactions = json['tbl_comment_reaction'] as List;
      upvotes = 0;
      downvotes = 0;
      for (var r in reactions) {
        if (r['reaction_type'] == 'upvote') upvotes++;
        if (r['reaction_type'] == 'downvote') downvotes++;
        if (currentUserId != null && r['user_no'] == currentUserId) {
          userReact = r['reaction_type'];
        }
      }
    }

    return PostComment(
      id: json['com_id'],
      postId: json['post_no'],
      userNo: json['user_no'],
      content: json['content'],
      isSolution: json['is_solution'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      authorName: author != null ? "${author['firstName']} ${author['lastName']}" : 'Unknown',
      authorProfilePic: profile?['filePath'],
      upvoteCount: upvotes,
      downvoteCount: downvotes,
      userReaction: userReact,
    );
  }
}
