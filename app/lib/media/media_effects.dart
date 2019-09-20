part of 'media.dart';

class ScrapeThumbnailUrl extends Effect {

  const ScrapeThumbnailUrl({
    @required this.mediaKey,
    @required this.source
  });

  final ModelKey mediaKey;

  final String source;

  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<Scraper>()
      .getThumbnail(this.source)
      .then((String result) {
        return result != null
          ? MediaThumbnailFound(
              mediaKey: this.mediaKey,
              value: result)
          : MediaThumbnailNotFound(
              mediaKey: this.mediaKey);
      });
  }
}
