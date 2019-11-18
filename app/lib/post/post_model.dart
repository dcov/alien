part of 'post.dart';

abstract class Post implements Saveable, Votable, Target {
  
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
      snudown = Snudown(data.selfText);
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
