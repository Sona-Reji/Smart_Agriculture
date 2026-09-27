import 'package:flutter/material.dart';
import '../services/resource_service.dart';
import '../models/resource.dart';
import '../models/resource_request.dart';
import '../widgets/resource_card.dart';
import '../widgets/worker_card.dart';
import '../widgets/category_card.dart';
import '../utils/app_colors.dart';
import 'resource_details_screen.dart';
import 'create_request_screen.dart';
import 'create_resource_screen.dart';

class ResourcesScreen extends StatefulWidget {
  final ResourceService service;

  const ResourcesScreen({
    super.key,
    required this.service,
  });

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final resources = widget.service.filteredResources;
        final workers = widget.service.workers;
        final requests = widget.service.myRequests;

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Find what you need. Share what you have.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                tooltip: 'Share / List Resource',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateResourceScreen(service: widget.service),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                const Tab(text: 'BROWSE'),
                const Tab(text: 'WORKERS'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('MY REQUESTS'),
                      if (requests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Browse Resources
                _buildBrowseTab(resources),

                // Tab 2: Farm Workers
                _buildWorkersTab(workers),

                // Tab 3: My Requests
                _buildRequestsTab(requests),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateRequestScreen(service: widget.service),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_task_rounded, size: 20),
            label: const Text(
              'Request Resource',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowseTab(List<Resource> resources) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: widget.service.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search equipment, power tiller, seeds, pump...',
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
        ),

        // Category Cards Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              CategoryCard(
                category: null,
                label: 'All Items',
                emoji: '🌾',
                isSelected: widget.service.selectedCategory == null,
                onTap: () => widget.service.setCategory(null),
              ),
              const SizedBox(width: 8),
              ...ResourceCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryCard(
                    category: cat,
                    label: cat.label,
                    emoji: cat.emoji,
                    isSelected: widget.service.selectedCategory == cat,
                    onTap: () => widget.service.setCategory(
                      widget.service.selectedCategory == cat ? null : cat,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Resources List
        Expanded(
          child: resources.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No resources found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Try searching for "tractor", "pump", "tiller", or select another category.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: resources.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final res = resources[index];
                    return ResourceCard(
                      resource: res,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResourceDetailsScreen(
                              resource: res,
                              service: widget.service,
                            ),
                          ),
                        );
                      },
                      onRequest: () => _showQuickRequestDialog(context, res),
                      onToggleSave: () {
                        widget.service.toggleSaveResource(res.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              res.isSaved
                                  ? 'Removed "${res.title}" from saved items'
                                  : 'Saved "${res.title}" to your favorites!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWorkersTab(List workers) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: workers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final worker = workers[index];
        return WorkerCard(
          worker: worker,
          onContact: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Contact ${worker.name}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role: ${worker.role}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Direct Phone: ${worker.phone}'),
                    const SizedBox(height: 6),
                    Text('Wage: ${worker.dailyRate}'),
                    const SizedBox(height: 6),
                    Text('Availability: ${worker.availability}'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${worker.name}... (Simulated)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Call Worker'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab(List<ResourceRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.assignment_outlined, size: 54, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'No requests submitted yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Tap the button below to request farm equipment, workers, or irrigation supplies.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requests[index];

        Color statusColor;
        Color statusBg;

        switch (req.status) {
          case RequestStatus.pending:
            statusColor = AppColors.statusAttention;
            statusBg = AppColors.statusAttentionBg;
            break;
          case RequestStatus.accepted:
            statusColor = AppColors.primary;
            statusBg = AppColors.primaryContainer;
            break;
          case RequestStatus.completed:
            statusColor = AppColors.textSecondary;
            statusBg = AppColors.background;
            break;
        }

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      req.resourceType.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.service.cycleRequestStatus(req.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            req.status.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.swap_horiz_rounded, size: 14, color: statusColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                req.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                req.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Needed: ${req.requiredDate}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Duration: ${req.duration}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(req.location, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  Text(req.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickRequestDialog(BuildContext context, Resource res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Request ${res.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${res.providerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Rate: ${res.priceText}'),
            const SizedBox(height: 4),
            Text('Availability: ${res.availabilityText}'),
            const SizedBox(height: 12),
            const Text(
              'Submit a booking request for this resource. The provider will receive an instant notification.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final newRequest = ResourceRequest(
                id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                resourceType: res.category.label,
                title: 'Request: ${res.title}',
                description: 'Requested from ${res.providerName} (${res.location})',
                requiredDate: 'Within 24 Hours',
                duration: 'Standard Period',
                location: 'Field 01',
                status: RequestStatus.pending,
                timestamp: DateTime.now(),
              );
              widget.service.addRequest(newRequest);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Request sent to ${res.providerName}! Added to "My Requests".'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Request'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
