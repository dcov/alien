part of 'media.dart';

class ScrapeThumbnail extends Effect {

  const ScrapeThumbnail({ @required this.media });

  final Media media;

  @override
  Future<Event> perform(Deps deps) async {
    String result;
    try {
      result = await deps.scraper.getThumbnail(media.source);
    } finally {
      // ignore: control_flow_in_finally
      return ThumbnailScraped(
        media: media,
        result: result
      );
    }
  }
}

