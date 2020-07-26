import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

part 'media_model.g.dart';

enum ThumbnailStatus {
  notLoaded,
  loading,
  notFound,
  loaded
}

abstract class Media implements Model {

  factory Media({
    @required String source,
    String thumbnail
  }) {
    return _$Media(
      source: source,
      thumbnailStatus: thumbnail != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notLoaded,
      thumbnail: thumbnail
    );
  }

  String get source;

  ThumbnailStatus thumbnailStatus;

  String thumbnail;
}

