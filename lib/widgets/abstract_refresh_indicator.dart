import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lightweight pull-to-refresh indicator that displays a caller-provided
/// [icon] instead of the Material progress arc used by [RefreshIndicator].
///
/// The icon rotates proportionally to the drag distance while the user pulls
/// and spins continuously while [onRefresh] is in flight. No external
/// dependencies are required — the widget listens to scroll notifications from
/// its [child] and renders the icon in an overlay above it.
class AbstractRefreshIndicator extends StatefulWidget {
  /// The scrollable below the indicator. Must use a scroll physics that
  /// reports overscroll (e.g. [AlwaysScrollableScrollPhysics] or
  /// [BouncingScrollPhysics]) so the pull gesture is detectable when there
  /// are few items.
  final Widget child;

  /// Called when the user pulls past [triggerDistance] and releases. The
  /// returned future controls how long the spinning state is shown.
  final Future<void> Function() onRefresh;

  /// The icon to display. Typically an [Icon] or [SvgPicture] sized around
  /// 24-32 logical pixels.
  final Widget icon;

  /// Pixels of overscroll required to trigger a refresh.
  final double triggerDistance;

  /// Damping applied to overscroll deltas so the icon trails the finger.
  /// Values closer to 1 follow the finger 1:1; smaller values feel heavier.
  final double dragDamping;

  /// Duration of one full rotation while [onRefresh] is running.
  final Duration spinDuration;

  const AbstractRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.icon,
    this.triggerDistance = 80,
    this.dragDamping = 0.5,
    this.spinDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AbstractRefreshIndicator> createState() =>
      _AbstractRefreshIndicatorState();
}

class _AbstractRefreshIndicatorState extends State<AbstractRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  double _dragOffset = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: widget.spinDuration,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    // Ignore notifications from nested horizontal scrollables (e.g. carousels
    // inside list items). Only the outer vertical scroll should drive refresh.
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0 && notification.metrics.pixels <= 0) {
        setState(() {
          _dragOffset =
              (_dragOffset - notification.overscroll * widget.dragDamping)
                  .clamp(0.0, widget.triggerDistance * 2);
        });
      }
    } else if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null &&
          notification.metrics.pixels <= 0 &&
          (notification.scrollDelta ?? 0) < 0) {
        setState(() {
          _dragOffset =
              (_dragOffset - notification.scrollDelta! * widget.dragDamping)
                  .clamp(0.0, widget.triggerDistance * 2);
        });
      } else if (_dragOffset > 0 && (notification.scrollDelta ?? 0) > 0) {
        // User reversed direction while still dragging — shrink the indicator.
        setState(() {
          _dragOffset = (_dragOffset - (notification.scrollDelta ?? 0)).clamp(
            0.0,
            double.infinity,
          );
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= widget.triggerDistance) {
        _startRefresh();
      } else if (_dragOffset > 0) {
        setState(() => _dragOffset = 0);
      }
    }

    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _dragOffset = widget.triggerDistance;
    });
    _spinController.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / widget.triggerDistance).clamp(0.0, 1.0);
    const indicatorSize = 40.0;
    final indicatorOffset = _dragOffset - indicatorSize;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.child,
        ),
        Positioned(
          top: indicatorOffset,
          left: 0,
          right: 0,
          height: indicatorSize,
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: progress,
                child: _isRefreshing
                    ? RotationTransition(
                        turns: _spinController,
                        child: widget.icon,
                      )
                    : Transform.rotate(
                        angle: progress * 2 * math.pi,
                        child: widget.icon,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
