import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects/effect_context.dart';

import 'media_events.dart';
import 'media_model.dart';

class ScrapeThumbnail extends Effect {

  const ScrapeThumbnail({ @required this.media });

  final Media media;

  @override
  Future<Event> perform(EffectContext context) async {
    String result;
    try {
      result = await context.scraper.getThumbnail(media.source);
    } finally {
      // ignore: control_flow_in_finally
      return ThumbnailScraped(
        media: media,
        result: result
      );
    }
  }
}

