import 'package:reddit/reddit.dart';

import '../models/comment.dart';

import 'snudown.dart';

Comment commentFromData(CommentData data) {
  return Comment(
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
    voteDir: data.voteDir);
}

