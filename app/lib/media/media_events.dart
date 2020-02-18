import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import 'media_effects.dart';
import 'media_model.dart';

class LoadThumbnail extends Event {

  const LoadThumbnail({ @required this.media });

  final Media media;

  @override
  dynamic update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return ScrapeThumbnail(media: this.media);
  }
}

class ThumbnailScraped extends Event {

  const ThumbnailScraped({
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

