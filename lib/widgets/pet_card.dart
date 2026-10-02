import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../services/image_storage_service.dart';
import 'status_badge.dart';

/// Highly polished, responsive reusable Pet Card for Whisker World
class PetCard extends StatefulWidget {
  final PetModel pet;
  final VoidCallback? onTap;
  final bool showOwnerActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const PetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.showOwnerActions = false,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isFav = false;
    if (widget.isFavorite != null) {
      isFav = widget.isFavorite!;
    } else {
      try {
        final authProvider = context.watch<AuthProvider>();
        final favProvider = context.watch<FavoriteProvider>();
        final currentUserId = authProvider.currentUser?.id;
        isFav = currentUserId != null && favProvider.isFavorite(widget.pet.id);
      } catch (_) {
        isFav = false;
      }
    }

    final imageUrl = widget.pet.primaryImageUrl ?? ImageStorageService().getFallbackImage(widget.pet.animalType);
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    // Format currency fee (supports ₹ / INR e.g. ₹8,000 and \$ e.g. \$250)
    final isUsd = widget.pet.location.contains('TX') ||
        widget.pet.location.contains('OR') ||
        widget.pet.location.contains('AZ') ||
        widget.pet.location.contains('Austin') ||
        (widget.pet.adoptionFee > 0 && widget.pet.adoptionFee < 1000);
    final feeText = widget.pet.adoptionFee > 0
        ? (isUsd
            ? '\$${widget.pet.adoptionFee.toInt()}'
            : '₹${widget.pet.adoptionFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}')
        : 'Free';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _isHovered ? -4.0 : 0.0, 0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryCoral.withValues(alpha: 0.5) : border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : (_isHovered
                      ? AppTheme.primaryCoral.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.05)),
              blurRadius: _isHovered ? 18 : 12,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap ?? () => context.go('/pets/${widget.pet.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🐾', style: TextStyle(fontSize: 36)),
                                const SizedBox(height: 6),
                                Text(
                                  widget.pet.displayYoungName,
                                  style: TextStyle(
                                    color: textSec,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Top-Left: Young Animal Name Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🐾', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
                          Text(
                            widget.pet.displayYoungName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right: Favorite Button (Public)
                  if (!widget.showOwnerActions)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Tooltip(
                        message: isFav ? 'Remove from favorites' : 'Favorite',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onFavoriteToggle ?? () async {
                              final currentUserId = context.read<AuthProvider?>()?.currentUser?.id;
                              if (currentUserId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please log in to save favorites!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              await context.read<FavoriteProvider>().toggleFavorite(currentUserId, widget.pet.id);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDark ? AppTheme.darkSurface : Colors.white).withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 18,
                                color: isFav ? const Color(0xFFE91E63) : textSec,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom-Left: Availability Status Badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: StatusBadge.forPet(widget.pet.availabilityStatus),
                  ),
                ],
              ),

              // Card Body Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Gender Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.pet.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: textPrim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildGenderBadge(widget.pet.gender),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Breed
                    Text(
                      widget.pet.breed,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSec,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Clear Age Pill (e.g. 7 weeks old)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cake_outlined, size: 12, color: AppTheme.primaryCoral),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.pet.ageValue} ${widget.pet.ageUnit.name} old',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: textPrim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Location Row with 📍 Pin
                    Row(
                      children: [
                        const Text('📍 ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            widget.pet.location.isNotEmpty ? widget.pet.location : 'Location on request',
                            style: TextStyle(fontSize: 12, color: textSec, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Footer: Adoption Fee & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Adoption Fee',
                                style: TextStyle(fontSize: 10, color: textSec),
                              ),
                              Text(
                                feeText,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryCoral,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.showOwnerActions)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onToggleStatus != null)
                                IconButton(
                                  icon: Icon(
                                    widget.pet.isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                    size: 20,
                                    color: AppTheme.naturalSageGreen,
                                  ),
                                  tooltip: widget.pet.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                                  onPressed: widget.onToggleStatus,
                                ),
                              if (widget.onEdit != null)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryCoral),
                                  tooltip: 'Edit Pet',
                                  onPressed: widget.onEdit,
                                ),
                              if (widget.onDelete != null)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD32F2F)),
                                  tooltip: 'Delete Pet',
                                  onPressed: widget.onDelete,
                                ),
                            ],
                          )
                        else
                          ElevatedButton(
                            onPressed: widget.onTap ?? () => context.go('/pets/${widget.pet.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryCoral,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
      ),
    );
  }

  Widget _buildGenderBadge(Gender gender) {
    final isMale = gender == Gender.male;
    final isFemale = gender == Gender.female;
    final color = isMale
        ? const Color(0xFF1976D2)
        : (isFemale ? const Color(0xFFD81B60) : AppTheme.charcoalLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gender.name.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
