import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'refreshable.dart';
import 'subreddit.dart';

class DefaultsModelSideEffects with RedditMixin {

  const DefaultsModelSideEffects();

  SubredditModel createSubredditModel(Subreddit subreddit) {
    return SubredditModel(subreddit);
  }

  Future<Iterable<Subreddit>> getDefaults() {
    return getInteractor().getSubreddits(
      where: Subreddits.defaults,
      page: Page(limit: kMaxItemLimit)
    ).then((Listing<Subreddit> listing) {
      return sortSubreddits(listing.things.toList());
    });
  }
}

class DefaultsModel extends RefreshableThingsModel {

  DefaultsModel([ this._sideEffects = const DefaultsModelSideEffects() ]);

  final DefaultsModelSideEffects _sideEffects;

  @override
  Future<Iterable<Subreddit>> loadItems() {
    return _sideEffects.getDefaults();
  }

  @override
  Model createItem(Subreddit item) {
    return _sideEffects.createSubredditModel(item);
  }
}

class DefaultsSliver extends View<DefaultsModel> {

  DefaultsSliver({ Key key, @required DefaultsModel model })
    : super(key: key, model: model);

  @override
  _DefaultsSliverState createState() => _DefaultsSliverState();
}

class _DefaultsSliverState extends ViewState<DefaultsModel, DefaultsSliver> {

  @override
  bool get rebuildOnChanges => true;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverHeadingChildBuilderDelegate(
        heading: ListItem(
          title: OverlineText('DEFAULTS'),
        ),
        builder: (BuildContext _, int index) {
          final SubredditModel childModel = model.children[index];
          return SubredditTile(model: childModel);
        },
        childCount: model.children.length
      ),
    );
  }
}