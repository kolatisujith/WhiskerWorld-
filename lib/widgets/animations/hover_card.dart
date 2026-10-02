import 'package:flutter/material.dart';

/// HoverCard provides an interactive hover effect on desktop & web.
/// On mouse enter, it slightly lifts with an elevated shadow and subtle scale.
class HoverCard extends StatefulWidget {
  final Widget child;
  final double liftDistance;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.liftDistance = 6.0,
    this.scale = 1.015,
    this.duration = const Duration(milliseconds: 220),
    this.onTap,
    this.borderRadius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: _isHovered ? Offset(0.0, -widget.liftDistance / 100.0) : Offset.zero,
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
