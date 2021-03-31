import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import '../model/media.dart';
import '../model/saveable.dart';
import '../model/snudown.dart';
import '../model/votable.dart';

part 'post.g.dart';

abstract class Post implements Model, Saveable, Votable {

  factory Post({
    required int commentCount,
    required bool isNSFW,
    required String authorName,
    required int createdAtUtc,
    required String domainName,
    required bool hasBeenViewed,
    required bool isSelf,
    Media? media,
    required String permalink,
    Snudown? selfText,
    required String subredditName,
    required String title,
    String? url,
    required bool isSaved,
    required String id,
    required String kind,
    required int score,
    required VoteDir voteDir,
  }) = _$Post;

  String get authorName;

  int get commentCount;
  set commentCount(int value);

  int get createdAtUtc;

  String get domainName;

  bool get hasBeenViewed;
  set hasBeenViewed(bool value);

  bool get isNSFW;
  set isNSFW(bool value);

  bool get isSelf;

  Media? get media;

  String get permalink;

  Snudown? get selfText;

  String get subredditName;

  String get title;

  String? get url;
}

