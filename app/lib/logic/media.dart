import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/media.dart';

part 'media.msg.dart';

@action loadThumbnail(_, { @required Media media }) {
  assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
  media.thumbnailStatus = ThumbnailStatus.loading;
  return GetThumbnail(media: media);
}

@effect getThumbnail(EffectContext context, { @required Media media }) {
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

@action getThumbnailSuccess(_, { @required Media media, @required String result }) {
  media
    ..thumbnailStatus = result != null
        ? ThumbnailStatus.loaded
        : ThumbnailStatus.notFound
    ..thumbnail = result;
}

@action getThumbnailFailure(_) {
  // TODO: implement
}

