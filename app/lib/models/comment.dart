import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

part 'comment.g.dart';

abstract class Comment implements Model, Saveable, Votable {

  factory Comment({
    String authorFlairText,
    required String authorName,
    required Snudown body,
    required int createdAtUtc,
    int? depth,
    String? distinguishment,
    required int editedAtUtc,
    required bool isSubmitter,
    required bool isSaved,
    required String id,
    required String kind,
    required int score,
    required VoteDir voteDir,
  }) = _$Comment;

  String? get authorFlairText;

  String get authorName;

  Snudown get body;

  int get createdAtUtc;

  int? get depth;

  String? get distinguishment;
  set distinguishment(String? value);

  int get editedAtUtc;

  bool get isSubmitter;
}
