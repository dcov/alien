import 'dart:convert';
import 'package:reddit/values.dart';

Map _extractData(Map obj) {
  return obj['data'] ?? obj;
}

Map _decodeData(String json) {
  final obj = jsonDecode(json);
  return _extractData(obj);
}

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

Account buildAccount(Map obj) {
  obj = _extractData(obj);
  return Account((AccountBuilder b) => b
    ..id = obj['id']
    ..created = _parseNum(obj['created'])
    ..createdUtc = _parseNum(obj["created_utc"])
    ..commentKarma = _parseNum(obj["comment_karma"])
    ..hasMail = obj['has_mail']
    ..hasModMail = obj['has_mod_mail']
    ..iconImageUrl = _parseString(obj['icon_img'])
    ..isFriend = obj['is_friend']
    ..isGold = obj['is_gold']
    ..isMod = obj['is_mod']
    ..isOver18 = obj["over_18"]
    ..linkKarma = _parseNum(obj["link_karma"])
    ..username = obj['name']
  );
}

Account decodeAccount(String json) {
  return buildAccount(_decodeData(json));
}

List<Thing> _extractReplies(Map obj) {
  final replies = obj["replies"];
  if (replies is String)
    return null;
  else 
    return buildListing<Thing>(replies, buildCommentsTreeThing).things;
}

Comment buildComment(Map obj) {
  obj = _extractData(obj);
  return Comment((CommentBuilder b) => b
    ..id = obj["id"]
    ..created = _parseNum(obj['created'])
    ..createdUtc = _parseNum(obj["created_utc"])
    ..downvoteCount = _parseNum(obj['downs'])
    ..isLiked = obj['likes']
    ..isScoreHidden = obj['score_hidden']
    ..score = _parseNum(obj['score'])
    ..upvoteCount = _parseNum(obj['ups'])
    ..canGild = obj['can_gild']
    ..gildCount = _parseNum(obj['gilded'])
    ..isSaved = obj['saved']
    ..approvedAtUtc = _parseNum(obj['approved_at_utc'])
    ..approvedBy = obj['approved_by']
    ..authorName = obj['author']
    ..authorFlairBackgroundColor = obj['author_flair_background_color']
    ..authorFlairCssClass = obj['author_flair_css_class']
    ..authorFlairTemplateId = obj['author_flair_template_id']
    ..authorFlairRichText = obj['author_flair_rich_text']
    ..authorFlairText = obj['author_flair_text']
    ..authorFlairTextColor = obj['author_flair_text_color']
    ..authorFlairType = obj['author_flair_type']
    ..authorFullId = obj['author_fullname']
    ..bannedAtUtc = _parseNum(obj['banned_at_utc'])
    ..bannedBy = obj['banned_by']
    ..body = obj['body']
    ..bodyHtml = obj['body_html']
    ..canModPost = obj['can_mod_post']
    ..collapsedReason = obj['collapsed_reason']
    ..controversialityScore = _parseNum(obj['controversiality'])
    ..depth = _parseNum(obj['depth'])
    ..distinguishment = obj['distinguished']
    ..editedUtc = _parseNum(obj['edited'])
    ..isArchived = obj['archived']
    ..isCollapsed = obj['collapsed']
    ..isNoFollow = obj['no_follow']
    ..isStickied = obj['stickied']
    ..isSubmitter = obj['is_submitter']
    ..linkFullId = obj['link_id']
    ..modNote = obj['mod_note']
    ..modReasonBy = obj['mod_reason_by']
    ..modReasonTitle = obj['mod_reason_title']
    ..modReports = _castList<String>(obj['mod_reports'])
    ..parentFullId = obj['parent_id']
    ..permalink = obj['permalink']
    ..removalReason = obj['removal_reason']
    ..replies = _extractReplies(obj)
    ..reportCount = _parseNum(obj['num_reports'])
    ..reportReasons = _castList<String>(obj['report_reasons'])
    ..sendReplies = obj['send_replies']
    ..subredditFullId = obj['subreddit_id']
    ..subredditName = obj['subreddit']
    ..subredditVisibility = obj['subreddit_type']
    ..userReports = _castList<String>(obj['user_reports'])
  );
}

Comment decodeComment(String json) => buildComment(_decodeData(json));

Distinguishment _parseDistinguishment(String value) {
  if (value != null) {
    switch (value) {
      case 'moderator':
        return Distinguishment.moderator;
      case 'admin':
        return Distinguishment.admin;
      default:
        return Distinguishment.special;
    }
  }

  return null;
}

Resolution buildResolution(Map obj) {
  return Resolution((b) => b
    ..url = obj['url']
    ..width = _parseNum(obj['width'])
    ..height = _parseNum(obj['height'])
  );
}

PreviewBuilder buildPreviewBuilder(Map obj) {
  final builder = PreviewBuilder();

  if (obj['preview'] != null) {
    obj = obj['preview'];
    builder.enabled = obj['enabled'];

    final resolutions = List<Resolution>();
    obj = obj['images'][0];
    resolutions.add(buildResolution(obj['source']));
    final other = obj['resolutions'];
    for (final res in other) {
      resolutions.add(buildResolution(res));
    }

    builder.resolutions = resolutions;
    return builder;
  }

  return null;
}

Link buildLink(Map obj) {
  obj = _extractData(obj);
  return Link((LinkBuilder b) => b
    ..id = obj["id"]
    ..created = _parseNum(obj['created'])
    ..createdUtc = _parseNum(obj["created_utc"])
    ..downvoteCount = _parseNum(obj["downs"])
    ..isLiked = obj["likes"]
    ..isScoreHidden = obj['score_hidden']
    ..score = _parseNum(obj['score'])
    ..upvoteCount = _parseNum(obj['ups'])
    ..canGild = obj['can_gild']
    ..gildCount= _parseNum(obj["gilded"])
    ..isSaved= obj["saved"]
    ..approvedAtUtc = _parseNum(obj['approved_at_utc'])
    ..approvedBy = obj['approved_by']
    ..authorFlairBackgroundColor = obj['author_flair_background_color']
    ..authorFlairCssClass = obj['author_flair_css_class']
    ..authorFlairTemplateId = obj['author_flair_template_id']
    ..authorFlairRichText = obj['author_flair_rich_text']
    ..authorFlairText = _parseString(obj['author_flair_text'])
    ..authorFlairTextColor = obj['author_flair_text_color']
    ..authorFullId = obj['author_fullname']
    ..authorName = obj['author']
    ..bannedAtUtc = _parseNum(obj['banned_at_utc'])
    ..bannedBy = obj['banned_by']
    ..categoryName = obj['category']
    ..canModPost = obj['can_mod_post']
    ..commentCount = _parseNum(obj['num_comments'])
    ..contentCategories = _castList(obj['content_categories'])
    ..crosspostCount = _parseNum(obj['num_crossposts'])
    ..distinguishment = _parseDistinguishment(obj['distinguished'])
    ..domainName = obj['domain']
    ..editedUtc = _parseNum(obj['edited'])
    ..isArchived = obj['archived']
    ..isClicked = obj['clicked']
    ..isContestMode = obj['contest_mode']
    ..isCrosspostable = obj['is_crosspostable']
    ..isHidden = obj['hidden']
    ..isLocked = obj['locked']
    ..isMediaOnly = obj['media_only']
    ..isMeta = obj['is_meta']
    ..isNoFollow = obj['no_follow']
    ..isOriginalContent = obj['is_original_content']
    ..isOver18 = obj['over_18']
    ..isPinned = obj['pinned']
    ..isRedditMediaDomain = obj['is_reddit_media_domain']
    ..isSelf = obj['is_self']
    ..isSpoiler = obj['spoiler']
    ..isStickied = obj['stickied']
    ..isQuarantined = obj['quarantined']
    ..isVideo = obj['is_video']
    ..isVisited = obj['visited']
    ..linkFlairBackgroundColor = obj['link_flair_background_color']
    ..linkFlairCssClass = obj['link_flair_css_class']
    ..linkFlairTemplateId = obj['link_flair_template_id']
    ..linkFlairText = obj['link_flair_text']
    ..linkFlairTextColor = obj['link_flair_text_color']
    ..linkFlairType = obj['link_flair_type']
    ..modNote = obj['mod_note']
    ..modReasonBy = obj['mod_reason_by']
    ..modReasonTitle = obj['mod_reaso_title']
    ..modReports = _castList<String>(obj['mod_reports'])
    ..parentWhitelistStatus = obj['parent_whitelist_status']
    ..permalink = obj['permalink']
    ..postHint = obj['post_hint']
    ..preview = buildPreviewBuilder(obj)
    ..removalReason = obj['removal_reason']
    ..reportCount = _parseNum(obj['num_reports'])
    ..reportReasons = _castList<String>(obj['report_reasons'])
    ..selfText = obj['selftext']
    ..selfTextHtml = obj['selftext_html']
    ..sendReplies = obj['send_replies']
    ..subredditFullId = obj['subreddit_id']
    ..subredditName = obj['subreddit']
    ..subredditSubscriberCount = _parseNum(obj['subreddit_subscribers'])
    ..suggestedSort = obj['suggested_sort']
    ..subredditVisibility = obj['subreddit_type']
    ..thumbnailUrl = _parseString(obj['thumbnail'], exclude: const ['default'])
    ..title = obj['title']
    ..url = obj['url']
    ..userReports = _castList<String>(obj['user_reports'])
    ..viewCount = _parseNum(obj['view_count'])
    ..whitelistStatus = obj['whitelist_status']
  );
}

Link decodeLink(String json) => buildLink(_decodeData(json));

Message buildMessage(Map obj) {
  obj = _extractData(obj);
  return Message((MessageBuilder b) => b
    ..id = obj["id"]
    ..created = _parseNum(obj['created'])
    ..createdUtc = _parseNum(obj["created_utc"])
    ..authorName = obj["author"]
    ..body = obj["body"]
    ..context = obj["context"]
    ..firstMessage = obj["first_message"]
    ..isLiked = obj["likes"]
    ..linkTitle = obj["link_title"]
    ..subredditName = obj["subreddit"]
    ..wasComment = obj["was_comment"]
  );
}

Message decodeMessage(String json) => buildMessage(_decodeData(json));

List<String> _parseThingIds(Map obj) {
  final list = List<String>();
  for (final child in obj["children"]) {
    list.add(child);
  }
  return list;
}

More buildMore(Map obj) {
  obj = _extractData(obj);
  return More((MoreBuilder b) => b
    ..id = obj["id"]
    ..count = _parseNum(obj["count"])
    ..thingIds = _parseThingIds(obj)
    ..depth = _parseNum(obj["depth"])
    ..parentFullId = obj["parent_id"]
  );
}

More decodeMore(String json) => buildMore(_decodeData(json));

Subreddit buildSubreddit(Map obj) {
  obj = _extractData(obj);
  return Subreddit((SubredditBuilder b) => b
    ..id = obj['id']
    ..created = _parseNum(obj['created'])
    ..createdUtc = _parseNum(obj["created_utc"])
    ..activeUserCount = _parseNum(obj["active_user_count"])
    ..bannerBackgroundColor = _parseColor(obj['banner_background_color'])
    ..bannerImageUrl = _parseString(obj['banner_background_image']) ?? _parseString(obj["banner_img"])
    ..description = obj["description"]
    ..displayName = obj["display_name"] ?? obj['name']
    ..headerImageUrl = _parseString(obj["header_img"])
    ..iconImageUrl = _parseString(obj['community_icon']) ?? _parseString(obj['icon_img'])
    ..isOver18 = obj["over_18"]
    ..isPublic = (obj['subreddit_type'] == 'public')
    ..keyColor = _parseColor(obj['key_color'])
    ..primaryColor = _parseColor(obj['primary_color'])
    ..publicDescription = obj['public_description']
    ..subscriberCount = _parseNum(obj['subscriber_count']) ?? _parseNum(obj["subscribers"])
    ..userIsModerator = obj['user_is_moderator']
    ..userIsSubscriber = obj['user_is_subscriber']
  );
}

Subreddit decodeSubreddit(String json) => buildSubreddit(_decodeData(json));

typedef T ThingBuilder<T extends Thing>(Map obj);

Listing<T> buildListing<T extends Thing>(Map obj, ThingBuilder<T> builder) {
  obj = _extractData(obj);
  final list = List<T>();
  final children = obj['children'] ?? obj['things'];
  for (final obj in children) {
    list.add(builder(obj));
  }
  return Listing<T>((b) => b
    ..nextId = obj['after']
    ..previousId = obj['before']
    ..things = list
  );
}

Thing buildThing(Map obj) {
  final kind = obj['kind'];
  switch (kind) {
    case 't1':
      return buildComment(obj);
    case 't2':
      return buildAccount(obj);
    case 't3':
      return buildLink(obj);
    case 't4':
      return buildMessage(obj);
    case 't5':
      return buildSubreddit(obj);
    case 'more':
      return buildMore(obj);
    default:
      throw new ArgumentError("Unhandled kind: $kind");
  }
}

Listing<Thing> decodeThingListing(String json) {
  return buildListing<Thing>(_decodeData(json), buildThing);
}

Thing buildCommentsTreeThing(Map obj) {
  final kind = obj['kind'];
  switch (kind) {
      case "t1": 
        return buildComment(obj);
      case "more":
        return buildMore(obj);
      default:
        throw new ArgumentError("Unhandled kind: $kind");
    }
}

Listing<Thing> decodeLinkComments(String json) {
  return buildListing<Thing>(_extractData(jsonDecode(json)[1]), buildCommentsTreeThing);
} 

Listing<Thing> decodeMoreComments(String json) {
  return buildListing<Thing>(_decodeData(json)['json'], buildCommentsTreeThing);
}

Listing<Account> decodeAccountListing(String json) {
  return buildListing<Account>(_decodeData(json), buildAccount);
}

Listing<Comment> decodeCommentListing(String json) {
  return buildListing<Comment>(_decodeData(json), buildComment);
}

Listing<Link> decodeLinkListing(String json) {
  return buildListing<Link>(_decodeData(json), buildLink);
}

Listing<Message> decodeMessageListing(String json) {
  return buildListing<Message>(_decodeData(json), buildMessage);
}

Listing<Subreddit> decodeSubredditListing(String json) {
  return buildListing<Subreddit>(_decodeData(json), buildSubreddit);
}

Iterable<Subreddit> decodeSubredditsList(String json) {
  final Map obj = jsonDecode(json);
  final List<Subreddit> list = List();
  for (final Map subredditObj in obj['subreddits']) {
    list.add(buildSubreddit(subredditObj));
  }
  return list;
}