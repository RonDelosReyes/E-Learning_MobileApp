import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../back_end/providers/community_provider.dart';
import '../../../models/student/community_hub/community_model.dart';
import '../../widgets/hamburgMenu.dart';
import '../../widgets/student/community/create_post_modal.dart';
import '../../widgets/student/community/post_card_widget.dart';
import '../../widgets/student/community/comments_modal.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/empty_state_widget.dart';

class CommunityHubPage extends StatefulWidget {
  final bool isInsideShell;
  const CommunityHubPage({super.key, this.isInsideShell = false});

  @override
  State<CommunityHubPage> createState() => _CommunityHubPageState();
}

class _CommunityHubPageState extends State<CommunityHubPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    await communityProvider.loadData(
      currentUserId: userProvider.userId,
      categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
      forceRefresh: forceRefresh,
    );
  }

  List<CommunityPost> _getFilteredPosts(List<CommunityPost> posts) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return posts;

    return posts.where((post) {
      return post.title.toLowerCase().contains(query) ||
             post.content.toLowerCase().contains(query) ||
             post.authorName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final gradient = theme.extension<AppGradient>()?.primary;

    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        final filteredPosts = _getFilteredPosts(communityProvider.posts);
        final isLoading = communityProvider.isLoading;

        Widget bodyContent = Column(
          children: [
            if (widget.isInsideShell)
              Container(
                color: gradient != null ? null : primaryColor,
                decoration: gradient != null ? BoxDecoration(gradient: gradient) : null,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search posts, authors, or categories...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            _buildCategoryFilter(communityProvider),
            Expanded(
              child: RefreshIndicator(
                    onRefresh: () => _loadData(forceRefresh: true),
                    child: (isLoading && communityProvider.posts.isEmpty)
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 2,
                          itemBuilder: (context, index) => const PostSkeleton(),
                        )
                      : filteredPosts.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.forum_outlined,
                            title: "The hub is quiet",
                            description: "Be the first one to start a discussion! Share your thoughts or ask a question.",
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            cacheExtent: 1000,
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) => PostCardWidget(
                              key: ValueKey(filteredPosts[index].postId),
                              post: filteredPosts[index],
                              onRefresh: () => _loadData(forceRefresh: true),
                              onShowComments: () => _showCommentsModal(filteredPosts[index]),
                            ),
                          ),
                  ),
            ),
          ],
        );

        if (widget.isInsideShell) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              onPressed: () => CreatePostModal.show(context, () => _loadData(forceRefresh: true)),
              backgroundColor: primaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            body: bodyContent,
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          drawer: const AppDrawer(currentRoute: 'community'),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            flexibleSpace: gradient != null
                ? Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                    ),
                  )
                : null,
            title: Text(
              'Community Hub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: onPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: gradient != null ? Colors.transparent : primaryColor,
            iconTheme: IconThemeData(color: onPrimary, size: 28),
            actions: [
              IconButton(
                onPressed: () => _loadData(forceRefresh: true),
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
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search posts, authors, or categories...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
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
            onPressed: () => CreatePostModal.show(context, () => _loadData(forceRefresh: true)),
            backgroundColor: primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          body: bodyContent,
        );
      },
    );
  }

  Widget _buildCategoryFilter(CommunityProvider provider) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final categories = provider.categories;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
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
                _loadData(forceRefresh: true);
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

  void _showCommentsModal(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(post: post),
    );
  }
}
