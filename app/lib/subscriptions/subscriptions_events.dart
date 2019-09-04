part of 'subscriptions.dart';

class UpdateSubscriptions extends Event {

  UpdateSubscriptions({
    @required this.subscriptionsKey,
    @required this.listingData,
  });

  final ModelKey subscriptionsKey;

  final ListingData listingData;

  @override
  void update(Store store) {
    for (final SubredditData subredditData in listingData.things) {
    }
  }
}
