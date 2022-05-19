import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

/// Wrapper around flutter_bloc's [BlocBuilder] that abstracts the use of general network item.
/// Offers Load feature.
/// Best used with [AbstractItemBloc] and [AbstractItemState] as template paramters but not mandatory.
/// If used with [AbstractItemState] (meaning that your bloc's state extends [AbstractItemState])
/// callbacks for [isLoading], [isError] and [itemCount] could be ignored and the values would be automatically resolved.
class AbstractItemConsumer<B extends BlocBase<S>, S> extends StatelessWidget {
  /// Used to specify how to dispatch an event that initializes the item.
  /// Usually this would be <bloc>LoadEvent
  final void Function(BuildContext context)? onInit;

  /// Set this flag to true if you want to initialize the data somewhere above in the context
  final bool skipInitialOnInit;

  /// Specify the widget to be shown when an error happens
  final Widget Function(void Function() onInit, S state)? errorBuilder;

  /// When there is no data use this builder to provide placeholder widget
  final Widget Function(void Function() onInit, S state)? noDataBuilder;

  /// Provide a callback specifying weather the data is currently loading
  /// If your bloc's state extends [AbstractItemState] you can ignore this callback
  final bool Function(S state)? isLoading;

  /// Provide a callback specifying weather an error has occured while loading
  /// If your bloc's state extends [AbstractItemState] you can ignore this callback
  final bool Function(S state)? isError;

  /// Provide a callback specifying weather the state contains desired data
  /// If your bloc's state extends [AbstractItemState] you can ignore this callback
  final bool Function(S state)? hasData;

  /// Provide eather the child or a builder to specify the content of this widget
  final Widget? child;
  final Widget Function(S state)? builder;

  AbstractItemConsumer({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.errorBuilder,
    this.noDataBuilder,
    this.isLoading,
    this.isError,
    this.hasData,
    this.child,
    this.builder,
  }) : super(key: key);

  bool _isLoading(S state) =>
      isLoading?.call(state) ??
      (state is AbstractItemState &&
          (state.resultStatus == ResultStatus.loading ||
              state.resultStatus == ResultStatus.loadedCached));
  bool _isError(S state) =>
      isError?.call(state) ??
      (state is AbstractItemState && state.resultStatus == ResultStatus.error);
  bool _hasData(S state) =>
      hasData?.call(state) ??
      (state is AbstractItemState && state.item != null);
  bool _isCached(S state) => _isError(state) && _hasData(state);
  bool _isEmpty(S state) => !_hasData(state);

  AbstractItemBloc? _blocInstance(BuildContext context) {
    try {
      return (context.read<B>() as AbstractItemBloc);
    } catch (e) {
      print('There is no instance of bloc registered: $e');
      return null;
    }
  }

  void _onInit(BuildContext context) => onInit != null
      ? onInit?.call(context)
      : _blocInstance(context)?.add(AbstractItemLoadEvent());

  @override
  Widget build(BuildContext context) {
    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => SafeArea(
        child: BlocBuilder<B, S>(
          builder: (context, state) {
            if (_isLoading(state) && _isEmpty(state)) {
              return const Loader();
            }

            //There is no network data and nothing is fetched from the cache and network error occured
            if (_isEmpty(state)) {
              if (_isError(state)) {
                return errorBuilder?.call(() => _onInit(context), state) ??
                    AbstractConfiguration.of(context)
                        ?.abstractItemErrorBuilder
                        ?.call(() => _onInit(context)) ??
                    AbstractItemErrorContainer(onInit: () => _onInit(context));
              } else {
                return noDataBuilder?.call(() => _onInit(context), state) ??
                    AbstractConfiguration.of(context)
                        ?.abstractItemNoDataBuilder
                        ?.call(() => _onInit(context)) ??
                    AbstractItemNoDataContainer(onInit: () => _onInit(context));
              }
            }

            return Stack(
              children: [
                child ?? builder?.call(state) ?? Container(),
                Positioned(
                  top: 0,
                  right: 0,
                  child: LoadInfoIcon(
                    isLoading: _isLoading(state),
                    isCached: _isCached(state),
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
