import 'package:reddit/values.dart';

import 'pagination_behavior.dart';

/// A pagination model where only the current page's items are shown.
class PagerPaginationBehaviorModel extends PaginationBehaviorModel {

  PagerPaginationBehaviorModel(PaginationBehaviorModelSideEffects sideEffects)
    : super(sideEffects);

  int get pageCount => _pageCount;
  int _pageCount = 1;

  bool get previousPageExists => pagination.previousPageExists;

  bool get nextPageExists => pagination.nextPageExists;

  int _pageCountIfSucceeds;

  @override
  void finishRefresh(Iterable<Thing> items) {
    if (items == null)
      return;
    _pageCount = _pageCountIfSucceeds;
    super.finishRefresh(items);
  }

  @override
  void refresh() {
    if (isRefreshing)
      return;
    _pageCountIfSucceeds = 1;
    super.refresh();
  }

  void loadNext() {
    assert(nextPageExists);
    if (isRefreshing || !nextPageExists)
      return;
    _pageCountIfSucceeds = _pageCount + 1;
    setRefreshing();
    loadNextItems()
      ?.then(
        finishRefresh,
        onError: (error) {
        }
      );
  }

  void loadPrevious() {
    assert(previousPageExists);
    if (isRefreshing || !previousPageExists)
      return;
    _pageCountIfSucceeds = _pageCount - 1;
    setRefreshing();
    loadPreviousItems()
      ?.then(
        finishRefresh,
        onError: (error) {
        }
      );
  }
}