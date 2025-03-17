import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

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
      return abstractConfiguration?.cachedDataLoaderBuilder?.call(context) ??
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              color: Colors.white.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(14.0),
              child: const Loader(size: 12),
            ),
          );
    }

    if (isCached && !isLoading) {
      return _CachedDataIcon(onReload: onReload);
    }

    return Container();
  }
}

class _CachedDataIcon extends StatelessWidget {
  final void Function(BuildContext context)? onReload;

  const _CachedDataIcon({this.onReload});

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    void onTap() => showDialog(
          context: context,
          builder: (context) {
            if (abstractConfiguration?.cachedDataWarningDialogBuilder != null) {
              return abstractConfiguration!.cachedDataWarningDialogBuilder!(
                  context, onReload);
            }

            return InfoDialog(
              showCancelButton: true,
              onApplyText:
                  abstractConfiguration?.translations.reload ?? 'Reload',
              onApply: () => onReload?.call(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    abstractConfiguration?.translations.showingCachedData ??
                        'Showing cached data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 15),
                  Text(
                    abstractConfiguration
                            ?.translations.thereWasAnErrorPleaseTryAgain ??
                        'There was an error, please try again',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

    if (abstractConfiguration?.cachedDataWarningIconBuilder != null) {
      return abstractConfiguration!.cachedDataWarningIconBuilder!(
          context, onTap);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          color: Colors.white.withValues(alpha: 0.5),
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
