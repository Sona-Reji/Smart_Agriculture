import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/resource_service.dart';
import '../utils/app_colors.dart';

class CreateResourceScreen extends StatefulWidget {
  final ResourceService service;

  const CreateResourceScreen({
    super.key,
    required this.service,
  });

  @override
  State<CreateResourceScreen> createState() => _CreateResourceScreenState();
}

class _CreateResourceScreenState extends State<CreateResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _availController = TextEditingController(text: 'Available Today');
  final _locationController = TextEditingController(text: 'Field 01 Vicinity');
  final _priceController = TextEditingController(text: '₹500 / day');

  ResourceCategory _selectedCategory = ResourceCategory.equipment;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _availController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newRes = Resource(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        providerName: 'You (Farmer)',
        providerPhone: '+91 98765 43210',
        location: _locationController.text.trim(),
        distanceKm: 0.1,
        availabilityText: _availController.text.trim(),
        priceText: _priceController.text.trim(),
        description: _descController.text.trim(),
        iconEmoji: _selectedCategory.emoji,
        createdAt: DateTime.now(),
      );

      widget.service.addResource(newRes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Resource listed! Visible to nearby community farmers.'),
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
        title: const Text('Share / List Resource'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selector
                const Text(
                  'RESOURCE CATEGORY',
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
                  children: ResourceCategory.values.map((cat) {
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
                const SizedBox(height: 18),

                // Resource Title
                const Text(
                  'RESOURCE TITLE',
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
                    hintText: 'e.g., Solar Water Pump, Seedling Trays, Power Weeder',
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
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 18),

                // Description
                const Text(
                  'DESCRIPTION & SPECIFICATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Mention condition, horsepower, capacity, attachments included, or terms of use...',
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
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                ),
                const SizedBox(height: 18),

                // Availability & Price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AVAILABILITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _availController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Available Today',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RENTAL / PRICE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              hintText: 'e.g., ₹500 / day',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Location
                const Text(
                  'GENERAL LOCATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Field 01 Vicinity, East Road',
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
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'LIST RESOURCE',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
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
