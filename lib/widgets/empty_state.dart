import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Clean, visually attractive empty state widget with icon, title, description, and action button
class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? emoji;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.emoji,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  /// Factory for no pets found
  factory EmptyState.noPets({VoidCallback? onReset}) {
    return EmptyState(
      emoji: '🐾',
      title: 'No Companions Found',
      description: 'We couldn\'t find any pets matching your active search or filters. Try adjusting criteria or clear filters to see more adorable companions.',
      actionLabel: onReset != null ? 'Reset Filters' : null,
      actionIcon: Icons.refresh_rounded,
      onAction: onReset,
    );
  }

  /// Factory for no stores found
  factory EmptyState.noStores({VoidCallback? onReset}) {
    return EmptyState(
      emoji: '🏡',
      title: 'No Pet Stores Found',
      description: 'No verified pet nurseries or sanctuaries match your query. Check your search term or view all partner locations.',
      actionLabel: onReset != null ? 'View All Stores' : null,
      actionIcon: Icons.storefront_rounded,
      onAction: onReset,
    );
  }

  /// Factory for no favorites
  factory EmptyState.noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      emoji: '❤️',
      title: 'No Saved Companions Yet',
      description: 'You haven\'t added any pets to your favorites list. Tap the heart icon on any pet card to save them for quick access later.',
      actionLabel: onExplore != null ? 'Explore Companions' : null,
      actionIcon: Icons.pets_rounded,
      onAction: onExplore,
    );
  }

  /// Factory for no adoption requests
  factory EmptyState.noRequests({VoidCallback? onExplore, bool isOwner = false}) {
    return EmptyState(
      emoji: '📋',
      title: isOwner ? 'No Adoption Inquiries Yet' : 'No Active Applications',
      description: isOwner
          ? 'You have not received any adoption inquiries yet. When adopters apply for your listed pets, their questionnaires will appear here.'
          : 'You have not submitted any adoption applications yet. Browse available young companions to begin your adoption journey!',
      actionLabel: onExplore != null ? (isOwner ? 'Manage My Pets' : 'Find a Companion') : null,
      actionIcon: Icons.pets_rounded,
      onAction: onExplore,
    );
  }

  /// Factory for empty store pets
  factory EmptyState.emptyStore({VoidCallback? onBrowseOther}) {
    return EmptyState(
      emoji: '✨',
      title: 'No Pets Currently Listed',
      description: 'This store doesn\'t have any young companions listed for adoption right now. Check back soon or explore other verified shelters.',
      actionLabel: onBrowseOther != null ? 'Browse Other Stores' : null,
      actionIcon: Icons.store_rounded,
      onAction: onBrowseOther,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final isDark = AppTheme.isDark(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or Emoji Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface
                      : AppTheme.primaryCoral.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppTheme.darkBorder
                        : AppTheme.primaryCoral.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: emoji != null
                      ? Text(emoji!, style: const TextStyle(fontSize: 42))
                      : Icon(
                          icon ?? Icons.inbox_rounded,
                          size: 42,
                          color: AppTheme.primaryCoral,
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrim,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSec,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Action button
              if (actionLabel != null && onAction != null)
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: actionIcon != null ? Icon(actionIcon, size: 18) : const SizedBox.shrink(),
                  label: Text(actionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
