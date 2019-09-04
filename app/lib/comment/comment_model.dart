part of 'comment.dart';

abstract class Comment extends Model implements Thing, Saveable, Votable {

  @override
  String get kind => 't1';

  String authorName;
}
