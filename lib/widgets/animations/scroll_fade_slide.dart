import 'package:flutter/material.dart';

/// ScrollFadeSlide applies a smooth fade-in and slide-up transition
/// when mounted or when scrolled into view.
class ScrollFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double slideOffset;
  final Curve curve;

  const ScrollFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.slideOffset = 28.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScrollFadeSlide> createState() => _ScrollFadeSlideState();
}

class _ScrollFadeSlideState extends State<ScrollFadeSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<double>(
      begin: widget.slideOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
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
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
