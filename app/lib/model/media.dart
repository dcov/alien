import 'package:muex/muex.dart';

part 'media.g.dart';

enum ThumbnailStatus {
  notLoaded,
  loading,
  notFound,
  loaded
}

abstract class Media implements Model {

  factory Media({
    required String source,
    required ThumbnailStatus thumbnailStatus,
    String? thumbnail
  }) = _$Media;

  String get source;

  ThumbnailStatus get thumbnailStatus;
  set thumbnailStatus(ThumbnailStatus value);

  String? get thumbnail;
  set thumbnail(String? value);
}
