import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/media.dart';

class LoadThumbnail extends Action {

  LoadThumbnail({
    @required this.media
  });

  final Media media;

  dynamic update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return GetThumbnail(media: media);
  }
}

class GetThumbnail extends Effect {

  GetThumbnail({
    @required this.media
  });

  final Media media;

  dynamic perform(EffectContext context) {
    return context.scraper.getThumbnail(media.source)
        .then((String result) {
          return GetThumbnailSuccess(
            media: media,
            result: result);
        })
        .catchError((_) {
          return GetThumbnailFailure();
        });
  }
}

class GetThumbnailSuccess extends Action {

  GetThumbnailSuccess({
    @required this.media,
    @required this.result
  });

  final Media media;

  final String result;

  @override
  dynamic update(_) {
    media
      ..thumbnailStatus = result != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notFound
      ..thumbnail = result;
  }
}

class GetThumbnailFailure extends Action {

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

