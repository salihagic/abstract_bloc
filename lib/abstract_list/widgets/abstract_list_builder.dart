import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

enum HeaderBehaviour {
  fixed,
  scrollable,
}

class AbstractListBuilder<B extends BlocBase<S>, S extends AbstractListState>
    extends StatelessWidget {
  final _refreshController = RefreshController();
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool enableRefresh;
  final bool enableLoadMore;
  final int columns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final Widget? header;
  final Widget Function(BuildContext context, S state)? headerBuilder;
  final HeaderBehaviour headerBehaviour;
  final Widget Function(BuildContext context, S state, int index)? itemBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final Widget Function(BuildContext context, S state, Widget child)?
      additionalBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final void Function(BuildContext context)? onRefresh;
  final void Function(BuildContext context)? onLoadMore;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? isError;
  final int Function(BuildContext context, S state)? itemCount;
  final Widget Function(BuildContext context, S state, int index)?
      separatorBuilder;
  final double Function(BuildContext context, S state)? heightBuilder;

  AbstractListBuilder({
    Key? key,
    this.columns = 1,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.errorBuilder,
    this.noDataBuilder,
    this.header,
    this.headerBuilder,
    this.headerBehaviour = HeaderBehaviour.fixed,
    this.isLoading,
    this.isError,
    this.itemCount,
    this.separatorBuilder,
    this.heightBuilder,
    this.itemBuilder,
    this.builder,
    this.additionalBuilder,
    this.onInit,
    this.skipInitialOnInit = false,
    this.onRefresh,
    this.onLoadMore,
  }) : super(key: key);

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
      (state is! AbstractListFilterablePaginatedState ||
          state.result.hasMoreItems);
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
  bool get _isHeaderScrollable => headerBehaviour == HeaderBehaviour.scrollable;

  AbstractListBloc? _blocInstance(BuildContext context) {
    try {
      return (context.read<B>() as AbstractListBloc);
    } catch (e) {
      print('There is no instance of bloc registered: $e');
      return null;
    }
  }

  void _onInit(BuildContext context) => onInit != null
      ? onInit?.call(context)
      : _blocInstance(context)?.add(AbstractListLoadEvent());

  Widget _buildHeader(BuildContext context, S state) {
    return header ?? headerBuilder?.call(context, state) ?? Container();
  }

  Widget _buildItem(
      BuildContext context, S state, int index, bool isHeaderScrollable) {
    return itemBuilder?.call(
            context, state, index - (isHeaderScrollable ? 1 : 0)) ??
        Container();
  }

  bool _isLastItem(
      BuildContext context, S state, int index, bool isHeaderScrollable) {
    return index ==
        (_itemCount(context, state) + (isHeaderScrollable ? 1 : 0) - 1);
  }

  Widget _buildListItem(
      BuildContext context, S state, int index, bool isHeaderScrollable) {
    final children = [
      _buildItem(context, state, index, isHeaderScrollable),
      if (!_isLastItem(context, state, index, isHeaderScrollable))
        separatorBuilder?.call(context, state, index) ?? Container(),
    ];

    if (scrollDirection == Axis.vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    }

    if (scrollDirection == Axis.horizontal) {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) {
        return BlocConsumer<B, S>(
          listener: (context, state) {
            if (!_showBigLoader(context, state)) {
              _refreshController.complete();
            }
          },
          builder: (context, state) {
            final child = () {
              final buildMaybeWithHeader = (Widget child) {
                if (_isHeaderScrollable) {
                  return ListView(
                    children: [
                      _buildHeader(context, state),
                      child,
                    ],
                  );
                }

                return child;
              };

              if (_showBigLoader(context, state)) {
                return buildMaybeWithHeader(
                    abstractConfiguration?.loaderBuilder?.call(context) ??
                        const Loader());
              }

              //There is no network data and nothing is fetched from the cache and network error occured
              if (_showEmptyContainer(context, state)) {
                return buildMaybeWithHeader(noDataBuilder?.call(
                        context, () => _onInit(context), state) ??
                    abstractConfiguration?.abstractListNoDataBuilder
                        ?.call(context, () => _onInit(context)) ??
                    AbstractListNoDataContainer(
                        onInit: () => _onInit(context)));
              }

              if (_showErrorContainer(context, state)) {
                return buildMaybeWithHeader(errorBuilder?.call(
                        context, () => _onInit(context), state) ??
                    abstractConfiguration?.abstractListErrorBuilder
                        ?.call(context, () => _onInit(context)) ??
                    AbstractLisErrorContainer(onInit: () => _onInit(context)));
              }

              if (builder != null) {
                return buildMaybeWithHeader(builder!(context, state));
              }

              if (columns <= 1) {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: scrollDirection,
                  physics: physics,
                  itemCount: _itemCount(context, state) +
                      (_isHeaderScrollable ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isHeaderScrollable && index == 0) {
                      return _buildHeader(context, state);
                    }

                    return _buildListItem(
                        context, state, index, _isHeaderScrollable);
                  },
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                scrollDirection: scrollDirection,
                physics: physics,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: childAspectRatio,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemCount:
                    _itemCount(context, state) + (_isHeaderScrollable ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isHeaderScrollable && index == 0) {
                    return _buildHeader(context, state);
                  }

                  return _buildListItem(
                      context, state, index, _isHeaderScrollable);
                },
              );
            }();

            final content = Stack(
              children: [
                () {
                  if (_useSmartRefresher()) {
                    return SmartRefresher(
                      scrollDirection: scrollDirection,
                      controller: _refreshController,
                      enablePullDown: _enableRefresh(context, state),
                      enablePullUp: _enableLoadMore(context, state),
                      onRefresh: () => onRefresh != null
                          ? onRefresh?.call(context)
                          : _blocInstance(context)
                              ?.add(AbstractListRefreshEvent()),
                      onLoading: () => onLoadMore != null
                          ? onLoadMore?.call(context)
                          : _blocInstance(context)
                              ?.add(AbstractListLoadMoreEvent()),
                      child: child,
                    );
                  }

                  return child;
                }(),
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

            final result = Container(
              height: heightBuilder?.call(context, state),
              child: () {
                if (headerBehaviour == HeaderBehaviour.fixed &&
                        header != null ||
                    headerBuilder != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header ??
                          headerBuilder?.call(context, state) ??
                          Container(),
                      Expanded(
                        child: content,
                      )
                    ],
                  );
                }

                return content;
              }(),
            );

            return additionalBuilder?.call(context, state, result) ?? result;
          },
        );
      },
    );
  }
}
