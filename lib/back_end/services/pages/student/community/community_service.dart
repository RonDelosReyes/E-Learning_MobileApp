import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../connection/db_connect.dart';
import '../../../../../models/student/community_hub/community_model.dart';
import '../../../../utils/debug_logger.dart';

class CommunityService {
  final SupabaseClient _supabase = supabase;

  /// Fetches community posts, prioritizing Pinned posts then Latest next.
  /// Supports filtering by multiple category IDs.
  Future<List<CommunityPost>> fetchCommunityPosts({List<int>? categoryIds, int? currentUserId}) async {
    try {
      await DebugLogger.log('COMMUNITY_DEBUG: Starting fetch. categoryIds: $categoryIds, currentUserId: $currentUserId');
      
      // 1. Initial query setup - fetching ALL community posts
      var query = _supabase.from('tbl_post').select('''
        post_id,
        user_no,
        title,
        content,
        image_url,
        category_id,
        is_verified,
        is_pinned,
        status_no,
        created_at,
        is_edited,
        post_type,
        tbl_user(firstName, lastName, tbl_profile(filePath)),
        tbl_reaction(*),
        tbl_comment(com_id),
        tbl_community_category(category)
      ''')
      .eq('post_type', 'community');

      // Add category filter if provided and not empty
      if (categoryIds != null && categoryIds.isNotEmpty) {
        await DebugLogger.log('COMMUNITY_DEBUG: Filtering by categoryIds: $categoryIds');
        query = query.inFilter('category_id', categoryIds);
      }

      // Prioritize Pinned then Latest
      final response = await query
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      await DebugLogger.log('COMMUNITY_DEBUG: Raw Response Length: ${response.length}');

      // 2. Map to model
      final posts = (response as List)
          .map((p) => CommunityPost.fromMap(p, currentUserId: currentUserId))
          .toList();

      await DebugLogger.log('COMMUNITY_DEBUG: Successfully mapped ${posts.length} posts');
      return posts;
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG ERROR: $e');
      return [];
    }
  }

  Future<List<CommunityCategory>> getCategories() async {
    try {
      final response = await _supabase.from('tbl_community_category').select().order('category');
      return (response as List).map((json) => CommunityCategory.fromJson(json)).toList();
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG CATEGORIES ERROR: $e');
      return [];
    }
  }

  Future<void> createPost(int userNo, String title, String content, int categoryId, String? imageUrl) async {
    try {
      await _supabase.from('tbl_post').insert({
        'user_no': userNo,
        'title': title,
        'content': content,
        'category_id': categoryId,
        'image_url': imageUrl,
        'post_type': 'community',
        'status_no': 1, // Defaulting to Active
      });
      await DebugLogger.log('COMMUNITY_DEBUG: Post created successfully by userNo: $userNo');
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG CREATE POST ERROR: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _supabase.from('tbl_post').delete().eq('post_id', postId);
      await DebugLogger.log('COMMUNITY_DEBUG: Post $postId deleted successfully');
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG DELETE POST ERROR: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<void> reactToPost(int postId, int userNo, String reactionType) async {
    try {
      final existing = await _supabase
          .from('tbl_reaction')
          .select()
          .eq('post_no', postId)
          .eq('user_no', userNo)
          .maybeSingle();

      if (existing != null) {
        if (existing['reaction_type'] == reactionType) {
          await _supabase.from('tbl_reaction').delete().eq('react_id', existing['react_id']);
          await DebugLogger.log('COMMUNITY_DEBUG: Reaction removed for postId: $postId');
        } else {
          await _supabase.from('tbl_reaction').update({'reaction_type': reactionType}).eq('react_id', existing['react_id']);
          await DebugLogger.log('COMMUNITY_DEBUG: Reaction updated to $reactionType for postId: $postId');
        }
      } else {
        await _supabase.from('tbl_reaction').insert({
          'post_no': postId,
          'user_no': userNo,
          'reaction_type': reactionType,
        });
        await DebugLogger.log('COMMUNITY_DEBUG: New reaction $reactionType added for postId: $postId');
      }
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG REACT ERROR: $e');
      throw Exception('Failed to react: $e');
    }
  }

  Future<List<PostComment>> getComments(int postId, {int? currentUserId}) async {
    try {
      final response = await _supabase
          .from('tbl_comment')
          .select('*, tbl_user (firstName, lastName, tbl_profile (filePath)), tbl_comment_reaction(*)')
          .eq('post_no', postId)
          .order('created_at', ascending: true);
      return (response as List).map((json) => PostComment.fromJson(json, currentUserId: currentUserId)).toList();
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG COMMENTS ERROR: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<void> addComment(int postId, int userNo, String content) async {
    try {
      await _supabase.from('tbl_comment').insert({
        'post_no': postId,
        'user_no': userNo,
        'content': content,
      });
      await DebugLogger.log('COMMUNITY_DEBUG: Comment added successfully by userNo: $userNo');
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG ADD COMMENT ERROR: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _supabase.from('tbl_comment').delete().eq('com_id', commentId);
      await DebugLogger.log('COMMUNITY_DEBUG: Comment $commentId deleted successfully');
    } catch (e) {
      await DebugLogger.log('COMMUNITY_DEBUG DELETE COMMENT ERROR: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> reactToComment(int commentId, int userNo, String reactionType) async {
    try {
      final existing = await _supabase
          .from('tbl_comment_reaction')
          .select()
          .eq('com_no', commentId)
          .eq('user_no', userNo)
          .maybeSingle();

      if (existing != null) {
        if (existing['reaction_type'] == reactionType) {
          await _supabase.from('tbl_comment_reaction').delete().eq('react_id', existing['react_id']);
        } else {
          await _supabase.from('tbl_comment_reaction').update({'reaction_type': reactionType}).eq('react_id', existing['react_id']);
        }
      } else {
        await _supabase.from('tbl_comment_reaction').insert({
          'com_no': commentId,
          'user_no': userNo,
          'reaction_type': reactionType,
        });
      }
    } catch (e) {
      throw Exception('Failed to react to comment: $e');
    }
  }
}
