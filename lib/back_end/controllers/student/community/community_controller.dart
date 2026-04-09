import '../../../services/pages/student/community/community_service.dart';
import '../../../../models/student/community_hub/community_model.dart';

class CommunityController {
  final CommunityService _service = CommunityService();

  Future<List<CommunityPost>> getPosts({List<int>? categoryIds, int? currentUserId}) async {
    return await _service.fetchCommunityPosts(categoryIds: categoryIds, currentUserId: currentUserId);
  }

  Future<List<CommunityCategory>> getCategories() async {
    return await _service.getCategories();
  }

  Future<void> createPost(int userNo, String title, String content, int categoryId, String? imageUrl) async {
    return await _service.createPost(userNo, title, content, categoryId, imageUrl);
  }

  Future<void> deletePost(int postId) async {
    return await _service.deletePost(postId);
  }

  Future<void> handleReaction(int postId, int userNo, String reactionType, String? currentReaction) async {
    return await _service.reactToPost(postId, userNo, reactionType);
  }

  Future<List<PostComment>> getComments(int postId, {int? currentUserId}) async {
    return await _service.getComments(postId, currentUserId: currentUserId);
  }

  Future<void> addComment(int postId, int userNo, String content) async {
    return await _service.addComment(postId, userNo, content);
  }

  Future<void> deleteComment(int commentId) async {
    return await _service.deleteComment(commentId);
  }

  Future<void> handleCommentReaction(int commentId, int userNo, String reactionType) async {
    return await _service.reactToComment(commentId, userNo, reactionType);
  }
}
