part of 'comment.dart';

abstract class Comment extends Model implements Thing, Saveable, Votable {

  factory Comment.fromData(CommentData data) {
    return _$Comment(
      authorName: data.authorName,
      id: data.id,
      kind: data.kind,
      isSaved: data.isSaved,
      score: data.score,
      voteDir: data.voteDir
    );
  }

  String get authorName;
}
