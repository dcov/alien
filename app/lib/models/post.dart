import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'comments_tree.dart';
import 'media.dart';
import 'saveable.dart';
import 'snudown.dart';
import 'votable.dart';

export 'comments_tree.dart';
export 'media.dart';
export 'saveable.dart';
export 'snudown.dart';
export 'votable.dart';

part 'post.g.dart';

abstract class Post implements Saveable, Votable {
  
  factory Post.fromData(PostData data) {
    Media media;
    if (!data.isSelf) {
      String thumbnail = data.thumbnailUrl;
      if (thumbnail == null) {
        thumbnail = data
          .preview
          ?.resolutions
          ?.firstWhere((_) => true, orElse: () => null)
          ?.url;
      }
      media = Media(
        source: data.url,
        thumbnail: thumbnail
      );
    }

    Snudown snudown;
    if (data.selfText != null) {
      snudown = Snudown.fromRaw(data.selfText);
    }
    return _$Post(
      authorName: data.authorName,
      commentCount: data.commentCount,
      createdAtUtc: data.createdAtUtc,
      domainName: data.domainName,
      id: data.id,
      isNSFW: data.isNSFW,
      isSaved: data.isSaved,
      isSelf: data.isSelf,
      kind: data.kind,
      media: media,
      permalink: data.permalink,
      score: data.score,
      selfText: snudown,
      subredditName: data.subredditName,
      thumbnailUrl: data.thumbnailUrl,
      title: data.title,
      url: data.url,
      voteDir: data.voteDir
    );
  }

  String get authorName;

  int commentCount;

  int get createdAtUtc;

  String get domainName;

  bool isNSFW;

  bool get isSelf;

  Media get media;

  String get permalink;

  Snudown get selfText;

  String get subredditName;

  String get thumbnailUrl;

  String get title;

  String get url;

  CommentsTree comments;
}
