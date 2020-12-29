import 'package:elmer/elmer.dart';

part 'media.g.dart';

enum ThumbnailStatus {
  notLoaded,
  loading,
  notFound,
  loaded
}

abstract class Media extends Model {

  factory Media({
    String source,
    ThumbnailStatus thumbnailStatus,
    String thumbnail
  }) = _$Media;

  String get source;

  ThumbnailStatus thumbnailStatus;

  String thumbnail;
}

