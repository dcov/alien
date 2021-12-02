import 'package:muex/muex.dart';

import '../reddit/types.dart';

import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit implements Model, Thing {

  factory Subreddit({
    required SubredditData data,
  }) {
    return _$Subreddit(
      kind: data.kind,
      id: data.id,
      bannerBackgroundColor: data.bannerBackgroundColor,
      bannerImageUrl: data.bannerImageUrl,
      iconImageUrl: data.iconImageUrl,
      name: data.displayName,
      primaryColor: data.primaryColor,
      userIsSubscriber: data.userIsSubscriber ?? false
    );
  }

  factory Subreddit.raw({
    int? bannerBackgroundColor,
    String? bannerImageUrl,
    String? iconImageUrl,
    required String name,
    int? primaryColor,
    required bool userIsSubscriber,
    required String id,
    required String kind,
  }) = _$Subreddit;

  int? get bannerBackgroundColor;
  set bannerBackgroundColor(int? value);

  String? get bannerImageUrl;
  set bannerImageUrl(String? value);

  String? get iconImageUrl;
  set iconImageUrl(String? value);

  String get name;

  int? get primaryColor;
  set primaryColor(int? value);

  bool get userIsSubscriber;
  set userIsSubscriber(bool value);
}
