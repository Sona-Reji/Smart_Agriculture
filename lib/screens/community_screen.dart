import 'package:flutter/material.dart';
import '../services/community_service.dart';
import '../models/community_post.dart';
import '../models/farmer.dart';
import '../widgets/community_post_card.dart';
import '../widgets/farmer_card.dart';
import '../utils/app_colors.dart';
import 'create_post_screen.dart';
import 'farmer_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityService service;
  final int initialTab;

  const CommunityScreen({
    super.key,
    required this.service,
    this.initialTab = 1,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  late int _activeViewTab;
  String _selectedCropFilter = 'All';

  final List<String> _cropFilterOptions = [
    'All',
    'Tomato',
    'Wheat',
    'Pomegranate',
    'Bell Pepper',
    'Rice',
    'Dairy',
  ];

  @override
  void initState() {
    super.initState();
    _activeViewTab = widget.initialTab;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final posts = widget.service.filteredPosts;
        final farmers = widget.service.getFilteredFarmers(
          cropQuery: _selectedCropFilter == 'All' ? null : _selectedCropFilter,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer Community',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Connect, learn and grow together.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search & View Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: widget.service.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: _activeViewTab == 0
                              ? 'Search farming questions, tips, crops...'
                              : 'Search farmers by name, location, crop...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    widget.service.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Toggle Tabs: Community Feed vs Farmers Near You
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _activeViewTab = 0),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _activeViewTab == 0 ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: _activeViewTab == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.dynamic_feed_rounded,
                                          size: 16,
                                          color: _activeViewTab == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Community Feed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: _activeViewTab == 0 ? FontWeight.bold : FontWeight.w500,
                                            color: _activeViewTab == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _activeViewTab = 1),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _activeViewTab == 1 ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: _activeViewTab == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline_rounded,
                                          size: 16,
                                          color: _activeViewTab == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Farmers Near You',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: _activeViewTab == 1 ? FontWeight.bold : FontWeight.w500,
                                            color: _activeViewTab == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Category or Filter Bar
                if (_activeViewTab == 0) _buildPostCategoryFilterBar() else _buildCropFilterBar(),
                const SizedBox(height: 8),

                // Main Content List
                Expanded(
                  child: _activeViewTab == 0
                      ? _buildPostsFeed(posts)
                      : _buildFarmersList(farmers),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(service: widget.service),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              'Create Post',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCategoryFilterBar() {
    final categories = [
      null, // All
      PostCategory.question,
      PostCategory.farmingTip,
      PostCategory.cropProblem,
      PostCategory.successStory,
      PostCategory.resourceRequest,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = widget.service.selectedCategory == cat;
          final label = cat == null ? 'All Topics' : '${cat.emoji} ${cat.label}';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => widget.service.setCategory(cat),
              selectedColor: AppColors.primaryContainer,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCropFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _cropFilterOptions.map((crop) {
          final isSelected = _selectedCropFilter == crop;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(crop),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCropFilter = crop);
                }
              },
              selectedColor: AppColors.primaryContainer,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostsFeed(List<CommunityPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.forum_outlined, size: 54, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'No community posts yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 6),
              Text(
                'Be the first farmer to share a tip, question, or crop problem.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return CommunityPostCard(
          post: post,
          onLike: () => widget.service.toggleLike(post.id),
          onComment: () => _showCommentsBottomSheet(context, post),
          onAuthorTap: () => _openAuthorProfile(context, post.authorName),
        );
      },
    );
  }

  Widget _buildFarmersList(List<Farmer> farmers) {
    if (farmers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.people_outline, size: 54, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'No farmers found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 6),
              Text(
                'Try adjusting your search query or crop filter.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: farmers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        return FarmerCard(
          farmer: farmer,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FarmerProfileScreen(
                  farmer: farmer,
                  communityService: widget.service,
                ),
              ),
            );
          },
          onConnectTap: () {
            final newStatus = widget.service.cycleConnectionStatus(farmer.id);
            String msg = 'Connection request sent to ${farmer.name}';
            if (newStatus == ConnectionStatus.connected) {
              msg = 'Connected with ${farmer.name}';
            } else if (newStatus == ConnectionStatus.connect) {
              msg = 'Connection removed for ${farmer.name}';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  void _openAuthorProfile(BuildContext context, String authorName) {
    try {
      final farmer = widget.service.farmers.firstWhere(
        (f) => f.name.toLowerCase() == authorName.toLowerCase(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerProfileScreen(
            farmer: farmer,
            communityService: widget.service,
          ),
        ),
      );
    } catch (_) {
      // Author might be 'You' or an anonymous farmer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Viewing profile for $authorName'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showCommentsBottomSheet(BuildContext context, CommunityPost post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments (${post.comments.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Comments List
                    Expanded(
                      child: post.comments.isEmpty
                          ? const Center(
                              child: Text(
                                'No comments yet. Share your thoughts or agricultural advice!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: post.comments.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final c = post.comments[i];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            c.authorName,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            c.timeAgo,
                                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.text,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    // Add Comment Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Write a helpful comment...',
                                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: AppColors.cardBorder),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                            onPressed: () {
                              final text = commentController.text.trim();
                              if (text.isNotEmpty) {
                                widget.service.addComment(post.id, text);
                                commentController.clear();
                                setSheetState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
