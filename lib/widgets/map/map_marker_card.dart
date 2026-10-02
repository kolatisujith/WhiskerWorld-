import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../providers/map_provider.dart';

/// Interactive preview card for a selected Map pin (Store, Owner, or Chosen Pet)
class MapMarkerCard extends StatelessWidget {
  final SelectedMapItem item;
  final VoidCallback onClose;
  final VoidCallback? onCenter;

  const MapMarkerCard({
    super.key,
    required this.item,
    required this.onClose,
    this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final border = AppTheme.border(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Badge + Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTypeBadge(context),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onCenter != null)
                    IconButton(
                      icon: const Icon(Icons.my_location_rounded, size: 18),
                      tooltip: 'Center on Map',
                      onPressed: onCenter,
                      visualDensity: VisualDensity.compact,
                      color: textSec,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'Close Card',
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                    color: textSec,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Info: Image + Title/Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrim,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSec,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detailed Attributes
          _buildSpecificDetails(context),
          const SizedBox(height: 14),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (item.type) {
      case MapItemType.store:
        color = const Color(0xFF0D9488); // Teal / Emerald
        icon = Icons.storefront_rounded;
        label = 'Pet Store';
        break;
      case MapItemType.owner:
        color = AppTheme.primaryCoral;
        icon = Icons.person_rounded;
        label = 'Pet Owner';
        break;
      case MapItemType.pet:
        color = const Color(0xFFEAB308); // Golden amber
        icon = Icons.pets_rounded;
        label = '🐾 Chosen Pet';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = item.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.grey.withValues(alpha: 0.2),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    IconData icon;
    switch (item.type) {
      case MapItemType.store:
        icon = Icons.storefront_rounded;
        break;
      case MapItemType.owner:
        icon = Icons.person_rounded;
        break;
      case MapItemType.pet:
        icon = Icons.pets_rounded;
        break;
    }
    return Icon(icon, color: Colors.grey.shade500, size: 28);
  }

  Widget _buildSpecificDetails(BuildContext context) {
    final textSec = AppTheme.textSecondary(context);

    if (item.type == MapItemType.store && item.store != null) {
      final store = item.store!;
      return Column(
        children: [
          _detailRow(Icons.location_on_outlined, store.address, textSec),
          if (store.openingHours != null) ...[
            const SizedBox(height: 4),
            _detailRow(Icons.access_time_rounded, store.openingHours!, textSec),
          ],
          const SizedBox(height: 4),
          _detailRow(Icons.phone_outlined, store.phone, textSec),
        ],
      );
    } else if (item.type == MapItemType.owner && item.owner != null) {
      final owner = item.owner!;
      return Column(
        children: [
          _detailRow(Icons.location_on_outlined, owner.location ?? 'Location not specified', textSec),
          if (owner.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            _detailRow(Icons.email_outlined, owner.email, textSec),
          ],
          if (item.associatedPets.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pets_rounded, size: 14, color: textSec),
                const SizedBox(width: 6),
                Text(
                  '${item.associatedPets.length} pets up for adoption',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSec),
                ),
              ],
            ),
          ],
        ],
      );
    } else if (item.type == MapItemType.pet && item.pet != null) {
      final pet = item.pet!;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _specTag('Age', pet.formattedAge),
              _specTag('Gender', pet.gender.name.toUpperCase()),
              _specTag('Fee', pet.adoptionFee > 0 ? '\$${pet.adoptionFee.toStringAsFixed(0)}' : 'Free'),
            ],
          ),
          const SizedBox(height: 8),
          _detailRow(Icons.location_on_outlined, pet.location, textSec),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _detailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _specTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (item.type == MapItemType.store && item.store != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.go('/stores/${item.store!.id}'),
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('View Pet Store'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    } else if (item.type == MapItemType.pet && item.pet != null) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.go('/pets/${item.pet!.id}'),
              icon: const Icon(Icons.favorite_rounded, size: 16),
              label: const Text('View Pet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else if (item.type == MapItemType.owner && item.owner != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.go('/pets?query=${Uri.encodeComponent(item.owner!.name)}'),
          icon: const Icon(Icons.pets_rounded, size: 16),
          label: const Text('View Owner\'s Pets'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryCoral,
            side: const BorderSide(color: AppTheme.primaryCoral),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
