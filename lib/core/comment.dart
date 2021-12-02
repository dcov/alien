import 'package:muex/muex.dart';

import '../reddit/types.dart';

import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

part 'comment.g.dart';

abstract class Comment implements Model, Saveable, Votable {

  factory Comment({
    required CommentData data,
  }) {
    return _$Comment(
      authorFlairText: data.authorFlairText,
      authorName: data.authorName,
      body: snudownFromMarkdown(data.body),
      createdAtUtc: data.createdAtUtc,
      depth: data.depth,
      distinguishment: data.distinguishment,
      editedAtUtc: data.editedAtUtc,
      isSubmitter: data.isSubmitter,
      isSaved: data.isSaved,
      id: data.id,
      kind: data.kind,
      score: data.score,
      voteDir: data.voteDir,
    );
  }

  factory Comment.raw({
    String? authorFlairText,
    required String authorName,
    required Snudown body,
    required int createdAtUtc,
    int? depth,
    String? distinguishment,
    int? editedAtUtc,
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

  int? get editedAtUtc;

  bool get isSubmitter;
}
