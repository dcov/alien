import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

part 'comment.g.dart';

abstract class Comment extends Model implements Saveable, Votable {

  factory Comment({
    String authorFlairText,
    String authorName,
    Snudown body,
    int createdAtUtc,
    int depth,
    int editedAtUtc,
    bool isSubmitter,
    bool isSaved,
    String id,
    String kind,
    int score,
    VoteDir voteDir,
  }) = _$Comment;

  String get authorFlairText;

  String get authorName;

  Snudown get body;

  int get createdAtUtc;

  int get depth;

  int get editedAtUtc;

  bool get isSubmitter;
}

