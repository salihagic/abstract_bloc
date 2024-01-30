import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

enum AbstractScrollBehaviour { fixed, scrollable }

class AbstractListBuilder<B extends BlocBase<S>, S extends AbstractListState>
    extends StatelessWidget {
  final _refreshController = RefreshController();
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool enableRefresh;
  final bool enableLoadMore;
  final int columns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final Widget? header;
  final Widget Function(BuildContext context, S state)? headerBuilder;
  final AbstractScrollBehaviour headerScrollBehaviour;
  final Widget Function(BuildContext context, S state, int index)? itemBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onLoaded;
  final void Function(BuildContext context, S state)? onLoadedCached;
  final void Function(BuildContext context, S state)? onError;
  final Widget? footer;
  final Widget Function(BuildContext context, S state)? footerBuilder;
  final AbstractScrollBehaviour footerScrollBehaviour;
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
    this.controller,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.errorBuilder,
    this.noDataBuilder,
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

  Widget _buildHeader(BuildContext context, S state) =>
      header ?? headerBuilder?.call(context, state) ?? const SizedBox();
  Widget _buildItem(BuildContext context, S state, int index) =>
      itemBuilder?.call(context, state, index) ?? const SizedBox();
  Widget _buildFooter(BuildContext context, S state) =>
      footer ?? footerBuilder?.call(context, state) ?? const SizedBox();
  bool _shouldAddHeaderToThisItem(int index) =>
      index == 0 && headerScrollBehaviour == AbstractScrollBehaviour.scrollable;
  bool _shouldAddFooterToThisItem(BuildContext context, S state, int index) =>
      _isLastItem(context, state, index) &&
      footerScrollBehaviour == AbstractScrollBehaviour.scrollable;
  bool _isLastItem(BuildContext context, S state, int index) =>
      index == _itemCount(context, state) - 1;

  Widget _buildListItem(BuildContext context, S state, int index) {
    final children = [
      if (_shouldAddHeaderToThisItem(index)) _buildHeader(context, state),
      _buildItem(context, state, index),
      if (!_isLastItem(context, state, index))
        separatorBuilder?.call(context, state, index) ?? const SizedBox(),
      if (_shouldAddFooterToThisItem(context, state, index))
        _buildFooter(context, state),
    ];

    if (scrollDirection == Axis.vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    }

    if (scrollDirection == Axis.horizontal) {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }

    return const SizedBox();
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
            final child = () {
              final buildMaybeWithHeaderAndFooter = (Widget child) {
                return ListView(
                  physics: physics,
                  controller: controller,
                  padding: EdgeInsets.zero,
                  children: [
                    if (headerScrollBehaviour ==
                        AbstractScrollBehaviour.scrollable)
                      _buildHeader(context, state),
                    child,
                    if (footerScrollBehaviour ==
                        AbstractScrollBehaviour.scrollable)
                      _buildFooter(context, state),
                  ],
                );
              };

              if (_showBigLoader(context, state)) {
                return buildMaybeWithHeaderAndFooter(
                    abstractConfiguration?.loaderBuilder?.call(context) ??
                        const Loader());
              }

              //There is no network data and nothing is fetched from the cache and network error occured
              if (_showEmptyContainer(context, state)) {
                return buildMaybeWithHeaderAndFooter(noDataBuilder?.call(
                        context, () => _onInit(context), state) ??
                    abstractConfiguration?.abstractListNoDataBuilder
                        ?.call(context, () => _onInit(context)) ??
                    AbstractListNoDataContainer(
                        onInit: () => _onInit(context)));
              }

              if (_showErrorContainer(context, state)) {
                return buildMaybeWithHeaderAndFooter(errorBuilder?.call(
                        context, () => _onInit(context), state) ??
                    abstractConfiguration?.abstractListErrorBuilder
                        ?.call(context, () => _onInit(context)) ??
                    AbstractLisErrorContainer(onInit: () => _onInit(context)));
              }

              if (builder != null) {
                return buildMaybeWithHeaderAndFooter(builder!(context, state));
              }

              if (columns <= 1) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: scrollDirection,
                  physics: physics,
                  controller: controller,
                  itemCount: _itemCount(context, state),
                  itemBuilder: (context, index) {
                    return _buildListItem(context, state, index);
                  },
                );
              }

              return GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: scrollDirection,
                physics: physics,
                controller: controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: childAspectRatio,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemCount: _itemCount(context, state),
                itemBuilder: (context, index) {
                  return _buildListItem(context, state, index);
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (headerScrollBehaviour == AbstractScrollBehaviour.fixed)
                      _buildHeader(context, state),
                    Expanded(
                      child: content,
                    ),
                    if (footerScrollBehaviour == AbstractScrollBehaviour.fixed)
                      _buildFooter(context, state),
                  ],
                );
              }(),
            );

            return additionalBuilder?.call(context, state, result) ?? result;
          },
        );
      },
    );
  }
}
