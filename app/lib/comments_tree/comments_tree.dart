import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../comment/comment.dart';
import '../more/more.dart';
import '../thing/thing.dart';

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
