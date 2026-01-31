import 'dart:async';
import 'dart:ui';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';

/// Enum to define the behavior of scrollable headers or footers.
enum AbstractScrollBehaviour { fixed, scrollable }

/// A generic widget for building lists that support state management,
/// pagination, and refresh functionalities.
///
/// [B] - The type of BLoC or Cubit that manages the state of this list.
/// [S] - The type of state that this BLoC or Cubit provides, extending [AbstractListState].
class AbstractListBuilder<
  B extends StateStreamableSource<S>,
  S extends AbstractListState
>
    extends StatelessWidget {
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

  /// Indicates if the transition item (between header and footer) should be wrapped in Expanded and SingleChildScrollView
  final bool transitionItemExpanded;

  /// Whether to show a warning icon when displaying cached data.
  final bool showCachedDataWarningIcon;

  final bool reverse;

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
  const AbstractListBuilder({
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
    this.transitionItemExpanded = true,
    this.showCachedDataWarningIcon = true,
    this.reverse = false,
    this.errorBuilder,
    this.noDataBuilder,
    this.loaderBuilder,
    this.header,
    this.headerBuilder,
    this.headerScrollBehaviour = AbstractScrollBehaviour.scrollable,
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
    this.footerScrollBehaviour = AbstractScrollBehaviour.scrollable,
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
      itemCount?.call(context, state) ??
      state.result.items.abstractBlocListCount;

  bool _enableRefresh(BuildContext context, S state) => enableRefresh;

  bool _enableLoadMore(BuildContext context, S state) =>
      enableLoadMore &&
      _itemCount(context, state) > 0 &&
      state is AbstractListFilterablePaginatedState &&
      state.result.hasMoreItems;

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

    final resultBuilder = _AbstractListBuilderContent<B, S>(
      widget: this,
      abstractConfiguration: abstractConfiguration,
    );

    // Determine how to provide the BLoC or Cubit to the widget tree
    if (providerValue != null) {
      return BlocProvider.value(value: providerValue!, child: resultBuilder);
    }

    if (provider != null) {
      return BlocProvider<B>(create: provider!, child: resultBuilder);
    }

    if (providers.abstractBlocListIsNotNullOrEmpty) {
      return MultiBlocProvider(providers: providers!, child: resultBuilder);
    }

    return resultBuilder;
  }
}

/// Internal stateful widget to manage the refresh completer
class _AbstractListBuilderContent<
  B extends StateStreamableSource<S>,
  S extends AbstractListState
>
    extends StatefulWidget {
  final AbstractListBuilder<B, S> widget;
  final AbstractConfiguration? abstractConfiguration;

  const _AbstractListBuilderContent({
    required this.widget,
    required this.abstractConfiguration,
  });

  @override
  State<_AbstractListBuilderContent<B, S>> createState() =>
      _AbstractListBuilderContentState<B, S>();
}

class _AbstractListBuilderContentState<
  B extends StateStreamableSource<S>,
  S extends AbstractListState
>
    extends State<_AbstractListBuilderContent<B, S>> {
  Completer<void>? _refreshCompleter;
  Completer<void>? _loadMoreCompleter;

  AbstractListBuilder<B, S> get _widget => widget.widget;

  Future<void> _handleRefresh(BuildContext context) async {
    _refreshCompleter = Completer<void>();
    _widget._onRefresh(context);
    await _refreshCompleter!.future;
  }

  void _completeRefresh() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete();
    }
  }

  void _completeLoadMore() {
    if (_loadMoreCompleter != null && !_loadMoreCompleter!.isCompleted) {
      _loadMoreCompleter!.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbstractStatefulBuilder(
      initState: (context) {
        if (!_widget.skipInitialOnInit) {
          _widget._onInit(context);
        }
      },
      builder: (context) {
        return BlocConsumer<B, S>(
          listener: (context, state) {
            if (state.resultStatus != .loading) {
              _completeRefresh();
              _completeLoadMore();
            }

            _widget.listener?.call(context, state);

            if (state.resultStatus == .loaded) {
              _widget.onLoaded?.call(context, state);
            }

            if (state.resultStatus == .loadedCached) {
              _widget.onLoadedCached?.call(context, state);
            }

            if (state.resultStatus == .error) {
              _widget.onError?.call(context, state);
            }
          },
          builder: (context, state) {
            final calculatedHeader =
                _widget.header ?? _widget.headerBuilder?.call(context, state);
            final calculatedFooter =
                _widget.footer ?? _widget.footerBuilder?.call(context, state);

            final child = () {
              // Function to build a ListView with optional header and footer
              buildMaybeWithHeaderAndFooter(Widget child) {
                return ListView(
                  cacheExtent: _widget.cacheExtent,
                  physics: _widget.physics,
                  reverse: _widget.reverse,
                  controller: _widget.controller,
                  padding: _widget.padding ?? EdgeInsets.zero,
                  children: [
                    if (_widget.headerScrollBehaviour ==
                            AbstractScrollBehaviour.scrollable &&
                        calculatedHeader != null)
                      calculatedHeader,
                    child,
                    if (_widget.footerScrollBehaviour ==
                            AbstractScrollBehaviour.scrollable &&
                        calculatedFooter != null)
                      calculatedFooter,
                  ],
                );
              }

              // Check if a custom builder is provided
              if (_widget.builder != null) {
                return buildMaybeWithHeaderAndFooter(
                  _widget.builder!(context, state),
                );
              }

              final calculatedShowBigLoader = _widget._showBigLoader(
                context,
                state,
              );
              final calculatedShowEmptyContainer = _widget._showEmptyContainer(
                context,
                state,
              );
              final calculatedShowErrorContainer = _widget._showErrorContainer(
                context,
                state,
              );
              final shouldBuildTransitionItem =
                  calculatedShowBigLoader ||
                  calculatedShowEmptyContainer ||
                  calculatedShowErrorContainer;

              Widget transitionItemBuilder(BuildContext context) {
                // Check if we need to show a big loader
                if (calculatedShowBigLoader) {
                  return _widget.loaderBuilder?.call(context, state) ??
                      widget.abstractConfiguration?.loaderBuilder?.call(
                        context,
                      ) ??
                      const Loader();
                }

                // Check if we need to show an empty state
                if (calculatedShowEmptyContainer) {
                  return _widget.noDataBuilder?.call(
                        context,
                        () => _widget._onInit(context),
                        state,
                      ) ??
                      widget.abstractConfiguration?.abstractListNoDataBuilder
                          ?.call(context, () => _widget._onInit(context)) ??
                      AbstractListNoDataContainer(
                        onInit: () => _widget._onInit(context),
                      );
                }

                // Check if we need to show an error state
                if (calculatedShowErrorContainer) {
                  return _widget.errorBuilder?.call(
                        context,
                        () => _widget._onInit(context),
                        state,
                      ) ??
                      widget.abstractConfiguration?.abstractListErrorBuilder
                          ?.call(context, () => _widget._onInit(context)) ??
                      AbstractLisErrorContainer(
                        onInit: () => _widget._onInit(context),
                      );
                }

                return const SizedBox();
              }

              final shouldBuildHeader =
                  _widget.headerScrollBehaviour == .scrollable &&
                  calculatedHeader != null;
              final shouldBuildFooter =
                  _widget.footerScrollBehaviour == .scrollable &&
                  calculatedFooter != null;

              final resolvedItemCount = _widget._itemCount(context, state);
              final calculatedItemCount =
                  (shouldBuildTransitionItem ? 1 : resolvedItemCount) +
                  (shouldBuildHeader ? 1 : 0) +
                  (shouldBuildFooter ? 1 : 0);
              final calculatedIndexOffset = shouldBuildHeader ? 1 : 0;

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

                return _widget.itemBuilder?.call(
                  context,
                  state,
                  index - calculatedIndexOffset,
                );
              }

              Widget calculatedSeparatorBuilder(
                BuildContext context,
                int index,
              ) {
                if (shouldBuildHeader && index == 0) {
                  return const SizedBox();
                }

                if (shouldBuildFooter && index == (calculatedItemCount - 1)) {
                  return const SizedBox();
                }

                if (shouldBuildTransitionItem) {
                  return const SizedBox();
                }

                return _widget.separatorBuilder?.call(context, state, index) ??
                    const SizedBox();
              }

              // Determine the appropriate list view or grid view based on the columns property
              if (_widget.columns <= 1) {
                // Use LayoutBuilder with SingleChildScrollView for transition items (empty/error/loading states)
                // This ensures the content is centered vertically within available space
                if (shouldBuildTransitionItem) {
                  final resolvedPadding =
                      _widget.padding?.resolve(TextDirection.ltr) ??
                      EdgeInsets.zero;

                  return Column(
                    children: [
                      if (shouldBuildHeader)
                        Padding(
                          padding: EdgeInsets.only(
                            left: resolvedPadding.left,
                            right: resolvedPadding.right,
                            top: resolvedPadding.top,
                          ),
                          child: calculatedHeader,
                        ),

                      if (widget.widget.transitionItemExpanded)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics:
                                    _widget.physics ??
                                    const AlwaysScrollableScrollPhysics(),
                                controller: _widget.controller,
                                reverse: _widget.reverse,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: transitionItemBuilder(context),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        transitionItemBuilder(context),
                      if (shouldBuildFooter)
                        Padding(
                          padding: EdgeInsets.only(
                            left: resolvedPadding.left,
                            right: resolvedPadding.right,
                            bottom: resolvedPadding.bottom,
                          ),
                          child: calculatedFooter,
                        ),
                    ],
                  );
                }

                // Use AlwaysScrollableScrollPhysics when refresh is enabled to allow pull-to-refresh even with few items
                final scrollPhysics = _widget.enableRefresh
                    ? const AlwaysScrollableScrollPhysics()
                    : _widget.physics;

                return ListView.separated(
                  cacheExtent: _widget.cacheExtent,
                  padding: _widget.padding ?? EdgeInsets.zero,
                  shrinkWrap: false,
                  reverse: _widget.reverse,
                  scrollDirection: _widget.scrollDirection,
                  physics: scrollPhysics,
                  controller: _widget.controller,
                  itemCount: calculatedItemCount,
                  itemBuilder: calculatedItemBuilder,
                  separatorBuilder: calculatedSeparatorBuilder,
                );
              }

              // Use AlwaysScrollableScrollPhysics when refresh is enabled to allow pull-to-refresh even with few items
              final scrollPhysics = _widget.enableRefresh
                  ? const AlwaysScrollableScrollPhysics()
                  : _widget.physics;

              return GridView.builder(
                cacheExtent: _widget.cacheExtent,
                padding: _widget.padding ?? EdgeInsets.zero,
                shrinkWrap: false,
                reverse: _widget.reverse,
                scrollDirection: _widget.scrollDirection,
                physics: scrollPhysics,
                controller: _widget.controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: shouldBuildTransitionItem
                      ? 1
                      : _widget.columns,
                  mainAxisSpacing: _widget.mainAxisSpacing,
                  crossAxisSpacing: _widget.crossAxisSpacing,
                  childAspectRatio: shouldBuildTransitionItem
                      ? 0.5
                      : _widget.childAspectRatio,
                  mainAxisExtent: _widget.mainAxisExtent,
                ),
                itemCount: calculatedItemCount,
                itemBuilder: calculatedItemBuilder,
              );
            }();

            // Build the scrollable content with refresh and load more support
            final content = Stack(
              children: [
                () {
                  final canLoadMore = _widget._enableLoadMore(context, state);
                  final canRefresh = _widget._enableRefresh(context, state);

                  // Wrap with scroll configuration to support all pointer devices
                  Widget scrollableChild = ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
                    child: child,
                  );

                  // Add scroll-based load more detection
                  if (canLoadMore) {
                    scrollableChild = NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          final metrics = notification.metrics;
                          // Trigger load more when user scrolls within 200 pixels of the bottom
                          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                            if (!_widget._isLoadingAny(context, state) &&
                                (_loadMoreCompleter == null ||
                                    _loadMoreCompleter!.isCompleted)) {
                              _loadMoreCompleter = Completer<void>();
                              _widget._onLoadMore(context);
                            }
                          }
                        }
                        return false;
                      },
                      child: scrollableChild,
                    );
                  }

                  // Add pull-to-refresh using Flutter's RefreshIndicator
                  if (canRefresh) {
                    scrollableChild = RefreshIndicator(
                      onRefresh: () => _handleRefresh(context),
                      child: scrollableChild,
                    );
                  }

                  return scrollableChild;
                }(),
                if (_widget.showCachedDataWarningIcon)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: LoadInfoIcon(
                      isLoading:
                          !_widget._showBigLoader(context, state) &&
                          _widget._isLoading(context, state) &&
                          _widget._hasData(context, state),
                      isCached: _widget._isCached(context, state),
                      onReload: (_) => _widget._onInit(context),
                    ),
                  ),
              ],
            );

            // Wrap the final content with headers and footers based on configuration
            final result = SizedBox(
              height: _widget.heightBuilder?.call(context, state),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_widget.headerScrollBehaviour == .fixed &&
                      calculatedHeader != null)
                    calculatedHeader,
                  Expanded(child: content),
                  if (_widget.footerScrollBehaviour == .fixed &&
                      calculatedFooter != null)
                    calculatedFooter,
                ],
              ),
            );

            // Return additional customization if provided
            return _widget.additionalBuilder?.call(context, state, result) ??
                result;
          },
        );
      },
    );
  }
}
