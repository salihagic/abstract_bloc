import 'dart:ui';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/material.dart';

/// Enum to define the behavior of scrollable headers or footers.
enum AbstractScrollBehaviour { fixed, scrollable }

/// A generic widget for building lists that support state management,
/// pagination, and refresh functionalities.
///
/// [B] - The type of BLoC or Cubit that manages the state of this list.
/// [S] - The type of state that this BLoC or Cubit provides, extending [AbstractListState].
class AbstractListBuilder<B extends StateStreamableSource<S>,
    S extends AbstractListState> extends StatelessWidget {
  final _refreshController = RefreshController();

  /// The direction of the scrollable list, either vertical or horizontal.
  final Axis scrollDirection;

  /// Physics to apply to the scroll view.
  final ScrollPhysics? physics;

  /// Optional scroll controller to control the scroll view.
  final ScrollController? controller;

  /// Indicates if pull-to-refresh functionality is enabled.
  final bool enableRefresh;

  /// Indicates if load more functionality is enabled.
  final bool enableLoadMore;

  /// Whether to show a warning icon when displaying cached data.
  final bool showCachedDataWarningIcon;

  /// Number of columns for grid layouts.
  final int columns;

  /// Cache extent for the scrollable list.
  final double? cacheExtent;

  /// Spacing between items in the main axis (for grids).
  final double mainAxisSpacing;

  /// Spacing between items in the cross axis (for grids).
  final double crossAxisSpacing;

  /// The aspect ratio of the children in a grid layout.
  final double childAspectRatio;

  /// The main axis extent for grid items.
  final double? mainAxisExtent;

  /// Padding for the entire list.
  final EdgeInsetsGeometry? padding;

  /// Optional header widget.
  final Widget? header;

  /// Optional builder function for the header widget.
  final Widget Function(BuildContext context, S state)? headerBuilder;

  /// Behavior of the header scrolling (fixed or scrollable).
  final AbstractScrollBehaviour headerScrollBehaviour;

  /// Function to build each item in the list.
  final Widget Function(BuildContext context, S state, int index)? itemBuilder;

  /// Function to build the overall content of the list.
  final Widget Function(BuildContext context, S state)? builder;

  /// Listener for changes in the state.
  final void Function(BuildContext context, S state)? listener;

  /// Callback when data is successfully loaded from the network.
  final void Function(BuildContext context, S state)? onLoaded;

  /// Callback when cached data is successfully loaded.
  final void Function(BuildContext context, S state)? onLoadedCached;

  /// Callback when an error occurs during data loading.
  final void Function(BuildContext context, S state)? onError;

  /// Optional footer widget.
  final Widget? footer;

  /// Optional builder function for the footer widget.
  final Widget Function(BuildContext context, S state)? footerBuilder;

  /// Behavior of the footer scrolling (fixed or scrollable).
  final AbstractScrollBehaviour footerScrollBehaviour;

  /// Additional widget builder function for extra customization.
  final Widget Function(BuildContext context, S state, Widget child)?
      additionalBuilder;

  /// Builder function for error state.
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;

  /// Builder function for no data state.
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;

  /// Builder function for loading state.
  final Widget Function(BuildContext context, S state)? loaderBuilder;

  /// Callback for initial execution logic.
  final void Function(BuildContext context)? onInit;

  /// Indicates whether to skip the initial call to onInit function.
  final bool skipInitialOnInit;

  /// Callback for pull-to-refresh logic.
  final void Function(BuildContext context)? onRefresh;

  /// Callback for loading more data logic.
  final void Function(BuildContext context)? onLoadMore;

  /// Function to check if loading is occurring.
  final bool Function(BuildContext context, S state)? isLoading;

  /// Function to check if an error occurred.
  final bool Function(BuildContext context, S state)? isError;

  /// Function to get the item count for the list.
  final int Function(BuildContext context, S state)? itemCount;

  /// Function to build separator items between list items.
  final Widget Function(BuildContext context, S state, int index)?
      separatorBuilder;

  /// Function to dynamically set item height.
  final double Function(BuildContext context, S state)? heightBuilder;

  /// An optional instance of the BLoC or Cubit.
  final B? providerValue;

  /// A function to create a BLoC or Cubit instance.
  final B Function(BuildContext context)? provider;

  /// A list of providers to be created using MultiBlocProvider.
  final List<SingleChildWidget>? providers;

  /// Main constructor for [AbstractListBuilder].
  AbstractListBuilder({
    super.key,
    this.columns = 1,
    this.cacheExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.controller,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.showCachedDataWarningIcon = true,
    this.errorBuilder,
    this.noDataBuilder,
    this.loaderBuilder,
    this.header,
    this.headerBuilder,
    this.headerScrollBehaviour = AbstractScrollBehaviour.fixed,
    this.isLoading,
    this.isError,
    this.itemCount,
    this.separatorBuilder,
    this.heightBuilder,
    this.itemBuilder,
    this.builder,
    this.listener,
    this.onLoaded,
    this.onLoadedCached,
    this.onError,
    this.footer,
    this.footerBuilder,
    this.footerScrollBehaviour = AbstractScrollBehaviour.fixed,
    this.additionalBuilder,
    this.onInit,
    this.skipInitialOnInit = false,
    this.onRefresh,
    this.onLoadMore,
    this.providerValue,
    this.provider,
    this.providers,
  });

  // Internal methods for various state checks, item counts, refresh logic, etc.

  bool _isLoadingAny(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      state.resultStatus == ResultStatus.loading;

  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      (state.resultStatus == ResultStatus.loading ||
          state.resultStatus == ResultStatus.loadedCached);

  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ?? state.resultStatus == ResultStatus.error;

  int _itemCount(BuildContext context, S state) =>
      itemCount?.call(context, state) ?? state.result.items.count;

  bool _enableRefresh(BuildContext context, S state) => enableRefresh;

  bool _enableLoadMore(BuildContext context, S state) =>
      enableLoadMore &&
      _itemCount(context, state) > 0 &&
      state is AbstractListFilterablePaginatedState &&
      state.result.hasMoreItems;

  bool _useSmartRefresher() => enableRefresh || enableLoadMore;

  bool _hasData(BuildContext context, S state) =>
      _itemCount(context, state) > 0;

  bool _isEmpty(BuildContext context, S state) => !_hasData(context, state);

  bool _isCached(BuildContext context, S state) =>
      _isError(context, state) && _hasData(context, state);

  bool _showBigLoader(BuildContext context, S state) =>
      _isLoadingAny(context, state);

  bool _showEmptyContainer(BuildContext context, S state) =>
      _isEmpty(context, state) && !_isError(context, state);

  bool _showErrorContainer(BuildContext context, S state) =>
      _isEmpty(context, state) && _isError(context, state);

  B? _blocOrCubitInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      debugPrint('There is no instance of bloc or cubit registered: $e');

      return null;
    }
  }

  void _execute(
    BuildContext context,
    void Function(BuildContext)? executable,
    void Function(AbstractListBloc instance)? executableBloc,
    void Function(AbstractListCubit instance)? executableCubit,
  ) {
    if (executable != null) {
      executable.call(context);
    } else {
      final instance = _blocOrCubitInstance(context);

      if (instance is AbstractListBloc) {
        executableBloc?.call(instance as AbstractListBloc);
      }

      if (instance is AbstractListCubit) {
        executableCubit?.call(instance as AbstractListCubit);
      }
    }
  }

  void _onInit(BuildContext context) => _execute(
        context,
        onInit,
        (instance) => instance.add(AbstractListLoadEvent()),
        (instance) => instance.load(),
      );

  void _onRefresh(BuildContext context) => _execute(
        context,
        onRefresh,
        (instance) => instance.add(AbstractListRefreshEvent()),
        (instance) => instance.refresh(),
      );

  void _onLoadMore(BuildContext context) => _execute(
        context,
        onLoadMore,
        (instance) => instance.add(AbstractListLoadMoreEvent()),
        (instance) => instance.loadMore(),
      );

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    final resultBuilder = AbstractStatefulBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      dispose: () {
        try {
          _refreshController.dispose();
        } catch (e) {
          debugPrint(
              'There is an error while trying to dispose of _refreshController: $e');
        }
      },
      builder: (context) {
        return BlocConsumer<B, S>(
          listener: (context, state) {
            if (!_showBigLoader(context, state)) {
              _refreshController.complete();
            }

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
            final calculatedHeader =
                header ?? headerBuilder?.call(context, state);
            final calculatedFooter =
                footer ?? footerBuilder?.call(context, state);

            final child = () {
              // Function to build a ListView with optional header and footer
              buildMaybeWithHeaderAndFooter(Widget child) {
                return ListView(
                  cacheExtent: cacheExtent,
                  physics: physics,
                  controller: controller,
                  padding: padding ?? EdgeInsets.zero,
                  children: [
                    if (headerScrollBehaviour ==
                            AbstractScrollBehaviour.scrollable &&
                        calculatedHeader != null)
                      calculatedHeader,
                    child,
                    if (footerScrollBehaviour ==
                            AbstractScrollBehaviour.scrollable &&
                        calculatedFooter != null)
                      calculatedFooter,
                  ],
                );
              }

              // Check if a custom builder is provided
              if (builder != null) {
                return buildMaybeWithHeaderAndFooter(builder!(context, state));
              }

              final calculatedShowBigLoader = _showBigLoader(context, state);
              final calculatedShowEmptyContainer =
                  _showEmptyContainer(context, state);
              final calculatedShowErrorContainer =
                  _showErrorContainer(context, state);
              final shouldBuildTransitionItem = calculatedShowBigLoader ||
                  calculatedShowEmptyContainer ||
                  calculatedShowErrorContainer;

              Widget transitionItemBuilder(BuildContext context) {
                // Check if we need to show a big loader
                if (calculatedShowBigLoader) {
                  return loaderBuilder?.call(context, state) ??
                      abstractConfiguration?.loaderBuilder?.call(context) ??
                      const Loader();
                }

                // Check if we need to show an empty state
                if (calculatedShowEmptyContainer) {
                  return noDataBuilder?.call(
                          context, () => _onInit(context), state) ??
                      abstractConfiguration?.abstractListNoDataBuilder
                          ?.call(context, () => _onInit(context)) ??
                      AbstractListNoDataContainer(
                          onInit: () => _onInit(context));
                }

                // Check if we need to show an error state
                if (calculatedShowErrorContainer) {
                  return errorBuilder?.call(
                          context, () => _onInit(context), state) ??
                      abstractConfiguration?.abstractListErrorBuilder
                          ?.call(context, () => _onInit(context)) ??
                      AbstractLisErrorContainer(onInit: () => _onInit(context));
                }

                return const SizedBox();
              }

              final shouldBuildHeader =
                  headerScrollBehaviour == AbstractScrollBehaviour.scrollable &&
                      calculatedHeader != null;
              final shouldBuildFooter =
                  footerScrollBehaviour == AbstractScrollBehaviour.scrollable &&
                      calculatedFooter != null;

              final resolvedItemCount = _itemCount(context, state);
              final calculatedItemCount =
                  (shouldBuildTransitionItem ? 1 : resolvedItemCount) +
                      (shouldBuildHeader ? 1 : 0) +
                      (shouldBuildFooter ? 1 : 0);
              final calculatedIndexOffset = shouldBuildHeader ? 1 : 0;

              if (shouldBuildTransitionItem &&
                  (headerScrollBehaviour == AbstractScrollBehaviour.fixed ||
                      !shouldBuildHeader)) {
                return transitionItemBuilder(context);
              }

              Widget? calculatedItemBuilder(BuildContext context, int index) {
                if (shouldBuildHeader && index == 0) {
                  return calculatedHeader;
                }

                if (shouldBuildFooter && index == (calculatedItemCount - 1)) {
                  return calculatedFooter;
                }

                if (shouldBuildTransitionItem) {
                  return transitionItemBuilder(context);
                }

                return itemBuilder?.call(
                    context, state, index - calculatedIndexOffset);
              }

              Widget calculatedSeparatorBuilder(
                  BuildContext context, int index) {
                if (shouldBuildHeader && index == 0) {
                  return const SizedBox();
                }

                if (shouldBuildFooter && index == (calculatedItemCount - 1)) {
                  return const SizedBox();
                }

                if (shouldBuildTransitionItem) {
                  return const SizedBox();
                }

                return separatorBuilder?.call(context, state, index) ??
                    const SizedBox();
              }

              // Determine the appropriate list view or grid view based on the columns property
              if (columns <= 1) {
                return ListView.separated(
                  cacheExtent: cacheExtent,
                  padding: padding ?? EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: scrollDirection,
                  physics: physics,
                  controller: controller,
                  itemCount: calculatedItemCount,
                  itemBuilder: calculatedItemBuilder,
                  separatorBuilder: calculatedSeparatorBuilder,
                );
              }

              return GridView.builder(
                cacheExtent: cacheExtent,
                padding: padding ?? EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: scrollDirection,
                physics: physics,
                controller: controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: shouldBuildTransitionItem ? 1 : columns,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio:
                      shouldBuildTransitionItem ? 0.5 : childAspectRatio,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemCount: calculatedItemCount,
                itemBuilder: calculatedItemBuilder,
              );
            }();

            // Stack to include the SmartRefresher if enabled
            final content = Stack(
              children: [
                () {
                  if (_useSmartRefresher()) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: PointerDeviceKind.values.toSet(),
                      ),
                      child: SmartRefresher(
                        cacheExtent: cacheExtent,
                        scrollDirection: scrollDirection,
                        controller: _refreshController,
                        enablePullDown: _enableRefresh(context, state),
                        enablePullUp: _enableLoadMore(context, state),
                        onRefresh: () => _onRefresh(context),
                        onLoading: () => _onLoadMore(context),
                        child: child,
                      ),
                    );
                  }

                  return child; // Return plain child if no SmartRefresher is used
                }(),
                if (showCachedDataWarningIcon)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: LoadInfoIcon(
                      isLoading: !_showBigLoader(context, state) &&
                          _isLoading(context, state) &&
                          _hasData(context, state),
                      isCached: _isCached(context, state),
                      onReload: (_) => _onInit(context),
                    ),
                  ),
              ],
            );

            // Wrap the final content with headers and footers based on configuration
            final result = SizedBox(
              height: heightBuilder?.call(context, state),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headerScrollBehaviour == AbstractScrollBehaviour.fixed &&
                      calculatedHeader != null)
                    calculatedHeader,
                  Expanded(
                    child: content,
                  ),
                  if (footerScrollBehaviour == AbstractScrollBehaviour.fixed &&
                      calculatedFooter != null)
                    calculatedFooter,
                ],
              ),
            );

            // Return additional customization if provided
            return additionalBuilder?.call(context, state, result) ?? result;
          },
        );
      },
    );

    // Determine how to provide the BLoC or Cubit to the widget tree
    if (providerValue != null) {
      return BlocProvider.value(
        value: providerValue!,
        child: resultBuilder,
      );
    }

    if (provider != null) {
      return BlocProvider<B>(
        create: provider!,
        child: resultBuilder,
      );
    }

    if (providers.isNotNullOrEmpty) {
      return MultiBlocProvider(
        providers: providers!,
        child: resultBuilder,
      );
    }

    return resultBuilder; // No providers used, return main child directly
  }
}
