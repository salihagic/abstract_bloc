import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractItemBuilder<B extends AbstractItemBloc<S>,
    S extends AbstractItemState> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? isError;
  final bool Function(BuildContext context, S state)? hasData;
  final Widget? child;
  final Widget Function(BuildContext context, S state)? listener;
  final Widget Function(BuildContext context, S state)? builder;

  AbstractItemBuilder({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.errorBuilder,
    this.noDataBuilder,
    this.isLoading,
    this.isError,
    this.hasData,
    this.child,
    this.listener,
    this.builder,
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

  B _blocInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      print('There is no instance of bloc registered: $e');
      throw e;
    }
  }

  void _onInit(BuildContext context) => onInit != null
      ? onInit?.call(context)
      : _blocInstance(context).add(AbstractItemLoadEvent());

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => SafeArea(
        child: BlocConsumer<B, S>(
          listener: (context, state) {
            listener?.call(context, state);
          },
          builder: (context, state) {
            if (_isLoading(context, state) && _isEmpty(context, state)) {
              return abstractConfiguration?.loaderBuilder?.call(context) ??
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
      ),
    );
  }
}
