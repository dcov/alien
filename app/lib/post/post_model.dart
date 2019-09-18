part of 'post.dart';

abstract class Post extends Model
    implements Thing, Saveable, Votable, RoutingTarget {
  
  factory Post.fromData(PostData data) => _$Post(
    authorName: data.authorName,
    commentCount: data.commentCount,
    domainName: data.domainName,
    id: data.id,
    isNSFW: data.isNSFW,
    isSaved: data.isSaved,
    isSelf: data.isSelf,
    kind: data.kind,
    score: data.score,
    selfText: data.selfText,
    subredditName: data.subredditName,
    thumbnailUrl: data.thumbnailUrl,
    title: data.title,
    url: data.url,
    voteDir: data.voteDir
  );

  String get authorName;

  int commentCount;

  String get domainName;

  bool isNSFW;

  bool get isSelf;

  String selfText;

  String get subredditName;

  String get thumbnailUrl;

  String get title;

  String get url;
}
