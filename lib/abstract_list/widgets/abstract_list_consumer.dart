import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Wrapper around flutter_bloc's [BlocConsumer] that abstracts the use of general list of network items.
/// Offers Load, Refresh and Load more features.
/// Best used with [AbstractListBloc] and [AbstractListState] as template paramters but not mandatory.
/// If used with AbstractListState(meaning that your bloc's state extends [AbstractListState])
/// callbacks for [isLoading], [isError] and [itemCount] could be ignored and the values would be automatically resolved.
class AbstractListConsumer<B extends BlocBase<S>, S> extends StatelessWidget {
  /// Private refresh controller used for managing loader of header and footer in loading state
  final _refreshController = RefreshController();

  /// Specify the direction of the list
  final Axis scrollDirection;

  /// Set scroll physics for the listview
  final ScrollPhysics? physics;

  /// Specify weather the list should allow "refresh" feature
  final bool enableRefresh;

  /// Specify weather the list should allow "load more" feature
  final bool enableLoadMore;

  /// Specify text and image placeholder when an error happens
  final AbstractListEmptyErrorContainerOptions? errorOptions;

  /// Specify text and image placeholder when there are no items in the list
  final AbstractListEmptyContainerOptions? emptyOptions;

  /// When there is no data use this builder to provide placeholder widget
  final Widget Function(S state)? emptyContainerBuilder;

  /// Optional header above the list, could be filters or some custom list title
  final Widget? header;

  /// Optional header above the list, could be filters or some custom list title
  final Widget Function(S)? headerBuilder;

  /// Specifies single list item
  final Widget Function(S, int)? itemBuilder;

  /// Specifies builder for the whole list
  final Widget Function(BuildContext, S)? builder;

  /// Used to specify how to dispatch an event that initializes the first batch of data in your list.
  /// Usually this would be <bloc>LoadEvent
  final void Function(BuildContext context)? onInit;

  /// Set this flag to true if you want to initialize the data somewhere above in the context
  final bool skipInitialOnInit;

  /// Used to specify how to dispatch an event on your bloc when the user refreshes the list by pulling down
  final void Function(BuildContext)? onRefresh;

  /// Used to specify how to dispatch an event on your bloc when the user reaches the end of the list
  final void Function(BuildContext)? onLoadMore;

  /// Provide a callback specifying weather the data is currently loading
  /// If your bloc's state extends [AbstractListState] you can ignore this callback
  final bool Function(S state)? isLoading;

  /// Provide a callback specifying weather an error has occured while loading
  /// If your bloc's state extends [AbstractListState] you can ignore this callback
  final bool Function(S state)? isError;

  /// Provide a callback specifying the number of items currently present in the state
  /// If your bloc's state extends [AbstractListState] you can ignore this callback
  final int Function(S state)? itemCount;

  final Widget Function(S state, int index)? separatorBuilder;

  final double Function(S state)? heightBuilder;

  AbstractListConsumer({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.errorOptions,
    this.emptyOptions,
    this.emptyContainerBuilder,
    this.header,
    this.headerBuilder,
    this.isLoading,
    this.isError,
    this.itemCount,
    this.separatorBuilder,
    this.heightBuilder,
    this.itemBuilder,
    this.builder,
    this.onInit,
    this.skipInitialOnInit = false,
    this.onRefresh,
    this.onLoadMore,
  }) : super(key: key);

  bool _isLoadingAny(S state) =>
      isLoading?.call(state) ??
      (state is AbstractListState &&
          state.resultStatus == ResultStatus.loading);
  bool _isLoading(S state) =>
      isLoading?.call(state) ??
      (state is AbstractListState &&
          (state.resultStatus == ResultStatus.loading ||
              state.resultStatus == ResultStatus.loadedCached));
  bool _isError(S state) =>
      isError?.call(state) ??
      (state is AbstractListState && state.resultStatus == ResultStatus.error);
  int _itemCount(S state) =>
      itemCount?.call(state) ??
      (state is AbstractListState ? state.items.count : 0);

  bool _enableRefresh(S state) => enableRefresh && !_isError(state);
  bool _enableLoadMore(S state) =>
      enableLoadMore &&
      _itemCount(state) > 0 &&
      !_isError(state) &&
      (state is! AbstractListFilterablePaginatedState || state.hasMoreData);
  bool _useSmartRefresher() => enableRefresh || enableLoadMore;

  bool _hasData(S state) => _itemCount(state) > 0;
  bool _isEmpty(S state) => !_hasData(state);
  bool _isCached(S state) => _isError(state) && _hasData(state);

  bool _showBigLoader(S state) => _isLoadingAny(state);
  bool _showEmptyContainer(S state) => _isEmpty(state) && !_isError(state);
  bool _showErrorContainer(S state) => _isEmpty(state) && _isError(state);

  @override
  Widget build(BuildContext context) {
    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          onInit?.call(context);
        }
      },
      builder: (context) {
        return BlocConsumer<B, S>(
          listener: (context, state) {
            if (!_showBigLoader(state)) {
              _refreshController.complete();
            }
          },
          builder: (context, state) {
            final child = () {
              if (_showBigLoader(state)) {
                return const Loader();
              }

              //There is no network data and nothing is fetched from the cache and network error occured
              if (_showEmptyContainer(state)) {
                return emptyContainerBuilder?.call(state) ??
                    AbstractListEmptyContainer(options: emptyOptions);
              }

              if (_showErrorContainer(state)) {
                return AbstractListEmptyErrorContainer(
                    options: errorOptions, onInit: onInit);
              }

              if (builder != null) {
                return builder!(context, state);
              }

              //Here is memory, cached or network data
              return ListView.separated(
                shrinkWrap: true,
                scrollDirection: scrollDirection,
                physics: physics,
                itemCount: _itemCount(state),
                itemBuilder: (context, index) => itemBuilder != null
                    ? itemBuilder!(state, index)
                    : Container(),
                separatorBuilder: (context, index) =>
                    separatorBuilder?.call(state, index) ?? Container(),
              );
            }();

            final content = Stack(
              children: [
                () {
                  if (_useSmartRefresher()) {
                    return SmartRefresher(
                      scrollDirection: scrollDirection,
                      controller: _refreshController,
                      enablePullDown: _enableRefresh(state),
                      enablePullUp: _enableLoadMore(state),
                      onLoading: () => onLoadMore?.call(context),
                      onRefresh: () => onRefresh?.call(context),
                      child: child,
                    );
                  }

                  return child;
                }(),
                Column(
                  children: [
                    LoadInfoIcon(
                      isLoading: !_showBigLoader(state) &&
                          _isLoading(state) &&
                          _hasData(state),
                      isCached: _isCached(state),
                      onReload: onInit,
                    ),
                  ],
                ),
              ],
            );

            return Container(
              height: heightBuilder?.call(state),
              child: () {
                if (header != null || headerBuilder != null) {
                  return Column(
                    children: [
                      header ?? headerBuilder?.call(state) ?? Container(),
                      Expanded(
                        child: content,
                      )
                    ],
                  );
                }

                return content;
              }(),
            );
          },
        );
      },
    );
  }
}
