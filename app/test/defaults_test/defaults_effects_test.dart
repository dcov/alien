part of 'defaults_test.dart';

class MockSubredditListing extends Mock implements ListingData<SubredditData> { }

void testDefaultsEffects() => group('Defaults Effects Test', () {
  test('GetDefaults Test', () {
    final MockDefaults defaults = MockDefaults();
    final MockDeps deps = MockDeps();
    when(deps.client).thenReturn(MockRedditClient());
    final MockRedditClient client = deps.client;
    when(client.asDevice()).thenReturn(MockRedditInteractor());
    final MockRedditInteractor interactor = client.asDevice();
    final MockSubredditListing listing = MockSubredditListing();
    final List<SubredditData> data = <SubredditData>[];
    when(listing.things).thenReturn(data);
    when(interactor.getSubreddits(any, any))
        .thenAnswer((_) => Future.value(listing));

    GetDefaults(defaults: defaults).perform(deps)
        .then((result) {
          verify(deps.client);
          verify(client.asDevice());
          verify(listing.things);
          verify(interactor.getSubreddits(any, any));
          expect(result, isA<DefaultsLoaded>());
          final DefaultsLoaded event = result;
          expect(event.defaults, equals(defaults));
          expect(event.subreddits, equals(data));
        });
  });
});

