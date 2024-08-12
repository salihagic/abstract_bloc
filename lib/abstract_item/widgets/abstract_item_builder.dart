import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/material.dart';

class AbstractItemBuilder<B extends StateStreamableSource<S>,
    S extends AbstractItemState> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;
  final Widget Function(BuildContext context, S state)? loaderBuilder;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? isError;
  final bool Function(BuildContext context, S state)? hasData;
  final Widget? child;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onLoaded;
  final void Function(BuildContext context, S state)? onLoadedCached;
  final void Function(BuildContext context, S state)? onError;
  final B? providerValue;
  final B Function(BuildContext context)? provider;
  final List<SingleChildWidget>? providers;

  AbstractItemBuilder({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.errorBuilder,
    this.noDataBuilder,
    this.loaderBuilder,
    this.isLoading,
    this.isError,
    this.hasData,
    this.child,
    this.builder,
    this.listener,
    this.onLoaded,
    this.onLoadedCached,
    this.onError,
    this.providerValue,
    this.provider,
    this.providers,
  }) : super(key: key);

  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      (state.resultStatus == ResultStatus.loading ||
          state.resultStatus == ResultStatus.loadedCached);
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ?? state.resultStatus == ResultStatus.error;
  bool _hasData(BuildContext context, S state) =>
      hasData?.call(context, state) ?? state.item != null;
  bool _isCached(BuildContext context, S state) =>
      _isError(context, state) && _hasData(context, state);
  bool _isEmpty(BuildContext context, S state) => !_hasData(context, state);

  B _blocOrCubitInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      print('There is no instance of bloc or cubit registered: $e');

      throw e;
    }
  }

  void _onInit(BuildContext context) {
    if (onInit != null) {
      onInit?.call(context);
    } else {
      final instance = _blocOrCubitInstance(context);

      if (instance is AbstractItemBloc) {
        (instance as AbstractItemBloc).add(AbstractItemLoadEvent());
      }

      if (instance is AbstractItemCubit) {
        (instance as AbstractItemCubit).load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    final mainChild = StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => BlocConsumer<B, S>(
        listener: (context, state) {
          listener?.call(context, state);

          if (state.resultStatus == ResultStatus.loaded) {
            onLoaded?.call(context, state);
          }
          if (state.resultStatus == ResultStatus.loadedCached) {
            onLoadedCached?.call(context, state);
          }
          if (state.resultStatus == ResultStatus.error) {
            onError?.call(context, state);
          }
        },
        builder: (context, state) {
          if (_isLoading(context, state) && _isEmpty(context, state)) {
            return loaderBuilder?.call(context, state) ??
                abstractConfiguration?.loaderBuilder?.call(context) ??
                const Loader();
          }

          //There is no network data and nothing is fetched from the cache and network error occured
          if (_isEmpty(context, state)) {
            if (_isError(context, state)) {
              return errorBuilder?.call(
                      context, () => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractItemErrorBuilder
                      ?.call(context, () => _onInit(context)) ??
                  AbstractItemErrorContainer(onInit: () => _onInit(context));
            } else {
              return noDataBuilder?.call(
                      context, () => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractItemNoDataBuilder
                      ?.call(context, () => _onInit(context)) ??
                  AbstractItemNoDataContainer(onInit: () => _onInit(context));
            }
          }

          return Stack(
            children: [
              child ?? builder?.call(context, state) ?? Container(),
              Positioned(
                top: 0,
                right: 0,
                child: LoadInfoIcon(
                  isLoading: _isLoading(context, state),
                  isCached: _isCached(context, state),
                  onReload: (_) => _onInit(context),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (providerValue != null) {
      return BlocProvider.value(
        value: providerValue!,
        child: mainChild,
      );
    }

    if (provider != null) {
      return BlocProvider<B>(
        create: provider!,
        child: mainChild,
      );
    }

    if (providers.isNotNullOrEmpty) {
      return MultiBlocProvider(
        providers: providers!,
        child: mainChild,
      );
    }

    return mainChild;
  }
}
