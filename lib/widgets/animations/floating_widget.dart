import 'dart:math' as math;
import 'package:flutter/material.dart';

/// FloatingWidget applies an organic, continuous sine-wave floating motion
/// to its child widget. Perfect for hero badges, pet icons, and atmospheric accents.
class FloatingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double verticalDistance;
  final double horizontalDistance;
  final double maxRotation; // in radians
  final double phaseOffset; // 0.0 to 1.0 phase shift

  const FloatingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3200),
    this.verticalDistance = 8.0,
    this.horizontalDistance = 0.0,
    this.maxRotation = 0.0,
    this.phaseOffset = 0.0,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + widget.phaseOffset) % 1.0;
        final radians = progress * 2 * math.pi;
        final dy = math.sin(radians) * widget.verticalDistance;
        final dx = widget.horizontalDistance > 0 ? math.cos(radians) * widget.horizontalDistance : 0.0;
        final angle = widget.maxRotation > 0 ? math.sin(radians) * widget.maxRotation : 0.0;

        Widget current = Transform.translate(
          offset: Offset(dx, dy),
          child: child,
        );

        if (widget.maxRotation > 0) {
          current = Transform.rotate(
            angle: angle,
            child: current,
          );
        }

        return current;
      },
      child: widget.child,
    );
  }
}
