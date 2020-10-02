import 'package:reddit/reddit.dart';

import '../models/media.dart';
import '../models/post.dart';
import '../models/snudown.dart';

import 'snudown.dart';

Post postFromData(PostData data) {
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

