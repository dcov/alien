part of 'media.dart';

class ThumbnailUrl {
  const ThumbnailUrl._();
}

class ThumbnailUrlLoading implements ThumbnailUrl {
  const ThumbnailUrlLoading._();
}

class ThumbnailUrlValue implements ThumbnailUrl {
  ThumbnailUrlValue(this.value);
  final String value;
}

class ThumbnailUrlNotFound implements ThumbnailUrl {
  const ThumbnailUrlNotFound._();
}

abstract class Media extends Model {

  factory Media({
    @required String source,
    String thumbnailUrl
  }) {
    return _$Media(
      source: source,
      thumbnailUrl: thumbnailUrl != null
          ? ThumbnailUrlValue(thumbnailUrl)
          : const ThumbnailUrl._(),
    );
  }

  String get source;

  ThumbnailUrl thumbnailUrl;
}
