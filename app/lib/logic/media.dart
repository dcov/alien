import 'package:muex/muex.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/media.dart';

class LoadThumbnail implements Update {

  LoadThumbnail({
    @required this.media
  }) : assert(media != null);

  final Media media;

  @override
  Then update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return Then(_GetThumbnail(media: media));
  }
}

class _GetThumbnail implements Effect {

  _GetThumbnail({
    @required this.media
  }) : assert(media != null);

  final Media media;

  String get _thumbnailCacheKey => 'thumbnail-${media.source}';

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      String thumbnail;
      if (await context.cache.containsKey(_thumbnailCacheKey)) {
        thumbnail = await context.cache.get(_thumbnailCacheKey);
      } else {
        /// Scrape the thumbnail from the source site
        thumbnail = await context.scraper.getThumbnail(media.source);
        /// Cache the result
        await context.cache.put(_thumbnailCacheKey, thumbnail);
      }

      return Then(_UpdateThumbnail(
        media: media,
        thumbnail: thumbnail));
    } catch (_) {
      return Then(_GetThumbnailFailed(
        media: media));
    }
  }
}

class _UpdateThumbnail implements Update {

  _UpdateThumbnail({
    @required this.media,
    @required this.thumbnail
  }) : assert(media != null),
       assert(thumbnail != null);

  final Media media;

  final String thumbnail;

  @override
  Then update(_) {
    media
      ..thumbnailStatus = thumbnail != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notFound
      ..thumbnail = thumbnail;

    return Then.done();
  }
}

class _GetThumbnailFailed implements Update {

  _GetThumbnailFailed({
    @required this.media
  }) : assert(media != null);

  final Media media;

  @override
  Then update(_) {
    media.thumbnailStatus = ThumbnailStatus.notFound;
    return Then.done();
  }
}

