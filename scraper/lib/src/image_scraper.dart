part of scraper;

mixin _ImageScraper on _BaseScraper {

  static final RegExp imageUrlRegExp = RegExp('(http)?s?:?(\/\/[^"\']*\.(?:png|jpg|jpeg))');

  static String _validateImageUrl(String originalUrl, String imageUrl) {

    if (!imageUrlRegExp.hasMatch(imageUrl)) {
      return null;
    }

    final imageUri = Uri.parse(imageUrl);
    if (imageUri.scheme.isEmpty || imageUri.host.isEmpty) {
      final hostUri = Uri.parse(originalUrl);
      final destinationUri = hostUri.resolve(imageUri.path);
      return destinationUri.toString();
    }

    return imageUrl;
  }

  /// Scrapes the [url] for an image that can act as a thumbnail.
  static Future<String> _getThumbnail(String url) {
    return _client.read(url).then((String data) {
      final doc = parser.parse(data);

      for (final meta in doc.getElementsByTagName('meta')) {
        if (meta.attributes['property'] == 'og:image') {
          return _validateImageUrl(url, meta.attributes['content']);
        }
      }

      for (final video in doc.getElementsByTagName('video')) {
        final poster = video.attributes['poster'];
        if (poster != null) {
          return _validateImageUrl(url, poster);
        }
      }

      for (final img in doc.getElementsByTagName('img')) {
        final src = img.attributes['src'];
        if (src != null) {
          return _validateImageUrl(url, src);
        }
      }

      return null;
    });
  }

  Future<String> getThumbnail(String url) {
    return _runner.run(_getThumbnail, url);
  }
}
