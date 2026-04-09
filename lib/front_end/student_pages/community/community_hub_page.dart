import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../back_end/controllers/student/community/community_controller.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../models/student/community_hub/community_model.dart';
import '../../widgets/hamburgMenu.dart';
import '../../../back_end/utils/media_player_util.dart';
import '../../widgets/student/community/create_post_modal.dart';
import '../../../back_end/utils/post_media_fetcher.dart';
import '../../../back_end/utils/profile_pic_fetcher.dart';

class CommunityHubPage extends StatefulWidget {
  const CommunityHubPage({super.key});

  @override
  State<CommunityHubPage> createState() => _CommunityHubPageState();
}

class _CommunityHubPageState extends State<CommunityHubPage> {
  final CommunityController _controller = CommunityController();
  final TextEditingController _searchController = TextEditingController();
  List<CommunityPost> _posts = [];
  List<CommunityPost> _filteredPosts = [];
  List<CommunityCategory> _categories = [];
  final List<int> _selectedCategoryIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userIdNo = userProvider.userId;

      final categories = await _controller.getCategories();
      final posts = await _controller.getPosts(
        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
        currentUserId: userIdNo,
      );
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _posts = posts;
          _applySearch();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("COMMUNITY_HUB_ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = _posts.where((post) {
        return post.title.toLowerCase().contains(query) ||
               post.content.toLowerCase().contains(query) ||
               post.authorName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: 'community'),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Community Hub',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: onPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: onPrimary, size: 28),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Feed',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applySearch(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search posts, authors, or categories...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreatePostModal.show(context, _loadData),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _filteredPosts.isEmpty
                        ? const Center(child: Text("No posts found."))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredPosts.length,
                            itemBuilder: (context, index) => _buildPostCard(_filteredPosts[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _categories[index - 1];
          final isSelected = isAll ? _selectedCategoryIds.isEmpty : _selectedCategoryIds.contains(category?.id);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(isAll ? "All" : category!.name),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (val) {
                setState(() {
                  if (isAll) {
                    _selectedCategoryIds.clear();
                  } else {
                    if (_selectedCategoryIds.contains(category?.id)) {
                      _selectedCategoryIds.remove(category?.id);
                    } else {
                      _selectedCategoryIds.add(category!.id);
                    }
                  }
                });
                _loadData();
              },
              selectedColor: primaryColor,
              backgroundColor: theme.cardTheme.color,
              labelStyle: TextStyle(
                color: isSelected ? onPrimary : primaryColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post, {bool isModal = false}) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Card(
      margin: isModal ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isModal ? Colors.transparent : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isModal ? BorderSide.none : BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: isModal ? const EdgeInsets.symmetric(vertical: 8) : const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FutureBuilder<String?>(
                  future: ProfilePicFetcher.fetch(post.userNo),
                  builder: (context, snapshot) {
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.dividerColor.withOpacity(0.1),
                      backgroundImage: (snapshot.hasData && snapshot.data != null)
                          ? NetworkImage(snapshot.data!)
                          : const AssetImage('assets/profile_pic.png') as ImageProvider,
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "u/${post.authorName}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (post.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
                          ],
                        ],
                      ),
                      Text(
                        "${DateFormat('d/M/yyyy').format(post.createdAt)} • c/${post.categoryName}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (post.isPinned) ...[
                  const Icon(Icons.push_pin, size: 16, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                ],
                if (userProvider.userId == post.userNo)
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') _handleDeletePost(post.postId);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete Post", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_horiz),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Poppins',
              ),
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              FutureBuilder<String?>(
                future: PostMediaFetcher.fetch(post.imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

                  final resolvedUrl = snapshot.data!;
                  return GestureDetector(
                    onTap: () => MediaPlayerUtil.show(context, imageUrl: resolvedUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        resolvedUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildReactionButton(post, userProvider.userId!),
                const SizedBox(width: 12),
                if (!isModal)
                  _buildActionButton(Icons.mode_comment_outlined, "${post.commentCount}", () => _showCommentsModal(post)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(CommunityPost post, int userNo) {
    final theme = Theme.of(context);
    final isUpvoted = post.userReaction == 'upvote';
    final isDownvoted = post.userReaction == 'downvote';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: Icon(
              isUpvoted ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_up_outlined,
              color: isUpvoted ? Colors.orange : null,
              size: 22,
            ),
            onPressed: () => _handleReaction(post.postId, userNo, 'upvote', post.userReaction),
          ),
          Text(
            "${post.upvoteCount}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUpvoted ? Colors.orange : null,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 15, color: theme.dividerColor.withOpacity(0.1)),
          const SizedBox(width: 4),
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: Icon(
              isDownvoted ? Icons.arrow_circle_down_rounded : Icons.arrow_circle_down_outlined,
              color: isDownvoted ? Colors.blue : null,
              size: 22,
            ),
            onPressed: () => _handleReaction(post.postId, userNo, 'downvote', post.userReaction),
          ),
          Text(
            "${post.downvoteCount}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDownvoted ? Colors.blue : null,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleReaction(int postId, int userNo, String type, String? current) async {
    try {
      await _controller.handleReaction(postId, userNo, type, current);
      _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleDeletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.deletePost(postId);
        _loadData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showCommentsModal(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsModal(
        post: post,
        postCard: _buildPostCard(post, isModal: true),
      ),
    );
  }
}

class _CommentsModal extends StatefulWidget {
  final CommunityPost post;
  final Widget postCard;
  const _CommentsModal({required this.post, required this.postCard});

  @override
  State<_CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<_CommentsModal> {
  final CommunityController _controller = CommunityController();
  final TextEditingController _commentController = TextEditingController();
  List<PostComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final comments = await _controller.getComments(widget.post.postId, currentUserId: userProvider.userId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, 
            height: 4, 
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
          ),
          
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    const SizedBox(height: 32), // Space for close button
                    widget.postCard,
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text("COMMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600], letterSpacing: 1.2)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text("${_comments.length}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("No comments yet. Be the first to share your thoughts!")))
                    else
                      ..._comments.map((comment) => _buildCommentItem(comment, userProvider.userId!)),
                  ],
                ),
                
                Positioned(
                  top: 0,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,
                      fillColor: theme.dividerColor.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: theme.colorScheme.primary,
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;
                    await _controller.addComment(widget.post.postId, userProvider.userId!, _commentController.text.trim());
                    _commentController.clear();
                    _loadComments();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(PostComment comment, int currentUserId) {
    final theme = Theme.of(context);
    final isUpvoted = comment.userReaction == 'upvote';
    final isDownvoted = comment.userReaction == 'downvote';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FutureBuilder<String?>(
                future: ProfilePicFetcher.fetch(comment.userNo),
                builder: (context, snapshot) {
                  return CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.dividerColor.withOpacity(0.1),
                    backgroundImage: (snapshot.hasData && snapshot.data != null)
                        ? NetworkImage(snapshot.data!)
                        : const AssetImage('assets/profile_pic.png') as ImageProvider,
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        if (comment.isSolution) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text("SOLUTION", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    Text(DateFormat('MMM dd, yyyy').format(comment.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ],
                ),
              ),
              if (currentUserId == comment.userNo)
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'delete') _handleDeleteComment(comment.id);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete Comment", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment.content, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: Icon(isUpvoted ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_up_outlined, 
                           color: isUpvoted ? Colors.orange : null, size: 18),
                      onPressed: () => _handleCommentReaction(comment.id, currentUserId, 'upvote'),
                    ),
                    Text("${comment.upvoteCount}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, 
                         color: isUpvoted ? Colors.orange : null)),
                    const SizedBox(width: 4),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: Icon(isDownvoted ? Icons.arrow_circle_down_rounded : Icons.arrow_circle_down_outlined, 
                           color: isDownvoted ? Colors.blue : null, size: 18),
                      onPressed: () => _handleCommentReaction(comment.id, currentUserId, 'downvote'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleCommentReaction(int commentId, int userNo, String type) async {
    try {
      await _controller.handleCommentReaction(commentId, userNo, type);
      _loadComments();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleDeleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.deleteComment(commentId);
        _loadComments();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
