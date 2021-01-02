import 'package:mal/mal.dart';

part 'media.g.dart';

enum ThumbnailStatus {
  notLoaded,
  loading,
  notFound,
  loaded
}

abstract class Media implements Model {

  factory Media({
    String source,
    ThumbnailStatus thumbnailStatus,
    String thumbnail
  }) = _$Media;

  String get source;

  ThumbnailStatus thumbnailStatus;

  String thumbnail;
}

