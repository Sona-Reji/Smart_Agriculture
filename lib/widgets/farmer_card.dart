import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/farmer.dart';
import '../utils/app_colors.dart';
import '../screens/chat_screen.dart';

class FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback? onTap;
  final VoidCallback? onConnectTap;

  const FarmerCard({
    super.key,
    required this.farmer,
    this.onTap,
    this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      farmer.avatarEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farmer.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              farmer.experienceText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmer.farmingType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Crops info
            Row(
              children: [
                const Icon(Icons.eco_outlined, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    farmer.cropsSummary,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location & Distance
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  farmer.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  ${farmer.distanceText}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Direct Action Buttons (Call & Message)
            _buildDirectContactActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectContactActions(BuildContext context) {
    return Row(
      children: [
        // Call Button
        Expanded(
          child: SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () async {
                final phoneUri = Uri.parse('tel:${farmer.contactPhone}');
                try {
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${farmer.name} at ${farmer.contactPhone}')),
                      );
                    }
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Phone: ${farmer.contactPhone}')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: const Text(
                'CALL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Message Button
        Expanded(
          child: SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(farmer: farmer)),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text(
                'MESSAGE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
