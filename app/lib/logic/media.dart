import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/media.dart';

class LoadThumbnail implements Event {

  LoadThumbnail({
    @required this.media
  });

  final Media media;

  @override
  Effect update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return GetThumbnail(media: this.media);
  }
}

class GetThumbnail implements Effect {

  GetThumbnail({ @required this.media });

  final Media media;

  @override
  Future<Event> perform(EffectContext context) {
    return context.scraper.getThumbnail(media.source)
        .then((String result) {
          return GetThumbnailSuccess(
            media: media,
            result: result);
        })
        .catchError((_) {
          return GetThumbnailFailure(media: media);
        });
  }
}

class GetThumbnailSuccess implements Event {

  GetThumbnailSuccess({
    @required this.media,
    @required this.result
  });

  final Media media;

  final String result;

  @override
  void update(_) {
    media
      ..thumbnailStatus = result != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notFound
      ..thumbnail = result;
  }
}

class GetThumbnailFailure implements Event {

  GetThumbnailFailure({
    @required this.media
  });

  final Media media;
  
  @override
  void update(_) {
  }
}

