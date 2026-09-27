import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/community_service.dart';
import '../services/resource_service.dart';
import '../services/sensor_data_service.dart';
import '../models/resource_request.dart';
import '../widgets/farmer_card.dart';
import '../widgets/resource_card.dart';
import '../utils/app_colors.dart';
import 'farmer_profile_screen.dart';
import 'resource_details_screen.dart';
import 'create_resource_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final CommunityService communityService;
  final ResourceService resourceService;
  final SensorDataService sensorService;

  const ProfileScreen({
    super.key,
    required this.communityService,
    required this.resourceService,
    required this.sensorService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedSectionIndex = 0; // 0: My Fields, 1: My Resources, 2: My Requests, 3: Requests Received, 4: Saved, 5: Connections, 6: Settings

  // Settings mock state
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedUnit = 'Metric (°C, %RH)';
  bool _criticalAlertsSound = true;
  
  // Profile State
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;
  bool _isUpdatingLocation = false;

  Future<String> _getHumanReadableAddress(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=14&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SmartAgriApp/1.0',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final locality = address['village'] ??
              address['town'] ??
              address['city'] ??
              address['suburb'] ??
              address['county'] ??
              address['district'];
          final state = address['state'] ?? address['country'];

          if (locality != null && state != null) {
            return '$locality, $state';
          } else if (locality != null) {
            return locality.toString();
          } else if (state != null) {
            return state.toString();
          }
        }
      }
    } catch (_) {
      // Fallback if HTTP geocoding fails
    }

    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  Future<void> _updateLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isUpdatingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String humanReadableLoc = await _getHumanReadableAddress(
        position.latitude,
        position.longitude,
      );

      await FirebaseDatabase.instance.ref('users/$uid/location').set({
        'lat': position.latitude,
        'lng': position.longitude,
        'address': humanReadableLoc,
      });
      
      await FirebaseDatabase.instance.ref('users/$uid/profile').update({
        'location': humanReadableLoc,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $errorMsg'),
            backgroundColor: AppColors.statusCritical,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingLocation = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _userProfile = {
            'name': 'Guest Farmer',
            'farmingType': 'Organic & Smart Farming',
            'location': 'Kattappana, Kerala',
            'avatarEmoji': '👨‍🌾',
            'about': 'Welcome to Smart Agri! Login or register to sync profile & location with Firebase.',
          };
          _isLoadingProfile = false;
        });
      }
      return;
    }
    
    try {
      final ref = FirebaseDatabase.instance.ref('users/$uid/profile');
      ref.onValue.listen((event) {
        if (event.snapshot.exists) {
          if (mounted) {
            setState(() {
              _userProfile = Map<String, dynamic>.from(event.snapshot.value as Map);
              _isLoadingProfile = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingProfile = false);
        }
      }, onError: (_) {
        if (mounted) setState(() => _isLoadingProfile = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _editProfileDialog() async {
    if (_userProfile == null) return;
    
    final nameCtrl = TextEditingController(text: _userProfile!['name'] ?? '');
    final typeCtrl = TextEditingController(text: _userProfile!['farmingType'] ?? '');
    final locCtrl = TextEditingController(text: _userProfile!['location'] ?? '');
    final aboutCtrl = TextEditingController(text: _userProfile!['about'] ?? '');
    final phoneCtrl = TextEditingController(text: _userProfile!['contactPhone'] ?? '');
    final emojiCtrl = TextEditingController(text: _userProfile!['avatarEmoji'] ?? '👨‍🌾');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Farming Type')),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                TextField(controller: emojiCtrl, decoration: const InputDecoration(labelText: 'Avatar Emoji')),
                TextField(controller: aboutCtrl, decoration: const InputDecoration(labelText: 'Bio / About'), maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseDatabase.instance.ref('users/$uid/profile').update({
                    'name': nameCtrl.text.trim(),
                    'farmingType': typeCtrl.text.trim(),
                    'location': locCtrl.text.trim(),
                    'about': aboutCtrl.text.trim(),
                    'contactPhone': phoneCtrl.text.trim(),
                    'avatarEmoji': emojiCtrl.text.trim().isEmpty ? '👨‍🌾' : emojiCtrl.text.trim(),
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.communityService, widget.resourceService, widget.sensorService]),
      builder: (context, _) {
        final myRequests = widget.resourceService.myRequests;
        final requestsReceived = widget.resourceService.requestsReceived;
        final myResources = widget.resourceService.myListedResources;
        final savedResources = widget.resourceService.savedResources;
        final connectedFarmers = widget.communityService.connectedFarmers;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Farmer Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => setState(() => _selectedSectionIndex = 6),
              ),
            ],
          ),
          body: SafeArea(
            child: _isLoadingProfile 
              ? const Center(child: CircularProgressIndicator()) 
              : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  _buildProfileHeaderCard(),
                  const SizedBox(height: 16),

                  // 7 Section Filter Chips
                  _buildSectionSelector(
                    myResourcesCount: myResources.length,
                    myRequestsCount: myRequests.length,
                    receivedCount: requestsReceived.where((r) => r.status == RequestStatus.pending).length,
                    savedCount: savedResources.length,
                    connectedCount: connectedFarmers.length,
                  ),
                  const SizedBox(height: 16),

                  // Section Content
                  _buildSelectedSectionContent(
                    myRequests: myRequests,
                    requestsReceived: requestsReceived,
                    myResources: myResources,
                    savedResources: savedResources,
                    connectedFarmers: connectedFarmers,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderCard() {
    final name = _userProfile?['name'] ?? 'Loading...';
    final type = _userProfile?['farmingType'] ?? 'Farmer';
    final location = _userProfile?['location'] ?? 'Location not set';
    final emoji = _userProfile?['avatarEmoji'] ?? '👨‍🌾';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: _editProfileDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isUpdatingLocation)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.my_location, size: 16, color: AppColors.primary),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 8.0),
                            tooltip: 'Update Location',
                            onPressed: _updateLocation,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_userProfile?['about'] != null && _userProfile!['about'].toString().isNotEmpty) ...[
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _userProfile!['about'],
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionSelector({
    required int myResourcesCount,
    required int myRequestsCount,
    required int receivedCount,
    required int savedCount,
    required int connectedCount,
  }) {
    final sections = [
      {'label': '🌱 My Fields', 'badge': null},
      {'label': '🚜 My Resources', 'badge': myResourcesCount},
      {'label': '📩 My Requests', 'badge': myRequestsCount},
      {'label': '📥 Requests Received', 'badge': receivedCount > 0 ? receivedCount : null},
      {'label': '🔖 Saved Resources', 'badge': savedCount},
      {'label': '🧑‍🌾 Nearby Farmers', 'badge': connectedCount},
      {'label': '⚙️ Settings', 'badge': null},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sections.asMap().entries.map((entry) {
          final idx = entry.key;
          final sec = entry.value;
          final isSelected = _selectedSectionIndex == idx;
          final badge = sec['badge'] as int?;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                badge != null ? '${sec['label']} ($badge)' : sec['label'] as String,
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedSectionIndex = idx);
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

  Widget _buildSelectedSectionContent({
    required List<ResourceRequest> myRequests,
    required List<ResourceRequest> requestsReceived,
    required List myResources,
    required List savedResources,
    required List connectedFarmers,
  }) {
    switch (_selectedSectionIndex) {
      case 0:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Field 01 (Active Monitoring)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.statusGoodBg, borderRadius: BorderRadius.circular(8)),
                    child: const Text('🟢 LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.statusGood)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Crops: Hybrid Tomato, Bell Pepper, Wheat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('Location: Kattappana Sector 2 • Area: 3.2 Acres', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RESOURCES LISTED BY YOU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateResourceScreen(service: widget.resourceService),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('+ Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (myResources.isEmpty)
              _buildEmptySection(
                icon: Icons.inventory_2_outlined,
                title: 'No shared resources listed',
                subtitle: 'Tap "+ Add Resource" above to list your tractor, tiller, water pump, or tools for nearby farmers.',
              )
            else
              Column(
                children: myResources.map<Widget>((r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ResourceCard(
                      resource: r,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResourceDetailsScreen(resource: r, service: widget.resourceService),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        );

      case 2:
        if (myRequests.isEmpty) {
          return _buildEmptySection(
            icon: Icons.assignment_outlined,
            title: 'No resource requests active',
            subtitle: 'You have not submitted any equipment or worker requests.',
          );
        }
        return Column(
          children: myRequests.map<Widget>((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      _buildStatusBadge(req.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(req.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Needed: ${req.requiredDate} • ${req.duration}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            );
          }).toList(),
        );

      case 3:
        if (requestsReceived.isEmpty) {
          return _buildEmptySection(
            icon: Icons.inbox_rounded,
            title: 'No incoming requests',
            subtitle: 'Requests from other farmers for your equipment or resources will appear here.',
          );
        }
        return Column(
          children: requestsReceived.map<Widget>((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          req.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      _buildStatusBadge(req.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(req.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Date: ${req.requiredDate} • Duration: ${req.duration}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 12),

                  if (req.status == RequestStatus.pending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              widget.resourceService.declineReceivedRequest(req.id);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.statusCritical,
                              side: const BorderSide(color: AppColors.statusCritical),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.resourceService.acceptReceivedRequest(req.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ] else if (req.status == RequestStatus.accepted) ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.statusGood, size: 16),
                        const SizedBox(width: 6),
                        const Text('Request Accepted', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusGood)),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );

      case 4:
        if (savedResources.isEmpty) {
          return _buildEmptySection(
            icon: Icons.bookmark_border_rounded,
            title: 'No saved resources',
            subtitle: 'Bookmark power tillers, seeds, pumps, or supplies to quickly find them here.',
          );
        }
        return Column(
          children: savedResources.map<Widget>((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ResourceCard(
                resource: r,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResourceDetailsScreen(resource: r, service: widget.resourceService),
                    ),
                  );
                },
                onToggleSave: () => widget.resourceService.toggleSaveResource(r.id),
              ),
            );
          }).toList(),
        );

      case 5:
        final nearby = widget.communityService.farmers;
        if (nearby.isEmpty) {
          return _buildEmptySection(
            icon: Icons.people_outline_rounded,
            title: 'No nearby farmers found',
            subtitle: 'Registered farmers near your location will automatically appear here.',
          );
        }
        return Column(
          children: nearby.map<Widget>((farmer) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FarmerCard(
                farmer: farmer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FarmerProfileScreen(
                        farmer: farmer,
                        communityService: widget.communityService,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );

      case 6:
        return _buildSettingsSection(context);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color bg;
    Color color;
    switch (status) {
      case RequestStatus.pending:
        bg = AppColors.statusAttentionBg;
        color = AppColors.statusAttention;
        break;
      case RequestStatus.accepted:
        bg = AppColors.statusGoodBg;
        color = AppColors.statusGood;
        break;
      case RequestStatus.completed:
        bg = AppColors.background;
        color = AppColors.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status.label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('APPLICATION SETTINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.textSecondary)),
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text('Telemetry Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Instant alerts for low soil moisture & water level', style: TextStyle(fontSize: 11)),
            value: _notificationsEnabled,
            activeTrackColor: AppColors.primaryLight,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),

          SwitchListTile(
            title: const Text('Critical Alarm Buzzer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Play sound when gateway disconnects', style: TextStyle(fontSize: 11)),
            value: _criticalAlertsSound,
            activeTrackColor: AppColors.primaryLight,
            onChanged: (val) => setState(() => _criticalAlertsSound = val),
          ),
        ],
      ),
    );
  }
}
