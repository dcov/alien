part of 'media.dart';

class LoadMediaThumbnail extends Event {

  const LoadMediaThumbnail({ @required this.mediaKey });

  final ModelKey mediaKey;

  @override
  Effect update(Store store) {
    final Media media = store.get(this.mediaKey);
    assert(media != null);
    if (media.thumbnailUrl is ThumbnailUrlLoading ||
        media.thumbnailUrl is ThumbnailUrlValue ||
        media.thumbnailUrl is ThumbnailUrlNotFound)
      return null;
    
    media.thumbnailUrl = const ThumbnailUrlLoading._();
    return ScrapeThumbnailUrl(
      mediaKey: this.mediaKey,
      source: media.source
    );
  }
}

class MediaThumbnailFound extends Event {

  const MediaThumbnailFound({
    @required this.mediaKey,
    @required this.value
  });

  final ModelKey mediaKey;

  final String value;

  @override
  void update(Store store) {
    store.get<Media>()?.thumbnailUrl = ThumbnailUrlValue._(this.value);
  }
}

class MediaThumbnailNotFound extends Event {

  const MediaThumbnailNotFound({ @required this.mediaKey });

  final ModelKey mediaKey;

  @override
  void update(Store store) {
    store.get<Media>()?.thumbnailUrl = const ThumbnailUrlNotFound._();
  }
}
