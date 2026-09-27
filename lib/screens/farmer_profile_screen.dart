import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/farmer.dart';
import '../models/resource.dart';
import '../services/community_service.dart';
import '../services/resource_service.dart';
import '../utils/app_colors.dart';
import 'chat_screen.dart';
import 'resource_details_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  final Farmer farmer;
  final CommunityService communityService;

  const FarmerProfileScreen({
    super.key,
    required this.farmer,
    required this.communityService,
  });

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late Farmer _currentFarmer;

  @override
  void initState() {
    super.initState();
    _currentFarmer = widget.farmer;
  }

  @override
  Widget build(BuildContext context) {
    final resourceService = ResourceService();
    // Getting resources owned by this farmer (using partial name match)
    final ownedResources = resourceService.resources.where((r) {
      final farmerName = _currentFarmer.name.toLowerCase();
      final provider = r.providerName.toLowerCase();
      return provider.contains(farmerName.split(' ').first) || farmerName.contains(provider);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Farmer Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile link for ${_currentFarmer.name} copied.'), behavior: SnackBarBehavior.floating));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHeroCard(),
              const SizedBox(height: 24),
              
              // About (Bio)
              const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(_currentFarmer.about, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
              ),
              const SizedBox(height: 24),

              // Farm Details (Crops & Skills)
              const Text('Farming Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              _buildFarmDetails(),
              const SizedBox(height: 24),

              // Resources Owned
              if (ownedResources.isNotEmpty) ...[
                Text('Resources by ${_currentFarmer.name.split(' ').first}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildResourcesList(ownedResources, resourceService),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image/Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(_currentFarmer.avatarEmoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),

          // Name & Rating
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentFarmer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA000)),
                    const SizedBox(width: 4),
                    Text(_currentFarmer.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA000))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          Text(_currentFarmer.farmingType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 8),

          // Location & Approx Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${_currentFarmer.location} • ${_currentFarmer.distanceText}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons (Direct Call & Direct Message)
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Call Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final phoneUri = Uri.parse('tel:${_currentFarmer.contactPhone}');
              try {
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${_currentFarmer.name} at ${_currentFarmer.contactPhone}')),
                    );
                  }
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Phone: ${_currentFarmer.contactPhone}')),
                  );
                }
              }
            },
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call Farmer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Message Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(farmer: _currentFarmer)));
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Direct Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFarmDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Main Crops', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentFarmer.mainCrops.map((crop) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(crop, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Skills & Expertise', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentFarmer.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResourcesList(List<Resource> resources, ResourceService service) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final res = resources[index];
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResourceDetailsScreen(resource: res, service: service))),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(res.iconEmoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(res.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(res.priceText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}
