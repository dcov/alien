part of 'data.dart';

List<T> _castList<T>(List list) =>
  (list != null && list.isNotEmpty) ? list.cast<T>() : null;

int _parseNum(dynamic value) =>
  value is num ? value.round() : null;

String _parseString(String s, { Iterable<String> exclude }) {
  if (s?.isNotEmpty == true && exclude?.contains(s) != true) {
    return s;
  }

  return null;
}

int _parseColor(String color) {
  color = _parseString(color);
  if (color != null) {
    color = color.replaceFirst('#', '0xFF');
    return int.tryParse(color);
  }
  return null;
}

mixin ThingData {

  static ThingData from(Map obj) {
    final String kind = obj['kind'];
    final Map data = obj['data'];
    switch (kind) {
      case 't1':
        return CommentData(data);
      case 't2':
        return AccountData(data);
      case 't3':
        return PostData(data);
      case 't4':
        return MessageData(data);
      case 't5':
        return SubredditData(data);
      case 'more':
        return MoreData(data);
    }
    return null;
  }

  Map get _data;

  String get kind;

  String get id => _data['id'];

  String get fullId => '${kind}_$id';
}

mixin CreatedData {

  Map get _data;

  int get createdAtUtc => _parseNum(_data['created_utc']);
}

mixin GildableData {

  Map get _data;

  bool get canGild => _data['can_gild'];

  int get gildCount => _parseNum(_data['gilded']);
}

mixin VotableData {

  Map get _data;

  int get downvoteCount => _parseNum(_data['downs']);

  bool get isArchived => _data['archived'];

  bool get isScoreHidden => _data['score_hidden'];

  int get score => _parseNum(_data['score']);

  int get upvoteCount => _parseNum(_data['ups']);

  VoteDir get voteDir {
    final bool likes = _data['likes'];
    if (likes == null)
      return VoteDir.none;
    
    return likes ? VoteDir.up : VoteDir.down;
  }
}

mixin SaveableData {

  Map get _data;

  bool get isSaved => _data['saved'];
}

class AccountData with ThingData, CreatedData {

  factory AccountData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return AccountData(extractor(jsonDecode(json)));
  }

  AccountData(this._data);

  final Map _data;

  @override
  String get kind => 't2';

  int get commentKarma => _parseNum(_data['comment_karma']);

  bool get hasMail => _data['has_mail'];

  bool get hasModMail => _data['has_mod_mail'];

  String get iconImageUrl => _parseString(_data['icon_image']);

  bool get isFriend => _data['is_friend'];

  bool get isGold => _data['is_gold'];

  bool get isMod => _data['is_mod'];

  bool get isOver18 => _data['over_18'];

  int get linkKarma => _parseNum(_data['link_karma']);

  String get username => _data['name'];
}

class CommentData with ThingData, CreatedData, GildableData,
    VotableData, SaveableData {

  factory CommentData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return CommentData(extractor(jsonDecode(json)));
  }
  
  CommentData(this._data);

  final Map _data;

  @override
  String get kind => 't1';

  int get approvedAtUtc => _data['approved_at_utc'];

  String get authorName => _data['author'];

  String get authorFlairBackgroundColor => _data['author_flair_background_color'];

  String get authorFlairCssClass => _data['author_flair_css_class'];

  String get authorFlairTemplateId => _data['author_flair_template_id'];

  String get authorFlairRichText => _data['author_flair_rich_text'];

  String get authorFlairText => _data['author_flair_text'];

  String get authorFlairTextColor => _data['author_flair_text_color'];

  String get authorFlairType => _data['author_flair_type'];

  String get authorFullId => _data['author_fullname'];

  int get bannedAtUtc => _parseNum(_data['banned_at_utc']);

  String get bannedBy => _data['banned_by'];

  String get body => _data['body'];

  String get bodyHtml => _data['body_html'];

  bool get canModPost => _data['can_mod_post'];

  String get collapsedReason => _data['collapsed_reason'];

  int get controversialityScore => _parseNum(_data['controversiality']);

  int get depth => _parseNum(_data['depth']);

  String get distinguishment => _data['distinguished'];

  int get editedAtUtc => _parseNum(_data['edited']);

  bool get isCollapsed => _data['collapsed'];

  bool get isNoFollow => _data['no_follow'];

  bool get isStickied => _data['stickied'];

  bool get isSubmitter => _data['is_submitter'];

  bool get fullPostId => _data['link_id'];

  String get modNote => _data['mod_note'];

  String get modReasonBy => _data['mod_reason_by'];

  String get modReasonTitle => _data['mod_reason_title'];

  Iterable<String> get modReports => _castList<String>(_data['mod_reports']);

  String get fullParentId => _data['parent_id'];

  String get permalink => _data['permalink'];

  String get removalReason => _data['removal_reason'];

  Iterable<ThingData> get replies sync* {
    final obj = _data['replies'];
    if (obj is Map) {
      final replies = obj['data']['children'];
      for (final reply in replies) {
        yield ThingData.from(reply);
      }
    }
  }

  int get reportCount => _parseNum(_data['num_reports']);

  Iterable<String> get reportReasons => _castList<String>(_data['report_reasons']);

  bool get sendReplies => _data['send_replies'];

  String get fullSubredditId => _data['subreddit_id'];

  String get subredditName => _data['subreddit'];

  String get subredditVisibility => _data['subreddit_type'];

  Iterable<String> get userReports => _castList<String>(_data['user_reports']);
}

class MessageData with ThingData, CreatedData {

  factory MessageData.fromJson(String json, [DataExtractor extractor]) {
    return MessageData(extractor(jsonDecode(json)));
  }

  MessageData(this._data);

  final Map _data;

  @override
  String get kind => 't4';

  String get authorName => _data["author"];

  String get body => _data["body"];

  String get context => _data["context"];

  String get firstMessage => _data["first_message"];

  bool get isLiked => _data["likes"];

  String get postTitle => _data["link_title"];

  String get subredditName => _data["subreddit"];

  bool get wasComment => _data["was_comment"];
}

class MoreData with ThingData {

  MoreData(this._data);

  final Map _data;

  @override
  String get kind => 'more';

  int get count => _parseNum(_data["count"]);

  Iterable<String> get thingIds => _data['children'].cast<String>();

  int get depth => _parseNum(_data["depth"]);

  String get fullParentId => _data["parent_id"];
}

class ResolutionData {

  ResolutionData(this._data);

  final Map _data;

  String get url => _data['url'];

  String get width => _data['width'];

  String get height => _data['height'];
}

class PreviewData {

  PreviewData(this._data);

  final Map _data;

  bool get enabled => _data['enabled'];

  Iterable<ResolutionData> get resolutions sync* {
    final obj = _data['images'][0];
    final source = obj['source'];
    if (source != null) {
      yield ResolutionData(source);
    }
    final extras = obj['resolutions'];
    if (extras != null) {
      for (final extra in extras) {
        yield ResolutionData(extra);
      }
    }
  }
}

class PostData with ThingData, CreatedData, GildableData,
    VotableData, SaveableData {

  factory PostData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return PostData(extractor(jsonDecode(json)));
  }

  PostData(this._data);

  final Map _data;

  @override
  String get kind => 't3';

  int get approvedAtUtc => _parseNum(_data['approved_at_utc']);

  String get approvedBy => _data['approved_by'];

  String get authorFlairBackgroundColor => _data['author_flair_background_color'];

  String get authorFlairCssClass => _data['author_flair_css_class'];

  String get authorFlairTemplateId => _data['author_flair_template_id'];

  String get authorFlairRichText => _data['author_flair_rich_text'];

  String get authorFlairText => _parseString(_data['author_flair_text']);

  String get authorFlairTextColor => _data['author_flair_text_color'];

  String get fullAuthorId => _data['author_fullname'];

  String get authorName => _data['author'];

  int get bannedAtUtc => _parseNum(_data['banned_at_utc']);

  String get bannedBy => _data['banned_by'];

  String get categoryName => _data['category'];

  bool get canModPost => _data['can_mod_post'];

  int get commentCount => _parseNum(_data['num_comments']);

  Iterable<String> get contentCategories => _castList(_data['content_categories']);

  int get crosspostCount => _parseNum(_data['num_crossposts']);

  String get distinguishment => _data['distinguished'];

  String get domainName => _data['domain'];

  int get editedAtUtc => _parseNum(_data['edited']);

  bool get isClicked => _data['clicked'];

  bool get isContestMode => _data['contest_mode'];

  bool get isCrosspostable => _data['is_crosspostable'];

  bool get isHidden => _data['hidden'];

  bool get isLocked => _data['locked'];

  bool get isMediaOnly => _data['media_only'];

  bool get isMeta => _data['is_meta'];

  bool get isNoFollow => _data['no_follow'];

  bool get isOriginalContent => _data['is_original_content'];

  bool get isNSFW => _data['over_18'];

  bool get isPinned => _data['pinned'];

  bool get isRedditMediaDomain => _data['is_reddit_media_domain'];

  bool get isSelf => _data['is_self'];

  bool get isSpoiler => _data['spoiler'];

  bool get isStickied => _data['stickied'];

  bool get isQuarantined => _data['quarantined'];

  bool get isVideo => _data['is_video'];

  bool get isVisited => _data['visited'];

  String get flairBackgroundColor => _data['link_flair_background_color'];

  String get flairCssClass => _data['link_flair_css_class'];

  String get flairTemplateId => _data['link_flair_template_id'];

  String get flairText => _data['link_flair_text'];

  String get flairTextColor => _data['link_flair_text_color'];

  String get flairType => _data['link_flair_type'];

  String get modNote => _data['mod_note'];

  String get modReasonBy => _data['mod_reason_by'];

  String get modReasonTitle => _data['mod_reason_title'];

  Iterable<String> get modReports => _castList<String>(_data['mod_reports']);

  String get parentWhitelistStatus => _data['parent_whitelist_status'];

  String get permalink => _data['permalink'];

  String get postHint => _data['post_hint'];

  PreviewData get preview {
    final preview = _data['preview'];
    return preview != null ? PreviewData(preview) : null;
  }

  String get removalReason => _data['removal_reason'];

  int get reportCount => _parseNum(_data['num_reports']);

  Iterable<String> get reportReasons => _castList<String>(_data['report_reasons']);

  String get selfText => _data['selftext'];

  String get selfTextHtml => _data['selftext_html'];

  bool get sendReplies => _data['send_replies'];

  String get subredditFullId => _data['subreddit_id'];

  String get subredditName => _data['subreddit'];

  int get subredditSubscriberCount => _parseNum(_data['subreddit_subscribers']);

  String get suggestedSort => _data['suggested_sort'];

  String get subredditVisibility => _data['subreddit_type'];

  String get thumbnailUrl => _parseString(_data['thumbnail'], exclude: const ['default']);

  String get title => _data['title'];

  String get url => _data['url'];

  Iterable<String> get userReports => _castList<String>(_data['user_reports']);

  int get viewCount => _parseNum(_data['view_count']);

  String get whitelistStatus => _data['whitelist_status'];
}

class SubredditData with ThingData, CreatedData {

  static Iterable<SubredditData> iterableFromJson(String json, [DataExtractor extractor = _extractNothing]) {
    final obj = extractor(jsonDecode(json));
    return obj.map((data) => SubredditData(data));
  }

  factory SubredditData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return SubredditData(extractor(jsonDecode(json)));
  }

  SubredditData(this._data);

  final Map _data;

  @override
  String get kind => 't5';

  int get activeUserCount => _parseNum(_data["active_user_count"]);

  int get bannerBackgroundColor => _parseColor(_data['banner_background_color']);

  String get bannerImageUrl => _parseString(_data['banner_background_image']) ?? _parseString(_data["banner_img"]);

  String get description => _data["description"];

  String get displayName => _data["display_name"] ?? _data['name'];

  String get headerImageUrl => _parseString(_data["header_img"]);

  String get iconImageUrl => _parseString(_data['community_icon']) ?? _parseString(_data['icon_img']);

  bool get isOver18 => _data["over_18"];

  bool get isPublic => (_data['subreddit_type'] == 'public');

  int get keyColor => _parseColor(_data['key_color']);

  int get primaryColor => _parseColor(_data['primary_color']);

  String get publicDescription => _data['public_description'];

  int get subscriberCount => _parseNum(_data['subscriber_count']) ?? _parseNum(_data["subscribers"]);

  bool get userIsModerator => _data['user_is_moderator'];

  bool get userIsSubscriber => _data['user_is_subscriber'];
}

class ListingData<T extends ThingData> {

  factory ListingData.fromJson(String json, [DataExtractor extractor = _extractData]) {
    return ListingData(extractor(jsonDecode(json)));
  }

  ListingData(this._data);

  final Map _data;

  String get nextId => _data['after'];

  String get previousId => _data['before'];

  Iterable<T> get things sync* {
    final Iterable items = _data['children'] ?? _data['things'];
    for (final item in items) {
      yield ThingData.from(item);
    }
  }
}

