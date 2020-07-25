import 'package:reddit/reddit.dart' show CommentData;

import 'saveable_model.dart';
import 'snudown_model.dart';
import 'votable_model.dart';

export 'saveable_model.dart';
export 'snudown_model.dart';
export 'votable_model.dart';

part 'comment_model.g.dart';

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
