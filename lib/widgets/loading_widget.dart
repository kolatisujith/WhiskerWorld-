import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Branded loading indicator with animated paw pulse and customizable message
class LoadingWidget extends StatefulWidget {
  final String message;
  final double size;

  const LoadingWidget({
    super.key,
    this.message = 'Loading companions...',
    this.size = 56.0,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textSec = AppTheme.textSecondary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: widget.size + 24,
                  height: widget.size + 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primaryCoral.withValues(alpha: 0.4),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCoral),
                  ),
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurface
                          : AppTheme.primaryCoral.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🐾', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textSec,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
