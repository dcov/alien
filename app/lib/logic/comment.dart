import 'package:reddit/reddit.dart';

import '../models/comment.dart';

import 'snudown.dart';

extension CommentDataExtensions on CommentData {
  
  Comment toModel() {
    return Comment(
      authorFlairText: this.authorFlairText,
      authorName: this.authorName,
      body: snudownFrom(this.body),
      createdAtUtc: this.createdAtUtc,
      depth: this.depth,
      editedAtUtc: this.editedAtUtc,
      isSubmitter: this.isSubmitter,
      isSaved: this.isSaved,
      id: this.id,
      kind: this.kind,
      score: this.score,
      voteDir: this.voteDir);
  }
}

