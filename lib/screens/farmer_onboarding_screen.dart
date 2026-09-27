import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import 'main_navigation_screen.dart';

class FarmerOnboardingScreen extends StatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  State<FarmerOnboardingScreen> createState() => _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState extends State<FarmerOnboardingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Step 1: Farmer Profile
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isDetectingLocation = false;

  // Step 2: Farm
  final _totalAreaController = TextEditingController(text: '3.5');
  final _numberOfFieldsController = TextEditingController(text: '1');

  // Step 3: Field
  final _fieldNameController = TextEditingController(text: 'Field 01');
  final _fieldAreaController = TextEditingController(text: '3.5');
  final List<String> _selectedCrops = ['Hybrid Tomato', 'Bell Pepper'];
  final _cropInputController = TextEditingController();

  // Step 4: Resources (Optional)
  bool _addResource = false;
  final _resourceNameController = TextEditingController();
  String _resourceCategory = 'Equipment';
  String _resourceType = 'Tractor';
  final _resourcePriceController = TextEditingController(text: '₹800/hr');
  String _resourceAvailability = 'Available Now';

  final List<String> _availableCategories = [
    'Equipment',
    'Workers',
    'Seeds',
    'Tools',
    'Irrigation'
  ];

  final Map<String, List<String>> _categoryTypesMap = {
    'Equipment': ['Tractor', 'Power Tiller', 'Harvester', 'Thresher'],
    'Workers': ['Manual Worker', 'Harvest Specialist', 'Operator'],
    'Seeds': ['Coconut Seedlings', 'Tomato Seeds', 'Paddy Seeds', 'Vegetable Seeds'],
    'Tools': ['Sprayer', 'Weeder', 'Pruner', 'Chainsaw'],
    'Irrigation': ['Water Pump', 'Drip System', 'Sprinkler System'],
  };

  @override
  void initState() {
    super.initState();
    _loadExistingProfileData();
  }

  Future<void> _loadExistingProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseDatabase.instance.ref('users/$uid/profile').get();
      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        if (mounted) {
          setState(() {
            if (data['name'] != null && data['name'].toString().isNotEmpty) {
              _nameController.text = data['name'].toString();
            }
            if (data['contactPhone'] != null) {
              _phoneController.text = data['contactPhone'].toString();
            }
            if (data['location'] != null && data['location'].toString() != 'Not Set') {
              _locationController.text = data['location'].toString();
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = pos.latitude;
      _longitude = pos.longitude;

      // Reverse geocode via OpenStreetMap Nominatim
      String address = await _reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _locationController.text = address;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.statusCritical,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=14&addressdetails=1',
      );
      final res = await http.get(url, headers: {'User-Agent': 'SmartAgriApp/1.0'}).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final loc = addr['village'] ?? addr['town'] ?? addr['city'] ?? addr['suburb'] ?? addr['district'];
          final state = addr['state'] ?? addr['country'];
          if (loc != null && state != null) return '$loc, $state';
          if (loc != null) return loc.toString();
          if (state != null) return state.toString();
        }
      }
    } catch (_) {}
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  void _addCropTag() {
    final crop = _cropInputController.text.trim();
    if (crop.isNotEmpty && !_selectedCrops.contains(crop)) {
      setState(() {
        _selectedCrops.add(crop);
        _cropInputController.clear();
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _errorMessage = 'User not authenticated.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name in Step 1.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim().isEmpty ? 'Kattappana, Kerala' : _locationController.text.trim();
      final totalArea = double.tryParse(_totalAreaController.text.trim()) ?? 3.5;
      final numFields = int.tryParse(_numberOfFieldsController.text.trim()) ?? 1;

      final fieldName = _fieldNameController.text.trim().isEmpty ? 'Field 01' : _fieldNameController.text.trim();
      final fieldArea = double.tryParse(_fieldAreaController.text.trim()) ?? totalArea;

      // 1. Update user profile in RTDB
      await FirebaseDatabase.instance.ref('users/$uid/profile').update({
        'name': name,
        'contactPhone': phone,
        'location': location,
        'farmingType': 'Smart Agri Farmer',
        'totalAreaAcres': totalArea,
        'numberOfFields': numFields,
        'isOnboarded': true,
        'avatarEmoji': '👨‍🌾',
        'about': 'Managing $totalArea acres ($numFields field${numFields > 1 ? 's' : ''})',
      });

      // 2. Save location coordinates if present
      if (_latitude != null && _longitude != null) {
        await FirebaseDatabase.instance.ref('users/$uid/location').set({
          'lat': _latitude,
          'lng': _longitude,
          'address': location,
        });
      }

      // 3. Save field structure under fields/$fieldId
      final fieldId = 'field_${uid}_01';
      await FirebaseDatabase.instance.ref('fields/$fieldId').set({
        'id': fieldId,
        'ownerUid': uid,
        'name': fieldName,
        'areaAcres': fieldArea,
        'crops': _selectedCrops.isEmpty ? ['Hybrid Tomato'] : _selectedCrops,
        'current': {
          'soilMoisture': 42.0,
          'temperature': 29.5,
          'humidity': 76.0,
          'light': 680.0,
          'rain': false,
          'waterLevel': 72.0,
          'battery': 91.0,
          'deviceStatus': 'online',
          'timestamp': ServerValue.timestamp,
        },
        'createdAt': ServerValue.timestamp,
      });

      // 4. Save resource if specified
      if (_addResource && _resourceNameController.text.trim().isNotEmpty) {
        final resId = 'res_${DateTime.now().millisecondsSinceEpoch}';
        await FirebaseDatabase.instance.ref('resources/$resId').set({
          'id': resId,
          'ownerUid': uid,
          'ownerName': name,
          'ownerPhone': phone,
          'ownerLocation': location,
          'title': _resourceNameController.text.trim(),
          'category': _resourceCategory,
          'type': _resourceType,
          'price': _resourcePriceController.text.trim().isEmpty ? '₹500/day' : _resourcePriceController.text.trim(),
          'isAvailable': _resourceAvailability == 'Available Now',
          'availabilityStatus': _resourceAvailability,
          'lat': _latitude ?? 9.7523,
          'lng': _longitude ?? 76.9841,
          'createdAt': ServerValue.timestamp,
        });
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save setup: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _totalAreaController.dispose();
    _numberOfFieldsController.dispose();
    _fieldNameController.dispose();
    _fieldAreaController.dispose();
    _cropInputController.dispose();
    _resourceNameController.dispose();
    _resourcePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Farmer Setup'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppColors.cardBorder,
              color: AppColors.primary,
              minHeight: 4,
            ),
            const SizedBox(height: 12),

            // Step Title & Subtitle Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${_currentStep + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStepTitle(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        Text(
                          _getStepSubtitle(),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusCritical.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusCritical),
                  ),
                  child: Text(_errorMessage, style: const TextStyle(fontSize: 12, color: AppColors.statusCritical)),
                ),
              ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Navigation Buttons Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),

                  if (_currentStep == 3) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _completeOnboarding,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Skip Resources'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_currentStep < 3) {
                                setState(() => _currentStep++);
                              } else {
                                _completeOnboarding();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _currentStep == 3 ? 'Complete Setup' : 'Next Step →',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return '1. Farmer Profile';
      case 1:
        return '2. Farm Details';
      case 2:
        return '3. First Field Setup';
      case 3:
        return '4. Equipment & Resources';
      default:
        return '';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter your name, phone, and current location.';
      case 1:
        return 'Tell us about your total land and number of fields.';
      case 2:
        return 'Configure your primary field and crops grown.';
      case 3:
        return 'List equipment or services you are willing to share (Optional).';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: '+91 9876543210',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location / City',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _isDetectingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location, color: AppColors.primary),
                        tooltip: 'Detect Current Location',
                        onPressed: _detectCurrentLocation,
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'e.g. Kattappana, Kerala',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isDetectingLocation ? null : _detectCurrentLocation,
                icon: const Icon(Icons.gps_fixed, size: 16),
                label: const Text('Use GPS Location with Permission'),
              ),
            ),
          ],
        );

      case 1:
        return Column(
          children: [
            TextField(
              controller: _totalAreaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Total Cultivated Area (Acres) *',
                prefixIcon: const Icon(Icons.landscape_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'Acres',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberOfFieldsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Fields *',
                prefixIcon: const Icon(Icons.grid_view_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fieldNameController,
              decoration: InputDecoration(
                labelText: 'Field Name *',
                prefixIcon: const Icon(Icons.grass_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'e.g., North Field - Sector 1',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _fieldAreaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Field Area (Acres)',
                prefixIcon: const Icon(Icons.aspect_ratio_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'Acres',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Crops Grown (Multiple)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _selectedCrops.map((crop) {
                return Chip(
                  label: Text(crop),
                  onDeleted: () {
                    setState(() => _selectedCrops.remove(crop));
                  },
                  backgroundColor: AppColors.primaryContainer,
                  deleteIconColor: AppColors.primaryDark,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cropInputController,
                    decoration: InputDecoration(
                      hintText: 'Add crop (e.g. Wheat, Coconut)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (_) => _addCropTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addCropTag,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ],
        );

      case 3:
        final currentTypes = _categoryTypesMap[_resourceCategory] ?? ['Tractor'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Rent or Share Equipment/Services?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Allow nearby farmers to discover and request your resources', style: TextStyle(fontSize: 11)),
              value: _addResource,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _addResource = val),
            ),
            const Divider(),

            if (_addResource) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _resourceNameController,
                decoration: InputDecoration(
                  labelText: 'Resource / Equipment Name *',
                  prefixIcon: const Icon(Icons.build_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g. Mahindra 575 Tractor, Water Pump',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _resourceCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _availableCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _resourceCategory = val;
                      final types = _categoryTypesMap[val] ?? ['Equipment'];
                      _resourceType = types.first;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: currentTypes.contains(_resourceType) ? _resourceType : currentTypes.first,
                decoration: InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: currentTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _resourceType = val);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _resourcePriceController,
                decoration: InputDecoration(
                  labelText: 'Price / Rate',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g. ₹800/hr, ₹500/day',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _resourceAvailability,
                decoration: InputDecoration(
                  labelText: 'Availability Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Available Now', child: Text('🟢 Available Now')),
                  DropdownMenuItem(value: 'Reserved', child: Text('🟡 Reserved')),
                  DropdownMenuItem(value: 'Unavailable', child: Text('🔴 Unavailable')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _resourceAvailability = val);
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text(
                      'Ready to Complete Setup!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You can add shared resources later anytime from your Farmer Profile.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
