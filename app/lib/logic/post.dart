import 'package:mal/mal.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/media.dart';
import '../models/post.dart';
import '../models/snudown.dart';

import 'snudown.dart';

Post postFromData(PostData data, { bool hasBeenViewed = false }) {
  assert(data != null);
  assert(hasBeenViewed != null);

  Media media;
  if (!data.isSelf) {
    var thumbnail = data.thumbnailUrl ?? data.preview?.resolutions?.firstWhere((_) => true, orElse: () => null)?.url;
    if (thumbnail != null) {
      thumbnail = Uri.tryParse(thumbnail)?.hasScheme == true ? thumbnail : null;
    }

    media = Media(
      source: data.url,
      thumbnail: thumbnail,
      thumbnailStatus: thumbnail != null ? ThumbnailStatus.loaded : ThumbnailStatus.notLoaded);
  }

  Snudown selfText;
  if (data.selfText?.isNotEmpty == true) {
    selfText = snudownFromMarkdown(data.selfText);
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

extension PostEffectsExtensions on EffectContext {

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
    @required this.post
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
    @required this.post
  }) : assert(post != null);

  final Post post;

  @override
  Future<Then> effect(EffectContext context) async {
    await context.cache.put(_postIdToViewedKey(post.id), '');
    return Then.done();
  }
}
