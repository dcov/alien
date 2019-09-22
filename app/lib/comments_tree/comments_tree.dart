import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../comment/comment.dart';
import '../more/more.dart';
import '../thing/thing.dart';
import '../utils/utils.dart';

part 'comments_tree_effects.dart';
part 'comments_tree_events.dart';
part 'comments_tree_model.dart';
part 'comments_tree_widgets.dart';
part 'comments_tree.g.dart';

Thing _mapThing(ThingData data) {
  if (data is CommentData)
    return Comment.fromData(data);
  else if (data is MoreData)
    return More.fromData(data);
  
  return null;
}

Iterable<ThingData> _expandTree(Iterable<ThingData> data) sync* {
  for (final ThingData td in data) {
    yield td;
    if (td is CommentData)
      yield* _expandTree(td.replies);
  }
}
