import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'pagination_behavior.dart';
import 'refreshable.dart';
import 'thing.dart';

/// A pagination model where any subsequent items that are loaded are appended
/// to the end of any previous items instead of replacing them.
class EndlessPaginationBehaviorModel extends PaginationBehaviorModel {

  EndlessPaginationBehaviorModel(PaginationBehaviorModelSideEffects sideEffects) : super(sideEffects);

  /// Whether the next page is being loaded.
  bool get isLoadingMore => _isLoadingMore;
  bool _isLoadingMore = false;

  /// Whether another page can be loaded.
  bool get nextPageExists => pagination?.nextPageExists ?? false;

  /// The indices of the first item of every page.
  /// ```dart
  /// /// Returns the start index of the first page.
  /// final firstPageStart = pageStartIndices.elementAt(0);
  /// 
  /// final currentIndex = 14;
  /// /// Check whether the current index is the start of a page.
  /// final isPageStart = pageStartIndices.indexOf(currentIndex) != -1;
  /// 
  /// /// The returned index is the number of that page.
  /// final pageNumber = pageStartIndices.indexOf(currentIndex);
  /// ```
  Iterable<int> get pageStartIndices => _pageStartIndices;
  final List<int> _pageStartIndices = List<int>();

  @override
  Iterable<Model> mapItems(Iterable<Thing> items) {
    if (childList.isEmpty)
      return super.mapItems(items);

    /// Because we're endlessly adding items and Reddit might return items that
    /// are already in the list, we have to filter them out so that they don't
    /// get added twice.
    final filtered = List<Thing>();
    for (final thing in items) {
      final bool hasMatch = iterateUntil(childList.cast<ThingModelMixin>(), (ThingModelMixin model) => model.matchThing(thing));
      if (hasMatch)
        continue;
      
      filtered.add(thing);
    }
    return super.mapItems(filtered);
  }

  @override
  void finishRefresh(Iterable<Thing> items) {
    if (items == null)
      return;

    _pageStartIndices.add(0);
    super.finishRefresh(items);
  }

  void _resetState() {
    _pageStartIndices.clear();
    _isLoadingMore = false;
  }

  @override
  void setRefreshing() {
    _resetState();
    super.setRefreshing();
  }

  void loadMore() {
    if (!nextPageExists || isLoadingMore || isRefreshing)
      return;
    _isLoadingMore = true;
    notifyListeners();
    loadNextItems()?.then(
      _finishLoadMore,
      onError: (error) {
      }
    );
  }

  void _finishLoadMore(Iterable<Thing> items) {
    if (items == null)
      return;
    _isLoadingMore = false;
    _pageStartIndices.add(children.length);
    addItems(items);
    notifyListeners();
  }
}

const double _kScrollableExtentPadding = 144.0;

class EndlessPaginationBehaviorScrollView extends View<EndlessPaginationBehaviorModel> {

  EndlessPaginationBehaviorScrollView({ Key key, this.builder, EndlessPaginationBehaviorModel model })
    : super(key: key, model: model);

  final ModelWidgetBuilder<ThingModelMixin> builder;

  @override
  _EndlessPaginationBehaviorScrollViewState createState() => _EndlessPaginationBehaviorScrollViewState();
}

class _EndlessPaginationBehaviorScrollViewState extends RefreshableScrollViewState<EndlessPaginationBehaviorModel, EndlessPaginationBehaviorScrollView> {

  bool _trackOffset = false;

  void _checkPaginationStatus() {
    if (!model.isLoadingMore) {
      if (model.nextPageExists && !_trackOffset) {
        _trackOffset = true;
      }
    } else if (_trackOffset) {
      _trackOffset = false;
    }
  }

  @override
  void initModel() {
    super.initModel();
    model.addListener(_checkPaginationStatus);
    _checkPaginationStatus();
  }

  @override
  void onScrollUpdate() {
    super.onScrollUpdate();
    if (!_trackOffset)
      return;

    final ScrollMetrics metrics = controller.position;
    if (metrics.pixels > (metrics.maxScrollExtent - _kScrollableExtentPadding)) {
      model.loadMore();
    }
  }

  @override
  void disposeModel() {
    _trackOffset = false;
    model.removeListener(_checkPaginationStatus);
    super.disposeModel();
  }

  int _currentPage;

  @override
  SliverChildDelegate getChildDelegate(BuildContext context) {
    return SliverLatestChildBuilderDelegate(
      (BuildContext context, int index) => buildChild(context, model.children[index]),
      childCount: model.children.length,
      onLatestIndices: (int firstIndex, int lastIndex) {
        final int oldPage = _currentPage;
        if (model.isRefreshing) {
          /// we're refreshing so make sure that the current page is set to 0.
          if (_currentPage != 0)
            _currentPage = 0;
        } else if (_currentPage == null || _currentPage == 0) {
          /// we finished refreshing and are building the first page.
          _currentPage = 1;
        } else {
          final int middleIndex = (firstIndex + ((lastIndex - firstIndex) / 2)).floor();
          final int currentPageStart = model.pageStartIndices.elementAt(_currentPage - 1);
          if (currentPageStart > middleIndex) {
            _currentPage -= 1;
          } else if (model.pageStartIndices.length > _currentPage) {
            final int nextPageStart = model.pageStartIndices.elementAt(_currentPage);
            if (nextPageStart < middleIndex)
              _currentPage += 1;
          }
        }
        if (_currentPage != oldPage) {
          CurrentPageNotification(_currentPage).dispatch(context);
        }
      }
    );
  }

  @override
  Widget buildChild(BuildContext context, ThingModelMixin model) {
    return widget.builder(context, model);
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return ValueBuilder(
      valueGetter: () => model.isLoadingMore,
      listenable: model,
      builder: (BuildContext context, bool isLoadingMore, _) => SliverToBoxAdapter(
        child: isLoadingMore
          ? Padding(
              padding: Insets.fullAll,
              child: Center(child: const CircularProgressIndicator())
            )
          : const EmptyBox()
      ),
    );
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return super.buildSlivers(context)
      ..add(_buildLoadingMoreIndicator(context));
  }

  @override
  Widget build(BuildContext context) => buildScrollView(context);
}