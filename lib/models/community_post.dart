enum PostCategory {
  question,
  farmingTip,
  cropProblem,
  successStory,
  resourceRequest;

  String get label {
    switch (this) {
      case PostCategory.question:
        return 'Question';
      case PostCategory.farmingTip:
        return 'Farming Tip';
      case PostCategory.cropProblem:
        return 'Crop Problem';
      case PostCategory.successStory:
        return 'Success Story';
      case PostCategory.resourceRequest:
        return 'Resource Request';
    }
  }

  String get emoji {
    switch (this) {
      case PostCategory.question:
        return '❓';
      case PostCategory.farmingTip:
        return '💡';
      case PostCategory.cropProblem:
        return '🐛';
      case PostCategory.successStory:
        return '🎉';
      case PostCategory.resourceRequest:
        return '📦';
    }
  }
}

class PostComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime timestamp;

  const PostComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final PostCategory category;
  final String title;
  final String description;
  final DateTime timestamp;
  final int likesCount;
  final bool isLiked;
  final List<PostComment> comments;
  final String? imagePlaceholder;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar = '👨‍🌾',
    required this.category,
    required this.title,
    required this.description,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
    this.comments = const [],
    this.imagePlaceholder,
  });

  int get commentsCount => comments.length;

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  CommunityPost copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    PostCategory? category,
    String? title,
    String? description,
    DateTime? timestamp,
    int? likesCount,
    bool? isLiked,
    List<PostComment>? comments,
    String? imagePlaceholder,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
    );
  }
}
