import 'package:flutter/material.dart';

import 'feed.dart';
import 'original_links.dart';

class OriginalModelSideEffects {

  const OriginalModelSideEffects();

  OriginalLinksModel createOriginalLinksModel() => OriginalLinksModel();
}

class OriginalModel extends FeedModel {

  OriginalModel([ OriginalModelSideEffects sideEffects = const OriginalModelSideEffects() ])
    : links = sideEffects.createOriginalLinksModel();

  @override
  String get feedName => 'Original';

  @override
  IconData get iconData => Icons.donut_small;

  @override
  final OriginalLinksModel links;

  @override
  Color get primaryColor => Colors.red;
}