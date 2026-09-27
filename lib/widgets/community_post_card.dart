import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../utils/app_colors.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onAuthorTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              InkWell(
                onTap: onAuthorTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Center(
                    child: Text(
                      post.authorAvatar,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onAuthorTap,
                      child: Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      post.authorRole,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(post.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getCategoryColor(post.category).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(post.category.emoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      post.category.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(post.category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            post.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Comments Preview (if any)
          if (post.comments.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: '${post.comments.last.authorName}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(text: post.comments.last.text),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer: Timestamp & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                post.timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),

              // Like and Comment Actions
              Row(
                children: [
                  InkWell(
                    onTap: onLike,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 16,
                            color: post.isLiked ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: post.isLiked ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: onComment,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.mode_comment_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(PostCategory category) {
    switch (category) {
      case PostCategory.question:
        return AppColors.soilMoisture;
      case PostCategory.farmingTip:
        return AppColors.primary;
      case PostCategory.cropProblem:
        return AppColors.statusCritical;
      case PostCategory.successStory:
        return Color(0xFF7B1FA2);
      case PostCategory.resourceRequest:
        return AppColors.statusAttention;
    }
  }
}
