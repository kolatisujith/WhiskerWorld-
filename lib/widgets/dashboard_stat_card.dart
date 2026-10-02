import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Modern responsive Dashboard Stat Card with icon gradient, count, title, and hover elevation
class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard> {
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
            color: _isHovered ? widget.iconColor.withValues(alpha: 0.5) : border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : (_isHovered
                      ? widget.iconColor.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.04)),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.iconColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 26),
                  ),
                  const SizedBox(width: 16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: textPrim,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textSec,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: widget.iconColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: textSec.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
