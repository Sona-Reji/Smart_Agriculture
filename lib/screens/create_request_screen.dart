import 'package:flutter/material.dart';
import '../models/resource_request.dart';
import '../services/resource_service.dart';
import '../utils/app_colors.dart';

class CreateRequestScreen extends StatefulWidget {
  final ResourceService service;

  const CreateRequestScreen({
    super.key,
    required this.service,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController(text: 'Tomorrow Morning');
  final _durationController = TextEditingController(text: '1-2 Days');
  final _locationController = TextEditingController(text: 'Field 01, Local Sector');

  String _selectedType = 'Equipment';
  final List<String> _resourceTypes = [
    'Equipment',
    'Worker',
    'Seeds',
    'Tools',
    'Irrigation',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newReq = ResourceRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: _selectedType,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        requiredDate: _dateController.text.trim(),
        duration: _durationController.text.trim(),
        location: _locationController.text.trim(),
        status: RequestStatus.pending,
        timestamp: DateTime.now(),
      );

      widget.service.addRequest(newReq);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Resource request posted! Nearby farmers notified.'),
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
        title: const Text('Request Farm Resource'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resource Type selector
                const Text(
                  'RESOURCE TYPE',
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
                  children: _resourceTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
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

                // Request Title
                const Text(
                  'REQUEST TITLE',
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
                    hintText: 'e.g., Need 45HP Tractor or 2 Harvest Hands',
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
                  'DESCRIPTION & PURPOSE',
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
                    hintText: 'Describe exact task requirements, acreage, crop type, or specifications...',
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

                // Row: Required Date & Duration
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REQUIRED DATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Tomorrow',
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
                            'DURATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _durationController,
                            decoration: InputDecoration(
                              hintText: 'e.g., 2 Days',
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
                  'GENERAL FIELD LOCATION',
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
                    hintText: 'e.g., Field 01, North Sector',
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
                      'POST REQUEST',
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
