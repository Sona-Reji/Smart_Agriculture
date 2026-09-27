import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../models/resource_request.dart';
import '../services/resource_service.dart';
import '../utils/app_colors.dart';

class ResourceDetailsScreen extends StatefulWidget {
  final Resource resource;
  final ResourceService service;

  const ResourceDetailsScreen({
    super.key,
    required this.resource,
    required this.service,
  });

  @override
  State<ResourceDetailsScreen> createState() => _ResourceDetailsScreenState();
}

class _ResourceDetailsScreenState extends State<ResourceDetailsScreen> {
  late Resource _resource;

  @override
  void initState() {
    super.initState();
    _resource = widget.resource;
  }

  void _toggleSave() {
    widget.service.toggleSaveResource(_resource.id);
    setState(() {
      _resource = _resource.copyWith(isSaved: !_resource.isSaved);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _resource.isSaved ? 'Saved to your bookmarked resources.' : 'Removed from bookmarks.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _submitRequest() {
    final req = ResourceRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      resourceType: _resource.category.label,
      title: 'Booking: ${_resource.title}',
      description: 'Booked directly via resource details from ${_resource.providerName}',
      requiredDate: 'Within 2 Days',
      duration: '1-2 Days',
      location: 'Field 01',
      status: RequestStatus.pending,
      timestamp: DateTime.now(),
    );

    widget.service.addRequest(req);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.statusGood),
            SizedBox(width: 8),
            Text('Request Sent!'),
          ],
        ),
        content: Text(
          'Your booking request for "${_resource.title}" was submitted to ${_resource.providerName}.\n\nTrack progress in "My Requests".',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Great'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(
            icon: Icon(
              _resource.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _resource.isSaved ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Icon / Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Center(
                        child: Text(
                          _resource.iconEmoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _resource.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            _resource.category.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.statusGoodBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _resource.availabilityText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusGood,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rate & Provider Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTIMATED RATE / PRICE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _resource.priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'PROVIDER',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _resource.providerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                'RESOURCE OVERVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  _resource.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Specifications Table (if any)
              if (_resource.specifications.isNotEmpty) ...[
                const Text(
                  'TECHNICAL SPECIFICATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: _resource.specifications.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Location & Distance
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'General Location Area',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${_resource.location} (${_resource.distanceText})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons: REQUEST & CONTACT
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contacting ${_resource.providerName} (${_resource.providerPhone})...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text(
                        'CONTACT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submitRequest,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'REQUEST RESOURCE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
