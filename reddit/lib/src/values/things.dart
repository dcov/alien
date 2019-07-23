import 'package:built_value/built_value.dart';

part 'things.g.dart';

abstract class Thing {
  @nullable String get kind;
  @nullable String get id;
  String get fullId => '$kind\_$id';
}

abstract class Created implements Thing {
  @nullable int get created;
  @nullable int get createdUtc;
}

abstract class Archivable implements Thing {
  @nullable bool get isArchived;
}

abstract class Votable implements Thing, Archivable {
  @nullable int get downvoteCount;
  @nullable bool get isLiked;
  @nullable bool get isScoreHidden;
  @nullable int get score;
  @nullable int get upvoteCount;
}

abstract class Gildable implements Thing {
  @nullable bool get canGild;
  @nullable int get gildCount;
}

abstract class Saveable implements Thing {
  @nullable bool get isSaved;
}

abstract class Account extends Object with Thing, Created implements Built<Account, AccountBuilder> {
  @override String get kind => 't2';
  @nullable int get commentKarma;
  @nullable bool get hasMail;
  @nullable bool get hasModMail;
  @nullable String get iconImageUrl;
  @nullable bool get isFriend;
  @nullable bool get isGold;
  @nullable bool get isMod;
  @nullable bool get isOver18;
  @nullable int get linkKarma;
  @nullable String get username;

  Account._();
  factory Account([updates(AccountBuilder b)]) = _$Account;
}

abstract class Comment extends Object with Thing, Created, Votable, Gildable, Saveable implements Built<Comment, CommentBuilder> {
  @override String get kind => 't1';
  @nullable int get approvedAtUtc;
  @nullable String get approvedBy;
  @nullable String get authorName;
  @nullable String get authorFlairBackgroundColor;
  @nullable String get authorFlairCssClass;
  @nullable String get authorFlairTemplateId;
  @nullable String get authorFlairRichText;
  @nullable String get authorFlairText;
  @nullable String get authorFlairTextColor;
  @nullable String get authorFlairType;
  @nullable String get authorFullId;
  @nullable int get bannedAtUtc;
  @nullable String get bannedBy;
  @nullable String get body;
  @nullable String get bodyHtml;
  @nullable bool get canModPost;
  @nullable String get collapsedReason;
  @nullable int get controversialityScore;
  @nullable int get depth;
  @nullable String get distinguishment;
  @nullable int get editedUtc;
  @nullable bool get isCollapsed;
  @nullable bool get isNoFollow;
  @nullable bool get isStickied;
  @nullable bool get isSubmitter;
  @nullable String get linkFullId;
  @nullable String get modNote;
  @nullable String get modReasonBy;
  @nullable String get modReasonTitle;
  @nullable Iterable<String> get modReports;
  @nullable String get parentFullId;
  @nullable String get permalink;
  @nullable String get removalReason;
  @nullable Iterable<Thing> get replies;
  @nullable int get reportCount;
  @nullable Iterable<String> get reportReasons;
  @nullable bool get sendReplies;
  @nullable String get subredditFullId;
  @nullable String get subredditName;
  String get subredditNamePrefixed => 'r/$subredditName';
  @nullable String get subredditVisibility;
  @nullable Iterable<String> get userReports;

  Comment._();
  factory Comment([updates(CommentBuilder b)]) = _$Comment;
}

abstract class Resolution implements Built<Resolution, ResolutionBuilder> {
  @nullable String get url;
  @nullable int get width;
  @nullable int get height;

  Resolution._();
  factory Resolution([updates(ResolutionBuilder b)]) = _$Resolution;
}

abstract class Preview implements Built<Preview, PreviewBuilder> {
  @nullable bool get enabled;
  @nullable Iterable<Resolution> get resolutions;

  Preview._();
  factory Preview([updates(PreviewBuilder b)]) = _$Preview;
}

enum Distinguishment {
  moderator,
  admin,
  special
}

abstract class Link extends Object with Thing, Created, Votable, Gildable, Saveable implements Built<Link, LinkBuilder> {
  @override String get kind => 't3';
  @nullable int get approvedAtUtc;
  @nullable String get approvedBy;
  @nullable String get authorFlairBackgroundColor;
  @nullable String get authorFlairCssClass;
  @nullable String get authorFlairTemplateId;
  @nullable String get authorFlairRichText;
  @nullable String get authorFlairText;
  @nullable String get authorFlairTextColor;
  @nullable String get authorFullId;
  @nullable String get authorName;
  @nullable int get bannedAtUtc;
  @nullable String get bannedBy;
  @nullable String get categoryName;
  @nullable bool get canModPost;
  @nullable int get commentCount;
  @nullable Iterable<String> get contentCategories;
  @nullable int get crosspostCount;
  @nullable String get domainName;
  @nullable Distinguishment get distinguishment;
  @nullable int get editedUtc;
  @nullable bool get isClicked;
  @nullable bool get isContestMode;
  @nullable bool get isCrosspostable;
  @nullable bool get isHidden;
  @nullable bool get isLocked;
  @nullable bool get isMediaOnly;
  @nullable bool get isMeta;
  @nullable bool get isNoFollow;
  @nullable bool get isOriginalContent;
  @nullable bool get isOver18;
  @nullable bool get isPinned;
  @nullable bool get isRedditMediaDomain;
  @nullable bool get isSelf;
  @nullable bool get isSpoiler;
  @nullable bool get isStickied;
  @nullable bool get isQuarantined;
  @nullable bool get isVideo;
  @nullable bool get isVisited;
  @nullable String get linkFlairBackgroundColor;
  @nullable String get linkFlairCssClass;
  @nullable String get linkFlairTemplateId;
  @nullable String get linkFlairText;
  @nullable String get linkFlairTextColor;
  @nullable String get linkFlairType;
  @nullable String get modNote;
  @nullable String get modReasonBy;
  @nullable String get modReasonTitle;
  @nullable Iterable<String> get modReports;
  @nullable String get parentWhitelistStatus;
  @nullable String get permalink;
  @nullable String get postHint;
  @nullable Preview get preview;
  @nullable String get removalReason;
  @nullable int get reportCount;
  @nullable Iterable<String> get reportReasons;
  @nullable String get selfText;
  @nullable String get selfTextHtml;
  @nullable bool get sendReplies;
  @nullable String get subredditFullId;
  @nullable String get subredditName;
  String get subredditNamePrefixed => 'r/$subredditName';
  @nullable int get subredditSubscriberCount;
  @nullable String get suggestedSort;
  @nullable String get subredditVisibility;
  @nullable String get thumbnailUrl;
  @nullable String get title;
  @nullable String get url;
  @nullable Iterable<String> get userReports;
  @nullable int get viewCount;
  @nullable String get whitelistStatus;

  Link._();
  factory Link([updates(LinkBuilder b)]) = _$Link;
}

abstract class Message extends Object with Thing, Created implements Built<Message, MessageBuilder> {
  @override String get kind => 't4';
  @nullable String get authorName;
  @nullable String get body;
  @nullable String get context;
  @nullable String get firstMessage;
  @nullable bool get isLiked;
  @nullable String get linkTitle;
  @nullable String get subredditName;
  @nullable bool get wasComment;

  Message._();
  factory Message([updates(MessageBuilder b)]) = _$Message;
}

abstract class More extends Object with Thing implements Built<More, MoreBuilder> {
  @override String get kind => 'more';
  @nullable int get count;
  @nullable Iterable<String> get thingIds;
  @nullable int get depth;
  @nullable String get parentFullId;

  More._();
  factory More([updates(MoreBuilder b)]) = _$More;
}

abstract class Subreddit extends Object with Thing, Created implements Built<Subreddit, SubredditBuilder> {
  @override String get kind => 't5';
  @nullable int get activeUserCount;
  @nullable int get bannerBackgroundColor;
  @nullable String get bannerImageUrl;
  @nullable String get description;
  @nullable String get displayName;
  String get displayNamePrefixed => 'r/$displayName';
  @nullable String get headerImageUrl;
  @nullable String get iconImageUrl;
  @nullable bool get isPublic;
  @nullable bool get isOver18;
  @nullable int get keyColor;
  @nullable int get primaryColor;
  @nullable String get publicDescription;
  @nullable int get subscriberCount;
  @nullable bool get userIsModerator;
  @nullable bool get userIsSubscriber;

  Subreddit._();
  factory Subreddit([updates(SubredditBuilder b)]) = _$Subreddit;
}

abstract class Listing<T extends Thing> implements Built<Listing<T>, ListingBuilder<T>> {
  @nullable String get nextId;
  @nullable String get previousId;
  @nullable Iterable<T> get things;

  Listing._();
  factory Listing([updates(ListingBuilder<T> b)]) = _$Listing<T>;
}
