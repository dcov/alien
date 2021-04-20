import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'context.dart';
import 'media.dart';
import 'snudown.dart';
import 'saveable.dart';
import 'votable.dart';

part 'post.g.dart';

abstract class Post implements Model, Saveable, Votable {

  factory Post({
    required int commentCount,
    required bool isNSFW,
    required String authorName,
    required int createdAtUtc,
    required String domainName,
    required bool hasBeenViewed,
    required bool isSelf,
    Media? media,
    required String permalink,
    Snudown? selfText,
    required String subredditName,
    required String title,
    String? url,
    required bool isSaved,
    required String id,
    required String kind,
    required int score,
    required VoteDir voteDir,
  }) = _$Post;

  String get authorName;

  int get commentCount;
  set commentCount(int value);

  int get createdAtUtc;

  String get domainName;

  bool get hasBeenViewed;
  set hasBeenViewed(bool value);

  bool get isNSFW;
  set isNSFW(bool value);

  bool get isSelf;

  Media? get media;

  String get permalink;

  Snudown? get selfText;

  String get subredditName;

  String get title;

  String? get url;
}

Post postFromData(PostData data, { bool hasBeenViewed = false }) {
  Media? media;
  if (!data.isSelf) {
    var thumbnail = data.thumbnailUrl ??
        (data.preview?.resolutions.length != 0 ?
            data.preview?.resolutions.first.url :
            null);

    if (thumbnail != null) {
      thumbnail = Uri.tryParse(thumbnail)?.hasScheme == true ? thumbnail : null;
    }

    media = Media(
      // If it's not a self post then it should have a url
      source: data.url!,
      thumbnail: thumbnail,
      thumbnailStatus: thumbnail != null ? ThumbnailStatus.loaded : ThumbnailStatus.notLoaded);
  }

  Snudown? selfText;
  if (data.selfText?.isNotEmpty == true) {
    selfText = snudownFromMarkdown(data.selfText!);
  }

  return Post(
    commentCount: data.commentCount,
    isNSFW: data.isNSFW,
    authorName: data.authorName,
    createdAtUtc: data.createdAtUtc,
    domainName: data.domainName,
    hasBeenViewed: hasBeenViewed,
    isSelf: data.isSelf,
    media: media,
    permalink: data.permalink,
    selfText: selfText,
    subredditName: data.subredditName,
    title: data.title,
    url: data.url,
    isSaved: data.isSaved,
    id: data.id,
    kind: data.kind,
    score: data.score,
    voteDir: data.voteDir);
}

String _postIdToViewedKey(String id) => 'viewed-$id';

extension PostEffectsExtensions on CoreContext {

  Future<bool> getPostHasBeenViewed(Post post) {
    return this.cache.containsKey(_postIdToViewedKey(post.id));
  }

  Future<Map<String, bool>> getPostListingDataHasBeenViewed(ListingData<PostData> listing) async {
    final result = Map<String, bool>();
    for (final postData in listing.things) {
      result[postData.id] = await this.cache.containsKey(_postIdToViewedKey(postData.id));
    }
    return result;
  }
}

class MarkPostAsViewed implements Update {

  MarkPostAsViewed({
    required this.post
  });

  final Post post;

  @override
  Then update(_) {
    if (post.hasBeenViewed)
      return Then.done();

    post.hasBeenViewed = true;
    return Then(_CachePostAsViewed(post: post));
  }
}

class _CachePostAsViewed implements Effect {

  _CachePostAsViewed({
    required this.post
  });

  final Post post;

  @override
  Future<Then> effect(CoreContext context) async {
    await context.cache.put(_postIdToViewedKey(post.id), '');
    return Then.done();
  }
}
