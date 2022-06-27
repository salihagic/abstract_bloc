import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractGridBuilder<B extends BlocBase<S>, S extends AbstractListState> extends StatelessWidget {
  final _refreshController = RefreshController();
  final int crossAxisCount;

  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool enableRefresh;
  final bool enableLoadMore;
  final Widget? header;
  final Widget Function(BuildContext context, S state)? headerBuilder;
  final Widget Function(BuildContext context, S state, int index)? itemBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final Widget Function(BuildContext context, S state, Widget child)? additionalBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)? errorBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)? noDataBuilder;
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final void Function(BuildContext context)? onRefresh;
  final void Function(BuildContext context)? onLoadMore;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? isError;
  final int Function(BuildContext context, S state)? itemCount;
  final double Function(BuildContext context, S state)? heightBuilder;

  AbstractGridBuilder({
    Key? key,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
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
    this.isLoading,
    this.isError,
    this.itemCount,
    this.heightBuilder,
    this.itemBuilder,
    this.builder,
    this.additionalBuilder,
    this.onInit,
    this.skipInitialOnInit = false,
    this.onRefresh,
    this.onLoadMore,
  }) : super(key: key);

  bool _isLoadingAny(BuildContext context, S state) => isLoading?.call(context, state) ?? state.resultStatus == ResultStatus.loading;
  bool _isLoading(BuildContext context, S state) => isLoading?.call(context, state) ?? (state.resultStatus == ResultStatus.loading || state.resultStatus == ResultStatus.loadedCached);
  bool _isError(BuildContext context, S state) => isError?.call(context, state) ?? state.resultStatus == ResultStatus.error;
  int _itemCount(BuildContext context, S state) => itemCount?.call(context, state) ?? state.items.count;
  bool _enableRefresh(BuildContext context, S state) => enableRefresh;
  bool _enableLoadMore(BuildContext context, S state) => enableLoadMore && _itemCount(context, state) > 0 && !_isError(context, state) && (state is! AbstractListFilterablePaginatedState || state.hasMoreData);
  bool _useSmartRefresher() => enableRefresh || enableLoadMore;
  bool _hasData(BuildContext context, S state) => _itemCount(context, state) > 0;
  bool _isEmpty(BuildContext context, S state) => !_hasData(context, state);
  bool _isCached(BuildContext context, S state) => _isError(context, state) && _hasData(context, state);
  bool _showBigLoader(BuildContext context, S state) => _isLoadingAny(context, state);
  bool _showEmptyContainer(BuildContext context, S state) => _isEmpty(context, state) && !_isError(context, state);
  bool _showErrorContainer(BuildContext context, S state) => _isEmpty(context, state) && _isError(context, state);

  AbstractListBloc? _blocInstance(BuildContext context) {
    try {
      return (context.read<B>() as AbstractListBloc);
    } catch (e) {
      print('There is no instance of bloc registered: $e');
      return null;
    }
  }

  void _onInit(BuildContext context) => onInit != null ? onInit?.call(context) : _blocInstance(context)?.add(AbstractListLoadEvent());

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
              if (_showBigLoader(context, state)) {
                return abstractConfiguration?.loaderBuilder?.call(context) ?? const Loader();
              }

              //There is no network data and nothing is fetched from the cache and network error occured
              if (_showEmptyContainer(context, state)) {
                return noDataBuilder?.call(context, () => _onInit(context), state) ?? abstractConfiguration?.abstractGridNoDataBuilder?.call(context, () => _onInit(context)) ?? AbstractGridNoDataContainer(onInit: () => _onInit(context));
              }

              if (_showErrorContainer(context, state)) {
                return errorBuilder?.call(context, () => _onInit(context), state) ?? abstractConfiguration?.abstractGridErrorBuilder?.call(context, () => _onInit(context)) ?? AbstractGridErrorContainer(onInit: () => _onInit(context));
              }

              if (builder != null) {
                return builder!(context, state);
              }

              //Here is memory, cached or network data
              return GridView.builder(
                shrinkWrap: true,
                scrollDirection: scrollDirection,
                physics: physics,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: childAspectRatio,
                  mainAxisExtent: mainAxisExtent,
                ),
                itemCount: _itemCount(context, state),
                itemBuilder: (context, index) => itemBuilder != null ? itemBuilder!(context, state, index) : Container(),
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
                      onRefresh: () => onRefresh != null ? onRefresh?.call(context) : _blocInstance(context)?.add(AbstractListRefreshEvent()),
                      onLoading: () => onLoadMore != null ? onLoadMore?.call(context) : _blocInstance(context)?.add(AbstractListLoadMoreEvent()),
                      child: child,
                    );
                  }

                  return child;
                }(),
                Positioned(
                  top: 0,
                  right: 0,
                  child: LoadInfoIcon(
                    isLoading: !_showBigLoader(context, state) && _isLoading(context, state) && _hasData(context, state),
                    isCached: _isCached(context, state),
                    onReload: (_) => _onInit(context),
                  ),
                ),
              ],
            );

            final result = Container(
              height: heightBuilder?.call(context, state),
              child: () {
                if (header != null || headerBuilder != null) {
                  return Column(
                    children: [
                      header ?? headerBuilder?.call(context, state) ?? Container(),
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
