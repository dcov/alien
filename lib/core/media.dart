import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:muex/muex.dart';

import 'context.dart';

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

class LoadThumbnail implements Update {

  LoadThumbnail({
    required this.media
  });

  final Media media;

  @override
  Action update(_) {
    assert(media.thumbnailStatus == ThumbnailStatus.notLoaded);
    media.thumbnailStatus = ThumbnailStatus.loading;
    return _ScrapeThumbnail(media: media);
  }
}

class _ScrapeThumbnailIsolateMessage {

  _ScrapeThumbnailIsolateMessage({
    required this.originalUrl,
    required this.data,
  });

  final String originalUrl;
  final String data;
}

class _ScrapeThumbnail implements Effect {

  _ScrapeThumbnail({
    required this.media,
  });

  final Media media;

  static final imageUrlRegExp = RegExp('(http)?s?:?(\/\/[^"\']*\.(?:png|jpg|jpeg))');

  static String? _scrape(_ScrapeThumbnailIsolateMessage msg) {
    String? validateImageUrl(String imageUrl) {
      if (!imageUrlRegExp.hasMatch(imageUrl)) {
        return null;
      }

      final imageUri = Uri.parse(imageUrl);
      if (imageUri.scheme.isEmpty || imageUri.host.isEmpty) {
        final hostUri = Uri.parse(msg.originalUrl);
        final destinationUri = hostUri.resolve(imageUri.path);
        return destinationUri.toString();
      }

      return imageUrl;
    }

    final doc = htmlParser.parse(msg.data);

    for (final meta in doc.getElementsByTagName('meta')) {
      if (meta.attributes['property'] == 'og:image') {
        return validateImageUrl(meta.attributes['content']!);
      }
    }

    for (final video in doc.getElementsByTagName('video')) {
      final poster = video.attributes['poster'];
      if (poster != null) {
        return validateImageUrl(poster);
      }
    }

    for (final img in doc.getElementsByTagName('img')) {
      final src = img.attributes['src'];
      if (src != null) {
        return validateImageUrl(src);
      }
    }

    return null;
  }

  @override
  Future<Action> effect(CoreContext context) async {
    try {
      String? thumbnail;

      final thumbnailCacheKey = 'thumbnail-${media.source}';
      if (await context.cache.containsKey(thumbnailCacheKey)) {
        thumbnail = await context.cache.get(thumbnailCacheKey);
      } else {
        final data = await context.httpClient.read(Uri.parse(media.source));
        thumbnail = await compute<_ScrapeThumbnailIsolateMessage, String?>(
          _scrape,
          _ScrapeThumbnailIsolateMessage(
            originalUrl: media.source,
            data: data,
          )
        );

        /// Cache the result
        await context.cache.put(thumbnailCacheKey, thumbnail);
      }

      return _UpdateThumbnail(
        media: media,
        thumbnail: thumbnail,
      );
    } catch (_) {
      return _ScrapeThumbnailFailed(media: media);
    }
  }
}

class _UpdateThumbnail implements Update {

  _UpdateThumbnail({
    required this.media,
    this.thumbnail
  });

  final Media media;

  final String? thumbnail;

  @override
  Action update(_) {
    media
      ..thumbnailStatus = thumbnail != null
          ? ThumbnailStatus.loaded
          : ThumbnailStatus.notFound
      ..thumbnail = thumbnail;

    return None();
  }
}

class _ScrapeThumbnailFailed implements Update {

  _ScrapeThumbnailFailed({
    required this.media
  });

  final Media media;

  @override
  Action update(_) {
    media.thumbnailStatus = ThumbnailStatus.notFound;
    return None();
  }
}
