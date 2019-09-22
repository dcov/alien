part of 'comment.dart';

abstract class Comment extends Model implements Thing, Saveable, Votable {

  factory Comment.fromData(CommentData data) {
    return _$Comment(
      authorFlairText: data.authorFlairText,
      authorName: data.authorName,
      body: Snudown(data.body),
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
