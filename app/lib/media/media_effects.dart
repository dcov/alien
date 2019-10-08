part of 'media.dart';

class ScrapeThumbnail extends Effect {

  const ScrapeThumbnail({ @required this.media });

  final Media media;

  @override
  Future<Event> perform(AppContainer container) async {
    String result;
    try {
      result = await container.scraper.getThumbnail(media.source);
    } finally {
      // ignore: control_flow_in_finally
      return ThumbnailScraped(
        media: media,
        result: result
      );
    }
  }
}
