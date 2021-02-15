import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import 'media.dart';
import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

part 'post.g.dart';

abstract class Post implements Model, Saveable, Votable {

  factory Post({
    int commentCount,
    bool isNSFW,
    String authorName,
    int createdAtUtc,
    String domainName,
    bool hasBeenViewed,
    bool isSelf,
    Media media,
    String permalink,
    Snudown selfText,
    String subredditName,
    String title,
    String url,
    bool isSaved,
    String id,
    String kind,
    int score,
    VoteDir voteDir,
  }) = _$Post;

  String get authorName;

  int commentCount;

  int get createdAtUtc;

  String get domainName;

  bool hasBeenViewed;

  bool isNSFW;

  bool get isSelf;

  Media get media;

  String get permalink;

  Snudown get selfText;

  String get subredditName;

  String get title;

  String get url;
}

