import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Interactive multi-image gallery with hero preview, thumbnail strip, and lightbox dialog
class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final String fallbackEmoji;
  final String heroTag;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 360,
    this.fallbackEmoji = '🐾',
    this.heroTag = 'pet_gallery',
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isNotEmpty ? widget.imageUrls : <String>[];
    final isDark = AppTheme.isDark(context);
    final border = AppTheme.border(context);
    final cardBg = AppTheme.cardBackground(context);

    if (urls.isEmpty) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(widget.fallbackEmoji, style: const TextStyle(fontSize: 54)),
        ),
      );
    }

    final activeUrl = urls[_selectedIndex.clamp(0, urls.length - 1)];

    return Column(
      children: [
        // Main Hero Image
        GestureDetector(
          onTap: () => _openLightbox(context, urls, _selectedIndex),
          child: Hero(
            tag: '${widget.heroTag}_$_selectedIndex',
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    activeUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(widget.fallbackEmoji, style: const TextStyle(fontSize: 48)),
                    ),
                  ),
                  // Fullscreen zoom indicator
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.darkSurface : Colors.white).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fullscreen_rounded, size: 18, color: AppTheme.charcoal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Thumbnails Strip
        if (urls.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryCoral : border,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      urls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('🐾', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _openLightbox(BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        int currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.black.withValues(alpha: 0.9),
              insetPadding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InteractiveViewer(
                    maxScale: 4.0,
                    child: Image.network(
                      urls[currentIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ),
                  if (urls.length > 1 && currentIndex > 0)
                    Positioned(
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 40),
                        onPressed: () => setDialogState(() => currentIndex--),
                      ),
                    ),
                  if (urls.length > 1 && currentIndex < urls.length - 1)
                    Positioned(
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 40),
                        onPressed: () => setDialogState(() => currentIndex++),
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
}
