import 'package:elmer/elmer.dart';

import 'comments_tree.dart';
import 'media.dart';
import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

export 'comments_tree.dart';
export 'media.dart';
export 'saveable.dart';
export 'snudown.dart';
export 'votable.dart';

part 'post.mdl.dart';

@model
mixin $Post implements Saveable, Votable {

  String get authorName;

  int commentCount;

  int get createdAtUtc;

  String get domainName;

  bool isNSFW;

  bool get isSelf;

  $Media get media;

  String get permalink;

  $Snudown get selfText;

  String get subredditName;

  String get thumbnailUrl;

  String get title;

  String get url;

  $CommentsTree comments;
}
