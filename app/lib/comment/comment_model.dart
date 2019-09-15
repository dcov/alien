part of 'comment.dart';

abstract class Comment extends Model implements Thing, Saveable, Votable {

  factory Comment({
    String authorName,
  }) => _$Comment(
    kind: 't1'
  );

  String get authorName;
}
