import 'package:elmer/elmer.dart';

part 'media.mdl.dart';

enum ThumbnailStatus {
  notLoaded,
  loading,
  notFound,
  loaded
}

@model
mixin $Media {

  String get source;

  ThumbnailStatus thumbnailStatus;

  String thumbnail;
}

