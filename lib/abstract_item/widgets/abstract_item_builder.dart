import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/material.dart';

/// A generic widget for displaying different states of an item using BLoC or Cubit pattern.
class AbstractItemBuilder<B extends StateStreamableSource<S>,
    S extends AbstractItemState> extends StatelessWidget {
  // Optional initialization callback
  final void Function(BuildContext context)? onInit;

  // Flag to indicate if the initial onInit should be skipped
  final bool skipInitialOnInit;

  // Flag to show/hide the cached data warning icon
  final bool showCachedDataWarningIcon;

  // Builder for displaying error states
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;

  // Builder for displaying no data states
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;

  // Builder for the loading state
  final Widget Function(BuildContext context, S state)? loaderBuilder;

  // Condition to check if the current state is loading
  final bool Function(BuildContext context, S state)? isLoading;

  // Condition to check if the current state encountered an error
  final bool Function(BuildContext context, S state)? isError;

  // Condition to check if the current state has data
  final bool Function(BuildContext context, S state)? hasData;

  // An optional child widget to include in the output
  final Widget? child;

  // Builder function for presenting the main content when data is available
  final Widget Function(BuildContext context, S state)? builder;

  // Listener for reacting to state changes
  final void Function(BuildContext context, S state)? listener;

  // Callback invoked when data has been loaded
  final void Function(BuildContext context, S state)? onLoaded;

  // Callback for when cached data has been loaded
  final void Function(BuildContext context, S state)? onLoadedCached;

  // Callback for handling errors
  final void Function(BuildContext context, S state)? onError;

  // A pre-existing instance of BLoC or Cubit
  final B? providerValue;

  // A factory method for creating a new BLoC or Cubit instance
  final B Function(BuildContext context)? provider;

  // List of providers for multiple BLoC or Cubit instances
  final List<SingleChildWidget>? providers;

  /// Constructs an instance of [AbstractItemBuilder].
  const AbstractItemBuilder({
    super.key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.showCachedDataWarningIcon = true,
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
  });

  // Checks if the current state is in loading, either from the network or cached
  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??

      // Defaults to checking the state result status
      (state.resultStatus == ResultStatus.loading ||
          state.resultStatus == ResultStatus.loadedCached);

  // Checks if the current state has an error
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ?? state.resultStatus == ResultStatus.error;

  // Checks if the current state has valid data
  bool _hasData(BuildContext context, S state) =>
      hasData?.call(context, state) ?? state.item != null;

  // Checks if current state contains cached error data
  bool _isCached(BuildContext context, S state) =>
      _isError(context, state) && _hasData(context, state);

  // Checks if there is no data present
  bool _isEmpty(BuildContext context, S state) => !_hasData(context, state);

  // Retrieves the BLoC or Cubit instance from the context
  B _blocOrCubitInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      // Logs the error if no BLoC or Cubit is found
      debugPrint('There is no instance of bloc or cubit registered: $e');
      rethrow;
    }
  }

  // Initializes the BLoC or Cubit and triggers loading operation
  void _onInit(BuildContext context) {
    if (onInit != null) {
      onInit?.call(context); // Calls the provided onInit callback
    } else {
      final instance =
          _blocOrCubitInstance(context); // Gets the BLoC or Cubit instance

      // Dispatches loading event if it's an AbstractItemBloc
      if (instance is AbstractItemBloc) {
        (instance as AbstractItemBloc).add(AbstractItemLoadEvent());
      }

      // Calls load method if it's an AbstractItemCubit
      if (instance is AbstractItemCubit) {
        (instance as AbstractItemCubit).load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration =
        AbstractConfiguration.of(context); // Gets configuration

    final mainChild = AbstractStatefulBuilder(
      // Initializes the state of the child on first load
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context); // Calls _onInit if the initial call is not skipped
        }
      },
      // Handles the state changes in the child widget
      builder: (context) => BlocConsumer<B, S>(
        listener: (context, state) {
          listener?.call(
              context, state); // Invokes the listener for state changes

          // Handles different loading states and their respective callbacks
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
          // Displays the loader if still loading and no data is present
          if (_isLoading(context, state) && _isEmpty(context, state)) {
            return loaderBuilder?.call(context, state) ??
                abstractConfiguration?.loaderBuilder?.call(context) ??
                const Loader();
          }

          // Handles the case where there is no data available
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

          // Displays the main content when data is present
          return Stack(
            children: [
              child ?? builder?.call(context, state) ?? Container(),

              // Displays cached data warning if enabled
              if (showCachedDataWarningIcon)
                Positioned(
                  top: 0,
                  right: 0,
                  child: LoadInfoIcon(
                    isLoading:
                        _isLoading(context, state), // Passes loading state
                    isCached: _isCached(context, state), // Passes cached state
                    onReload: (_) =>
                        _onInit(context), // Reloads data on request
                  ),
                ),
            ],
          );
        },
      ),
    );

    // Provides the BLoC/Cubit as needed to the widget tree
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

    if (providers != null && providers!.isNotEmpty) {
      return MultiBlocProvider(
        providers: providers!,
        child: mainChild,
      );
    }

    return mainChild; // Returns the main child if no providers are set
  }
}
