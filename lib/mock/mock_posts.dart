import '../models/community_post.dart';

class MockPosts {
  static List<CommunityPost> getInitialPosts() {
    final now = DateTime.now();

    return [
      CommunityPost(
        id: 'post_01',
        authorName: 'Anil Kumar',
        authorRole: 'Fruit Farmer • Sunrise Orchards',
        authorAvatar: '🍎',
        category: PostCategory.cropProblem,
        title: 'Yellowing leaves on tomato plants after heavy rain',
        description:
            'My tomato plants are showing yellowing leaves starting from the bottom foliage up. Has anyone experienced this after sudden rainfall? Looking for organic remedies before applying copper fungicide.',
        timestamp: now.subtract(const Duration(hours: 2)),
        likesCount: 14,
        isLiked: false,
        comments: [
          PostComment(
            id: 'c_01',
            authorName: 'Suresh Patil',
            authorRole: 'Organic Farmer',
            text:
                'Check if water is stagnant around root zones. Bottom yellowing often indicates nitrogen leaching due to excess saturation or early blight onset.',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
          ),
          PostComment(
            id: 'c_02',
            authorName: 'Rajesh Shinde',
            authorRole: 'Vegetable Farmer',
            text:
                'Spray neem oil extract (5ml/L) with sour buttermilk early morning. That cured it in my sector last season.',
            timestamp: now.subtract(const Duration(minutes: 45)),
          ),
        ],
      ),
      CommunityPost(
        id: 'post_02',
        authorName: 'Suresh Patil',
        authorRole: 'Organic Farmer • Green Valley',
        authorAvatar: '🌾',
        category: PostCategory.farmingTip,
        title: 'Simple Jeevamrutha preparation for soil revitalization',
        description:
            'Quick reminder for organic growers: Mix 10kg desi cow dung, 10L cow urine, 2kg jaggery, 2kg besan, and a handful of virgin soil in 200L water. Ferment for 48 hours in shade. Feeds beneficial aerobic microbes wonderfully!',
        timestamp: now.subtract(const Duration(hours: 5)),
        likesCount: 28,
        isLiked: true,
        comments: [
          PostComment(
            id: 'c_03',
            authorName: 'Meena Rathod',
            authorRole: 'AgroTech Hub',
            text:
                'Excellent tip Suresh! Filter it through fine cloth if applying through drip lines to prevent emitter clogging.',
            timestamp: now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),
      CommunityPost(
        id: 'post_03',
        authorName: 'Rajesh Shinde',
        authorRole: 'Vegetable Farmer • Nashik Valley',
        authorAvatar: '👨‍🌾',
        category: PostCategory.resourceRequest,
        title: 'Looking for Power Tiller or Mini Tractor for 2 days',
        description:
            'Need a 9HP-12HP power tiller for bed preparation in 1.5 acres before transplanting bell pepper saplings this weekend. Willing to rent or exchange for battery sprayer usage.',
        timestamp: now.subtract(const Duration(hours: 8)),
        likesCount: 8,
        isLiked: false,
        comments: [
          PostComment(
            id: 'c_04',
            authorName: 'Rameshwar Jadhav',
            authorRole: 'Rice & Spice Farmer',
            text:
                'My VST power tiller is free starting tomorrow afternoon Rajesh. Message me directly!',
            timestamp: now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),
      CommunityPost(
        id: 'post_04',
        authorName: 'Meena Rathod',
        authorRole: 'Hydroponic Specialist • AgroTech Hub',
        authorAvatar: '🌱',
        category: PostCategory.successStory,
        title: '40% water reduction achieved with IoT sensor automated drip',
        description:
            'Delighted to share results from our 90-day trial: Linking soil moisture sensors directly to solenoid valves saved over 120,000 liters of water while boosting cherry tomato yield by 18%. Precision farming works!',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        likesCount: 42,
        isLiked: false,
        comments: [
          PostComment(
            id: 'c_05',
            authorName: 'Sunita Deshmukh',
            authorRole: 'Dairy & Fodder Farmer',
            text: 'Inspiring work! Are you using capacitive or resistive soil probes?',
            timestamp: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
      CommunityPost(
        id: 'post_05',
        authorName: 'Rameshwar Jadhav',
        authorRole: 'Rice & Spice Farmer • Riverbank Sector',
        authorAvatar: '🌿',
        category: PostCategory.question,
        title: 'Best companion crops for turmeric beds to suppress weeds?',
        description:
            'Setting up our monsoon turmeric plantation. Considering maize or red gram on borders, but looking for suggestions on intercropping within rows during initial 60 days.',
        timestamp: now.subtract(const Duration(days: 1, hours: 9)),
        likesCount: 11,
        isLiked: false,
        comments: [],
      ),
    ];
  }
}
