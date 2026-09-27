import 'package:flutter/material.dart';
import '../services/community_service.dart';
import '../models/community_post.dart';
import '../utils/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  final CommunityService service;

  const CreatePostScreen({
    super.key,
    required this.service,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  PostCategory _selectedCategory = PostCategory.question;
  bool _includePhoto = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPost = CommunityPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorName: 'You (Farmer)',
        authorRole: 'Field 01 Owner • Local Valley',
        authorAvatar: '👨‍🌾',
        category: _selectedCategory,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        timestamp: DateTime.now(),
        imagePlaceholder: _includePhoto ? 'sample_crop_image.png' : null,
      );

      widget.service.addPost(newPost);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Post published to Farmer Community!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'POST',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Type selector
                const Text(
                  'SELECT POST TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PostCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text('${cat.emoji} ${cat.label}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
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
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Post Title
                const Text(
                  'TITLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Yellow leaves on tomato plants or Need power tiller',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a post title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'DESCRIPTION & DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Provide clear context: crop variety, symptoms, soil condition, or resource requirements so fellow farmers can provide the best guidance...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter description details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Photo attachment mock
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Attach Crop Photo (Optional)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Shows leaf/soil condition to community',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _includePhoto,
                        activeThumbImage: null,
                        activeTrackColor: AppColors.primaryLight,
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected) ? AppColors.primary : Colors.grey,
                        ),
                        onChanged: (val) => setState(() => _includePhoto = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Helpful Posting Tip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryDark, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Clear posts with crop name and symptoms receive responses from local agronomists and peer farmers within 2 hours.',
                          style: TextStyle(fontSize: 11, color: AppColors.primaryDark, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
