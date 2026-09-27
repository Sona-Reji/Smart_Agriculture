import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/community_post.dart';
import '../models/farmer.dart';
import '../mock/mock_posts.dart';

class CommunityService extends ChangeNotifier {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;

  CommunityService._internal() {
    _posts = MockPosts.getInitialPosts();
    _initFirebaseUsersListener();
  }

  late List<CommunityPost> _posts;
  List<Farmer> _farmers = [];

  PostCategory? _selectedCategory;
  PostCategory? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  
  /// Exposes nearby farmers sorted by nearest distance first
  List<Farmer> get farmers => List.unmodifiable(_farmers);

  StreamSubscription<DatabaseEvent>? _usersSubscription;

  void _initFirebaseUsersListener() {
    try {
      final ref = FirebaseDatabase.instance.ref('users');
      _usersSubscription = ref.onValue.listen((event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final usersMap = Map<String, dynamic>.from(event.snapshot.value as Map);
          final currentUid = FirebaseAuth.instance.currentUser?.uid;

          // Extract current user coordinates if available
          double? myLat;
          double? myLng;
          if (currentUid != null && usersMap.containsKey(currentUid)) {
            final myLoc = (usersMap[currentUid]['location'] as Map?)?.cast<String, dynamic>();
            myLat = (myLoc?['lat'] as num?)?.toDouble();
            myLng = (myLoc?['lng'] as num?)?.toDouble();
          }

          final List<Farmer> loaded = [];
          usersMap.forEach((uid, val) {
            if (uid != currentUid && val is Map) {
              final farmer = Farmer.fromFirebase(
                uid.toString(),
                Map<String, dynamic>.from(val),
                currentLat: myLat,
                currentLng: myLng,
              );
              loaded.add(farmer);
            }
          });

          // Sort by nearest distance first
          loaded.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

          _farmers = loaded;
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint("Firebase users listener note: $e");
      });
    } catch (e) {
      debugPrint("Firebase users init note: $e");
    }
  }

  List<Farmer> getFilteredFarmers({String? cropQuery, String? typeQuery}) {
    return _farmers.where((farmer) {
      bool matches = true;
      if (cropQuery != null && cropQuery.isNotEmpty && cropQuery != 'All') {
        matches = matches &&
            farmer.mainCrops.any((c) => c.toLowerCase().contains(cropQuery.toLowerCase()));
      }
      if (typeQuery != null && typeQuery.isNotEmpty && typeQuery != 'All') {
        matches = matches &&
            farmer.farmingType.toLowerCase().contains(typeQuery.toLowerCase());
      }
      return matches;
    }).toList();
  }

  void setCategory(PostCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addPost(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newIsLiked = !post.isLiked;
      final newLikes = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;
      _posts[index] = post.copyWith(
        isLiked: newIsLiked,
        likesCount: newLikes.clamp(0, 99999),
      );
      notifyListeners();
    }
  }

  void addComment(String postId, String commentText, {String authorName = 'You (Farmer)', String authorRole = 'Field 01 Owner'}) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newComment = PostComment(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        authorName: authorName,
        authorRole: authorRole,
        text: commentText,
        timestamp: DateTime.now(),
      );
      final updatedComments = List<PostComment>.from(post.comments)..add(newComment);
      _posts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  List<CommunityPost> get filteredPosts {
    return _posts.where((post) {
      final matchesCategory = _selectedCategory == null || post.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.authorName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  ConnectionStatus cycleConnectionStatus(String farmerId) {
    return ConnectionStatus.connect;
  }

  List<Farmer> get connectedFarmers => List.unmodifiable(_farmers);

  void updateConnectionStatus(String farmerId, ConnectionStatus status) {
    notifyListeners();
  }

  Farmer? getFarmerById(String id) {
    try {
      return _farmers.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}
