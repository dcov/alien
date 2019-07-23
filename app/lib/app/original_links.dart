import 'dart:async';

import 'package:reddit/reddit.dart';

import 'base.dart';
import 'links_pagination.dart';
import 'param.dart';

class OriginalLinksModelSideEffects with RedditMixin {

  const OriginalLinksModelSideEffects();

  TimedParamModel<OriginalSort> createOriginalSortModel(
    OriginalSort sort,
    Iterable<OriginalSort> values,
    VoidCallback onSortUpdated,
  ) {
    return TimedParamModel<OriginalSort>(
      sort,
      values,
      onSortUpdated
    );
  }

  Future<Listing<Link>> getOriginalLinks(OriginalSort sort, Page page) {
    return getInteractor().getOriginalLinks(
      page: page,
      sort: sort
    );
  }
}

class OriginalLinksModel extends LinksPaginationModel {

  OriginalLinksModel([ this._sideEffects = const OriginalLinksModelSideEffects() ]) {
    _sort = _sideEffects.createOriginalSortModel(
      OriginalSort.hot,
      OriginalSort.values,
      refresh
    );
  }

  @override
  TimedParamModel<OriginalSort> get sort => _sort;
  TimedParamModel<OriginalSort> _sort;

  final OriginalLinksModelSideEffects _sideEffects;

  @override
  Future<Listing<Link>> loadPage(Page page) {
    return _sideEffects.getOriginalLinks(OriginalSort.hot, page);
  }
}