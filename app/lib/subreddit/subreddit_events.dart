import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart' show Page, ListingData, PostData;

import '../auth/auth_model.dart';
import '../listing/listing_events.dart';
import '../listing/listing_model.dart';
import '../post/post_model.dart';
import '../subreddit/subreddit_model.dart';
import '../user/user_model.dart';

import 'subreddit_effects.dart';

class InitSubreddit extends Event {

  InitSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.posts = Listing<Post>(
      status: ListingStatus.idle,
      things: <Post>[]);

    return UpdateSubredditPosts(
      subreddit: subreddit,
      newStatus: ListingStatus.refreshing);
  }
}

class DisposeSubreddit extends Event {

  DisposeSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.posts = null;
  }
}

class ToggleSubscribed extends Event {

  ToggleSubscribed({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(RootAuth root) {
    final User user = root.auth.currentUser;
    assert(user != null);

    subreddit.userIsSubscriber = !subreddit.userIsSubscriber;

    if (subreddit.userIsSubscriber)
      return <Message>{
        RemoveSubscription(subreddit: subreddit),
        PostUnsubscribe(
          subreddit: subreddit,
          user: user)
      };

    return <Message>{
      AddSubscription(subreddit: subreddit),
      PostSubscribe(
        subreddit: subreddit,
        user: user)
    };
  }
}

class AddSubscription extends ProxyEvent {

  AddSubscription({ @required this.subreddit });

  final Subreddit subreddit;
}

class RemoveSubscription extends ProxyEvent {

  RemoveSubscription({ @required this.subreddit });

  final Subreddit subreddit;
}

class PostSubscribeFail extends Event {

  PostSubscribeFail({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.userIsSubscriber = false;
  }
}

class PostUnsubscribeFail extends Event {

  PostUnsubscribeFail({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.userIsSubscriber = true;
  }
}

class UpdateSubredditPosts extends UpdateListing {

  const UpdateSubredditPosts({
    @required this.subreddit,
    @required this.newStatus
  });

  final Subreddit subreddit;

  final ListingStatus newStatus;

  @override
  dynamic update(_) {
    final Page page = updateListing(subreddit.posts, newStatus);
    if (page != null) {
      return GetSubredditPosts(
        subreddit: subreddit,
        newStatus: newStatus,
        page: page);
    }
  }
}

class GetSubredditPostsSuccess extends UpdateListingSuccess {

  GetSubredditPostsSuccess({
    @required this.subreddit,
    @required this.expectedStatus,
    @required this.result,
  });

  final Subreddit subreddit;
  final ListingStatus expectedStatus;
  final ListingData<PostData> result;

  @override
  dynamic update(_) {
    updateListingSuccess(
      subreddit.posts,
      expectedStatus,
      result,
      (data) => Post.fromData(data));
  }
}

class GetSubredditPostsFail extends Event {

  const GetSubredditPostsFail();

  @override
  dynamic update(_) { }
}

