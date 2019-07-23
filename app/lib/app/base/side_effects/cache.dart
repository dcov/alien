import 'dart:async';

import 'package:quiver/collection.dart';

LruMap<String, String> _thumbnailCache;

mixin CacheMixin {
  Map<String, String> getThumbnailCache() => _thumbnailCache;
}

mixin CacheScopeMixin {
  Future<void> initCache() async {
     _thumbnailCache = LruMap(maximumSize: 1000);
  }
}