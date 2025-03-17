import 'package:flutter/material.dart';

/// A customizable loading spinner widget.
class Loader extends StatelessWidget {
  /// The width of the loader.
  final double? width;

  /// The height of the loader.
  final double? height;

  /// The size of the circular loader.
  final double? size;

  /// The color of the loader. If null, defaults to the primary color of the theme.
  final Color? color;

  /// Creates a loader with optional width, height, size, and color.
  const Loader({
    super.key,
    this.width,
    this.height,
    this.size,
    this.color,
  });

  /// Creates a small loader with fixed size and optional color.
  const Loader.sm({
    super.key,
    this.color,
  })  : width = 16,
        height = 16,
        size = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? size,
      width: width ?? size,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
