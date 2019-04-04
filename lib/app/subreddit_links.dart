import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/widgets.dart';

import 'base.dart';
import 'links_pagination.dart';
import 'param.dart';

class SubredditLinksModelSideEffects with RedditMixin {

  const SubredditLinksModelSideEffects();

  TimedParamModel<SubredditSort> createSubredditSortModel(
    SubredditSort param,
    VoidCallback onParamUpdated,
    TimeSort timeParam
  ) {
    return TimedParamModel(
      param,
      SubredditSort.values,
      onParamUpdated,
      timeParam
    );
  }

  Future<Listing<Link>> getSubredditLinks(
    String subredditName,
    SubredditSort sort,
    Page page
  ) {
    return getInteractor().getSubredditLinks(
      subredditName: subredditName,
      sort: sort,
      page: page
    );
  }
}

class SubredditLinksModel extends LinksPaginationModel {

  SubredditLinksModel(
    this._subredditName, [
    this._sideEffects = const SubredditLinksModelSideEffects()
  ]) {
    _sort = _sideEffects.createSubredditSortModel(
      SubredditSort.hot,
      refresh,
      null
    );
  }

  @override
  TimedParamModel<SubredditSort> get sort => _sort;
  TimedParamModel<SubredditSort> _sort;

  final String _subredditName;

  final SubredditLinksModelSideEffects _sideEffects;

  @override
  Future<Listing<Link>> loadPage(Page page) {
    return _sideEffects.getSubredditLinks(
      _subredditName,
      sort.param,
      page
    );
  }
}