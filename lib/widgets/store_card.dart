import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../models/pet_store_model.dart';

/// Reusable Store Card for Whisker World with cover banner, logo avatar, verified badge, and pet count
class StoreCard extends StatefulWidget {
  final PetStoreModel store;
  final int petCount;
  final VoidCallback? onTap;
  final bool showManageActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  const StoreCard({
    super.key,
    required this.store,
    this.petCount = 0,
    this.onTap,
    this.showManageActions = false,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _isHovered ? -3.0 : 0.0, 0),
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
                  ? Colors.black.withValues(alpha: 0.3)
                  : (_isHovered
                      ? AppTheme.primaryCoral.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.04)),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap ?? () => context.go('/stores/${widget.store.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Banner & Overlapping Logo
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                    child: Image.network(
                      widget.store.displayCoverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppTheme.primaryCoral.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(Icons.storefront_rounded, size: 40, color: AppTheme.primaryCoral),
                        ),
                      ),
                    ),
                  ),

                  // Top-Right: Pet Count Pill
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.darkSurface : Colors.white).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
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
                            '${widget.petCount} available',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryCoral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom-Left Logo Avatar (Overlapping)
                  Positioned(
                    bottom: -20,
                    left: 16,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardBg,
                        border: Border.all(color: cardBg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          widget.store.displayLogoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Text('🏡', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Store Content Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Verified Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.store.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Tooltip(
                          message: 'Verified Ethical Caregiver Center',
                          child: Icon(Icons.verified_rounded, size: 16, color: AppTheme.naturalSageGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.primaryCoral),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.store.fullLocation,
                            style: TextStyle(fontSize: 12, color: textSec),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      widget.store.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSec,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              const Divider(height: 16),

              // Footer Action
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: widget.showManageActions
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.onToggleActive != null)
                            TextButton.icon(
                              onPressed: widget.onToggleActive,
                              icon: Icon(
                                widget.store.isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 15,
                                color: widget.store.isActive ? AppTheme.naturalSageGreen : textSec,
                              ),
                              label: Text(
                                widget.store.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.store.isActive ? AppTheme.naturalSageGreen : textSec,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onEdit != null)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  color: AppTheme.primaryCoral,
                                  tooltip: 'Edit Store',
                                  onPressed: widget.onEdit,
                                ),
                              if (widget.onDelete != null)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                  color: const Color(0xFFD32F2F),
                                  tooltip: 'Delete Store',
                                  onPressed: widget.onDelete,
                                ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.store.openingHours != null && widget.store.openingHours!.isNotEmpty
                                ? widget.store.openingHours!
                                : 'Open Daily',
                            style: TextStyle(fontSize: 11, color: textSec),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'View Store →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryCoral,
                            ),
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
}
