part of 'comment.dart';

class Comment extends Thing with Saveable, Votable {

  Comment({
    String id
  }) : super(id);

  @override
  String get kind => 't1';

  String get authorName => _authorName;
  String _authorName;
  set authorName(String value) {
    _authorName = set(_authorName, value);
  }
}
