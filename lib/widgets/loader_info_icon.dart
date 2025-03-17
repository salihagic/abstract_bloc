import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

/// A widget that displays an icon indicating whether loading is occurring
/// or if cached data is available.
class LoadInfoIcon extends StatelessWidget {
  final bool isLoading;
  final bool isCached;
  final void Function(BuildContext)? onReload;

  const LoadInfoIcon({
    super.key,
    required this.isLoading,
    required this.isCached,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    if (isLoading) {
      return _buildLoadingIndicator(abstractConfiguration, context);
    }

    if (isCached) {
      return _CachedDataIcon(onReload: onReload);
    }

    // Return an empty container when not loading and not cached
    return SizedBox.shrink();
  }

  Widget _buildLoadingIndicator(
      AbstractConfiguration? config, BuildContext context) {
    return config?.cachedDataLoaderBuilder?.call(context) ??
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            color: _getLoadingContainerColor(),
            padding: const EdgeInsets.all(14.0),
            child: const Loader(size: 12),
          ),
        );
  }

  Color _getLoadingContainerColor() {
    return Colors.white.withAlpha(125);
  }
}

/// A widget that displays an information icon indicating that cached data is being shown.
class _CachedDataIcon extends StatelessWidget {
  final void Function(BuildContext)? onReload;

  const _CachedDataIcon({this.onReload});

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    void onTap() {
      showDialog(
        context: context,
        builder: (context) {
          if (abstractConfiguration?.cachedDataWarningDialogBuilder != null) {
            return abstractConfiguration!.cachedDataWarningDialogBuilder!(
                context, onReload);
          }

          return _defaultCachedDataWarningDialog(
              abstractConfiguration, context);
        },
      );
    }

    if (abstractConfiguration?.cachedDataWarningIconBuilder != null) {
      return abstractConfiguration!.cachedDataWarningIconBuilder!(
          context, onTap);
    }

    return _defaultCachedDataIcon(onTap);
  }

  Widget _defaultCachedDataWarningDialog(
      AbstractConfiguration? config, BuildContext context) {
    return InfoDialog(
      showCancelButton: true,
      onApplyText: config?.translations.reload ?? 'Reload',
      onApply: () => onReload?.call(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config?.translations.showingCachedData ?? 'Showing cached data',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          Text(
            config?.translations.thereWasAnErrorPleaseTryAgain ??
                'There was an error, please try again',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _defaultCachedDataIcon(void Function() onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          color: Colors.white.withAlpha(125),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.info_outline,
            color: const Color(0xFFC42A03),
          ),
        ),
      ),
    );
  }
}
