import 'package:flutter/material.dart';
import '../services/resource_service.dart';
import '../services/community_service.dart';
import '../models/resource.dart';
import '../utils/app_colors.dart';
import 'resource_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  final ResourceService resourceService;
  final CommunityService communityService;
  final String? initialSearchQuery;
  final ResourceCategory? initialCategory;

  const ExploreScreen({
    super.key,
    required this.resourceService,
    required this.communityService,
    this.initialSearchQuery,
    this.initialCategory,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late TextEditingController _searchController;
  
  // Local Filter & Sort State
  String _sortBy = 'Nearest'; // Nearest, Available Now, Lowest Price
  double _maxDistance = 50.0;
  bool _availableOnly = false;
  double _maxPrice = 10000.0; // 10000 represents "Any"

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery ?? widget.resourceService.searchQuery);
    if (widget.initialSearchQuery != null) {
      widget.resourceService.setSearchQuery(widget.initialSearchQuery!);
    }
    if (widget.initialCategory != null) {
      widget.resourceService.setCategory(widget.initialCategory);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parsePrice(String price) {
    if (price.toLowerCase().contains('free')) return 0.0;
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 99999.0;
    return double.tryParse(digits) ?? 99999.0;
  }

  List<Resource> _getFilteredAndSortedResources() {
    var list = widget.resourceService.filteredResources; // Base search and category

    // Apply Distance Filter
    list = list.where((r) => r.distanceKm <= _maxDistance).toList();

    // Apply Availability Filter
    if (_availableOnly) {
      list = list.where((r) => r.isAvailable).toList();
    }

    // Apply Price Filter
    if (_maxPrice < 10000.0) {
      list = list.where((r) => _parsePrice(r.priceText) <= _maxPrice).toList();
    }

    // Apply Sorting
    list.sort((a, b) {
      if (_sortBy == 'Nearest') {
        return a.distanceKm.compareTo(b.distanceKm);
      } else if (_sortBy == 'Available Now') {
        if (a.isAvailable && !b.isAvailable) return -1;
        if (!a.isAvailable && b.isAvailable) return 1;
        return 0; // fallback to distance or original
      } else if (_sortBy == 'Lowest Price') {
        double priceA = _parsePrice(a.priceText);
        double priceB = _parsePrice(b.priceText);
        return priceA.compareTo(priceB);
      }
      return 0;
    });

    return list;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 16),
                  
                  // Category Filter
                  const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSheetCategoryChip('All', null, setSheetState),
                      ...ResourceCategory.values.map((cat) {
                        return _buildSheetCategoryChip(cat.label, cat, setSheetState);
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sort By
                  const Text('Sort By', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Nearest', 'Available Now', 'Lowest Price'].map((opt) {
                      final isSel = _sortBy == opt;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) {
                            setSheetState(() => _sortBy = opt);
                            setState(() {}); // Update main UI
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.background,
                        side: BorderSide(color: isSel ? AppColors.primary : AppColors.cardBorder),
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.primaryDark : AppColors.textSecondary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Distance Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Distance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text('${_maxDistance.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _maxDistance,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setSheetState(() => _maxDistance = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Max Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      Text(_maxPrice >= 10000.0 ? 'Any' : '₹${_maxPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setSheetState(() => _maxPrice = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),

                  // Availability Filter
                  SwitchListTile(
                    title: const Text('Available Now Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    value: _availableOnly,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setSheetState(() => _availableOnly = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetCategoryChip(String label, ResourceCategory? category, StateSetter setSheetState) {
    final isSelected = widget.resourceService.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          widget.resourceService.setCategory(category);
          setSheetState(() {});
        } else if (category != null) {
          widget.resourceService.setCategory(null);
          setSheetState(() {});
        }
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.background,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.resourceService,
      builder: (context, _) {
        final resources = _getFilteredAndSortedResources();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text('Explore Resources', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: AppColors.textPrimary),
                onPressed: _openFilterSheet,
                tooltip: 'Filter & Sort',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Prominent Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.resourceService.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search tractor, pump, worker, seeds...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              widget.resourceService.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),

              // Categories Horizontal List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildMainCategoryChip('All', null),
                    const SizedBox(width: 8),
                    ...ResourceCategory.values.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildMainCategoryChip('${cat.emoji} ${cat.label}', cat),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.cardBorder),

              // Search Results List
              Expanded(
                child: resources.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            Text('No resources match filters', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.resourceService.setSearchQuery('');
                                widget.resourceService.setCategory(null);
                                setState(() {
                                  _maxDistance = 50.0;
                                  _availableOnly = false;
                                  _maxPrice = 10000.0;
                                  _sortBy = 'Nearest';
                                });
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: resources.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final res = resources[index];
                          return _buildResourceCard(context, res);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCategoryChip(String label, ResourceCategory? category) {
    final isSelected = widget.resourceService.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.resourceService.setCategory(category);
        } else if (category != null) {
          widget.resourceService.setCategory(null);
        }
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, Resource res) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResourceDetailsScreen(
              resource: res,
              service: widget.resourceService,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        res.category.label.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
                      ),
                      Text(
                        res.priceText,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    res.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        res.isAvailable ? Icons.check_circle : Icons.do_not_disturb_alt, 
                        size: 14, 
                        color: res.isAvailable ? AppColors.statusGood : AppColors.textMuted
                      ),
                      const SizedBox(width: 4),
                      Text(
                        res.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 12, 
                          color: res.isAvailable ? AppColors.statusGood : AppColors.textMuted, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          res.distanceText,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
