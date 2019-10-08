part of 'app.dart';

class AppContainer {

  factory AppContainer(String clientId) {
    return AppContainer._(
      RedditClient(clientId),
      Scraper()
    );
  }

  AppContainer._(this.client, this.scraper);

  final RedditClient client;

  final Scraper scraper;
}
