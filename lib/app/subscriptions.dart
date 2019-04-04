import 'dart:async';

import 'package:reddit/endpoints.dart';
import 'package:reddit/helpers.dart';
import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'refreshable.dart';
import 'subreddit.dart';

class SubscriptionsModelSideEffects with RedditMixin {

  const SubscriptionsModelSideEffects();

  SubredditModel createSubredditModel(Subreddit thing) => SubredditModel(thing);

  Future<Iterable<Subreddit>> getSubscriptions() {
    return _getSubscriptions(List<Subreddit>(), Pagination(limit: kMaxItemLimit));
  }

  Future<Iterable<Subreddit>> _getSubscriptions(List<Subreddit> list, Pagination pagination) {
    return getInteractor().getMySubreddits(
      where: MySubreddits.subscriber,
      page: pagination.nextPage,
      includeCategories: true,
    ).then((listing) {
      list.addAll(listing.things);
      pagination = pagination.forward(listing);
      return pagination.nextPageExists ? _getSubscriptions(list, pagination) : list;
    });
  }
}

class SubscriptionsModel extends RefreshableThingsModel {

  SubscriptionsModel([ this._sideEffects = const SubscriptionsModelSideEffects() ]);

  final SubscriptionsModelSideEffects _sideEffects;

  @override
  Future<Iterable<Subreddit>> loadItems() {
    return _sideEffects.getSubscriptions().then((Iterable<Subreddit> subreddits) {
      return sortSubreddits(subreddits.toList());
    });
  }

  @override
  SubredditModel createItem(Subreddit thing) {
    return _sideEffects.createSubredditModel(thing);
  }
}

class SubscriptionsSliver extends View<SubscriptionsModel> {

  SubscriptionsSliver({ Key key, @required SubscriptionsModel model })
    : super(key: key, model: model);

  @override
  _SubscriptionsSliverState createState() => _SubscriptionsSliverState();
}

class _SubscriptionsSliverState extends ViewState<SubscriptionsModel, SubscriptionsSliver> {

  @override
  bool get rebuildOnChanges => true;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverHeadingChildBuilderDelegate(
        heading: ListItem(
          title: OverlineText('SUBSCRIPTIONS'),
        ),
        builder: (BuildContext _, int index) {
          final SubredditModel childModel = model.children[index];
          return SubredditTile(model: childModel);
        },
        childCount: model.children.length,
      ),
    );
  }
}