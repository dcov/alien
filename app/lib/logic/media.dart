import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/media.dart';

class LoadThumbnail extends Action {

  LoadThumbnail({
    @required this.media
  }) : assert(media != null);

  final Media media;

  @override
  dynamic update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return _GetThumbnail(media: media);
  }
}

class _GetThumbnail extends Effect {

  _GetThumbnail({
    @required this.media
  }) : assert(media != null);

  final Media media;

  String get _thumbnailCacheKey => 'thumbnail-${media.source}';

  @override
  dynamic perform(EffectContext context) async {
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

      return _FinishGetThumbnail(
        media: media,
        thumbnail: thumbnail);
    } catch (_) {
      return _GetThumbnailFailed();
    }
  }
}

class _FinishGetThumbnail extends Action {

  _FinishGetThumbnail({
    @required this.media,
    @required this.thumbnail
  }) : assert(media != null),
       assert(thumbnail != null);

  final Media media;

  final String thumbnail;

  @override
  dynamic update(_) {
    media
      ..thumbnailStatus = thumbnail != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notFound
      ..thumbnail = thumbnail;
  }
}

class _GetThumbnailFailed extends Action {

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

