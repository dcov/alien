import 'package:flutter/material.dart';

import 'feed.dart';
import 'home_links.dart';

class HomeModelSideEffects {

  const HomeModelSideEffects();

  HomeLinksModel createHomeLinks() => HomeLinksModel();
}

class HomeModel extends FeedModel {

  HomeModel([ HomeModelSideEffects sideEffects = const HomeModelSideEffects() ])
    : links = sideEffects.createHomeLinks();

  @override
  String get feedName => 'Home';

  @override
  IconData get iconData => Icons.home;

  @override
  final HomeLinksModel links;

  @override
  Color get primaryColor => Colors.orange;
}