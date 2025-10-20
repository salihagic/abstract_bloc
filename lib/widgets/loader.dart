import 'package:flutter/material.dart';

/// The generic loader widget.
class Loader extends StatelessWidget {
  /// The color of the loader. If null, defaults to the primary color of the app.
  final Color? color;

  /// The size of the loader.
  final double? size;

  /// The thickness of the loader.
  final double? thickness;

  const Loader({super.key, this.size, this.color, this.thickness = 1.0});

  const Loader.sm({
    super.key,
    this.size = 16,
    this.color,
    this.thickness = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
            strokeCap: StrokeCap.round,
            strokeWidth: thickness,
          ),
        ),
      ),
    );
  }
}
