import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart' show PostData;

import '../models/post.dart';

part 'post.msg.dart';

extension PostDataExtensions on PostData {

  Post toModel() {
    return Post(
      commentCount: this.commentCount,
      isNSFW: this.isNSFW,
      authorName: this.authorName,
      createdAtUtc: this.createdAtUtc,
      domainName: this.domainName,
      isSelf: this.isSelf,
      permalink: this.permalink,
      subredditName: this.subredditName,
      title: this.title,
      url: this.url,
      isSaved: this.isSaved,
      id: this.id,
      kind: this.kind,
      score: this.score,
      voteDir: this.voteDir);
  }
}

