import 'dart:async';

import 'package:reddit/reddit.dart';

import 'base.dart';
import 'links_pagination.dart';
import 'param.dart';

class HomeLinksModelSideEffects with RedditMixin {

  const HomeLinksModelSideEffects();

  TimedParamModel<HomeSort> createHomeSortModel(
    HomeSort sort,
    Iterable<HomeSort> values,
    VoidCallback onSortUpdated
  ) {
    return TimedParamModel(
      sort,
      values,
      onSortUpdated
    );
  }

  Future<Listing<Link>> getHomeLinks(HomeSort sort, Page page) {
    return getInteractor().getHomeLinks(
      sort: sort,
      page: page
    );
  }
}

class HomeLinksModel extends LinksPaginationModel {

  HomeLinksModel([ this._sideEffects = const HomeLinksModelSideEffects() ]) {
    _sort = _sideEffects.createHomeSortModel(
      HomeSort.best,
      HomeSort.values,
      refresh
    );
  }

  @override
  TimedParamModel<HomeSort> get sort => _sort;
  TimedParamModel<HomeSort> _sort;

  final HomeLinksModelSideEffects _sideEffects;

  Future<Listing<Link>> loadPage(Page page) {
    return _sideEffects.getHomeLinks(HomeSort.hot, page);
  }
}