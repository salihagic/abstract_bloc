import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

class LoadInfoIcon extends StatelessWidget {
  final bool isLoading;
  final bool isCached;
  final void Function(BuildContext)? onReload;

  const LoadInfoIcon({
    Key? key,
    required this.isLoading,
    required this.isCached,
    this.onReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isLoading)
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              color: Colors.white.withOpacity(0.5),
              padding: const EdgeInsets.all(14.0),
              child: const Loader(size: 12),
            ),
          ),
        if (isCached && !isLoading)
          ShowingCachedDataIcon(
            onReload: onReload,
            icon: Icons.warning_amber_rounded,
            allowReload: true,
          ),
      ],
    );
  }
}
