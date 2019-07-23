import 'package:flutter/material.dart';

import 'base.dart';
import 'all.dart';
import 'feed.dart';
import 'home.dart';
import 'original.dart';
import 'popular.dart';

class FeedsModelSideEffects {

  const FeedsModelSideEffects();

  AllModel createAllModel() => AllModel();

  HomeModel createHomeModel() => HomeModel();

  OriginalModel createOriginalModel() => OriginalModel();

  PopularModel createPopularModel() => PopularModel();
}

class FeedsModel extends Model {
  
  FeedsModel(
    bool isSignedIn, [
    FeedsModelSideEffects sideEffects = const FeedsModelSideEffects()
  ]) : feeds = ImmutableList(_createFeedsList(isSignedIn, sideEffects));

  final ImmutableList<FeedModel> feeds;

  static List<FeedModel> _createFeedsList(bool isSignedIn, FeedsModelSideEffects sideEffects) {
    final List<FeedModel> list = <FeedModel>[
      sideEffects.createPopularModel(),
      sideEffects.createAllModel(),
      sideEffects.createOriginalModel()
    ];
    if (isSignedIn)
      list.insert(0, sideEffects.createHomeModel());
    return list;
  }
}

class FeedsSliver extends StatelessWidget {

  FeedsSliver({ Key key, @required this.model })
    : super(key: key);

  final FeedsModel model;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      ListItem(title: OverlineText('FEEDS'))
    ];
    for (final FeedModel feed in model.feeds) {
      children.add(FeedTile(model: feed));
    }
    return SliverList(delegate: SliverChildListDelegate(children));
  }
}