import 'package:reddit/reddit.dart' show CommentData;

import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

export 'saveable.dart';
export 'snudown.dart';
export 'votable.dart';

part 'comment.g.dart';

abstract class Comment implements Saveable, Votable {

  factory Comment.fromData(CommentData data) {
    return _$Comment(
      authorFlairText: data.authorFlairText,
      authorName: data.authorName,
      body: Snudown.fromRaw(data.body),
      createdAtUtc: data.createdAtUtc,
      depth: data.depth,
      editedAtUtc: data.editedAtUtc,
      isSubmitter: data.isSubmitter,
      id: data.id,
      kind: data.kind,
      isSaved: data.isSaved,
      score: data.score,
      voteDir: data.voteDir
    );
  }

  String get authorFlairText;

  String get authorName;

  Snudown get body;

  int get createdAtUtc;

  int get depth;

  int get editedAtUtc;

  bool get isSubmitter;
}
