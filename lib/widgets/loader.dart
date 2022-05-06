import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final Color? color;

  const Loader({
    this.width,
    this.height,
    this.size,
    this.color,
  });

  const Loader.sm({
    this.width = 16,
    this.height = 16,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Theme.of(context).colorScheme.secondary),
            ),
          ),
        ),
      ),
    );
  }
}
