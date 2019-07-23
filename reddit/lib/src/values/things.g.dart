// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'things.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: avoid_returning_this
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_new
// ignore_for_file: test_types_in_equals

class _$Account extends Account {
  @override
  final int commentKarma;
  @override
  final bool hasMail;
  @override
  final bool hasModMail;
  @override
  final String iconImageUrl;
  @override
  final bool isFriend;
  @override
  final bool isGold;
  @override
  final bool isMod;
  @override
  final bool isOver18;
  @override
  final int linkKarma;
  @override
  final String username;
  @override
  final String id;
  @override
  final int created;
  @override
  final int createdUtc;

  factory _$Account([void updates(AccountBuilder b)]) =>
      (new AccountBuilder()..update(updates)).build();

  _$Account._(
      {this.commentKarma,
      this.hasMail,
      this.hasModMail,
      this.iconImageUrl,
      this.isFriend,
      this.isGold,
      this.isMod,
      this.isOver18,
      this.linkKarma,
      this.username,
      this.id,
      this.created,
      this.createdUtc})
      : super._();

  @override
  Account rebuild(void updates(AccountBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountBuilder toBuilder() => new AccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Account &&
        commentKarma == other.commentKarma &&
        hasMail == other.hasMail &&
        hasModMail == other.hasModMail &&
        iconImageUrl == other.iconImageUrl &&
        isFriend == other.isFriend &&
        isGold == other.isGold &&
        isMod == other.isMod &&
        isOver18 == other.isOver18 &&
        linkKarma == other.linkKarma &&
        username == other.username &&
        id == other.id &&
        created == other.created &&
        createdUtc == other.createdUtc;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(0,
                                                        commentKarma.hashCode),
                                                    hasMail.hashCode),
                                                hasModMail.hashCode),
                                            iconImageUrl.hashCode),
                                        isFriend.hashCode),
                                    isGold.hashCode),
                                isMod.hashCode),
                            isOver18.hashCode),
                        linkKarma.hashCode),
                    username.hashCode),
                id.hashCode),
            created.hashCode),
        createdUtc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Account')
          ..add('commentKarma', commentKarma)
          ..add('hasMail', hasMail)
          ..add('hasModMail', hasModMail)
          ..add('iconImageUrl', iconImageUrl)
          ..add('isFriend', isFriend)
          ..add('isGold', isGold)
          ..add('isMod', isMod)
          ..add('isOver18', isOver18)
          ..add('linkKarma', linkKarma)
          ..add('username', username)
          ..add('id', id)
          ..add('created', created)
          ..add('createdUtc', createdUtc))
        .toString();
  }
}

class AccountBuilder implements Builder<Account, AccountBuilder> {
  _$Account _$v;

  int _commentKarma;
  int get commentKarma => _$this._commentKarma;
  set commentKarma(int commentKarma) => _$this._commentKarma = commentKarma;

  bool _hasMail;
  bool get hasMail => _$this._hasMail;
  set hasMail(bool hasMail) => _$this._hasMail = hasMail;

  bool _hasModMail;
  bool get hasModMail => _$this._hasModMail;
  set hasModMail(bool hasModMail) => _$this._hasModMail = hasModMail;

  String _iconImageUrl;
  String get iconImageUrl => _$this._iconImageUrl;
  set iconImageUrl(String iconImageUrl) => _$this._iconImageUrl = iconImageUrl;

  bool _isFriend;
  bool get isFriend => _$this._isFriend;
  set isFriend(bool isFriend) => _$this._isFriend = isFriend;

  bool _isGold;
  bool get isGold => _$this._isGold;
  set isGold(bool isGold) => _$this._isGold = isGold;

  bool _isMod;
  bool get isMod => _$this._isMod;
  set isMod(bool isMod) => _$this._isMod = isMod;

  bool _isOver18;
  bool get isOver18 => _$this._isOver18;
  set isOver18(bool isOver18) => _$this._isOver18 = isOver18;

  int _linkKarma;
  int get linkKarma => _$this._linkKarma;
  set linkKarma(int linkKarma) => _$this._linkKarma = linkKarma;

  String _username;
  String get username => _$this._username;
  set username(String username) => _$this._username = username;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _created;
  int get created => _$this._created;
  set created(int created) => _$this._created = created;

  int _createdUtc;
  int get createdUtc => _$this._createdUtc;
  set createdUtc(int createdUtc) => _$this._createdUtc = createdUtc;

  AccountBuilder();

  AccountBuilder get _$this {
    if (_$v != null) {
      _commentKarma = _$v.commentKarma;
      _hasMail = _$v.hasMail;
      _hasModMail = _$v.hasModMail;
      _iconImageUrl = _$v.iconImageUrl;
      _isFriend = _$v.isFriend;
      _isGold = _$v.isGold;
      _isMod = _$v.isMod;
      _isOver18 = _$v.isOver18;
      _linkKarma = _$v.linkKarma;
      _username = _$v.username;
      _id = _$v.id;
      _created = _$v.created;
      _createdUtc = _$v.createdUtc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Account other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Account;
  }

  @override
  void update(void updates(AccountBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Account build() {
    final _$result = _$v ??
        new _$Account._(
            commentKarma: commentKarma,
            hasMail: hasMail,
            hasModMail: hasModMail,
            iconImageUrl: iconImageUrl,
            isFriend: isFriend,
            isGold: isGold,
            isMod: isMod,
            isOver18: isOver18,
            linkKarma: linkKarma,
            username: username,
            id: id,
            created: created,
            createdUtc: createdUtc);
    replace(_$result);
    return _$result;
  }
}

class _$Comment extends Comment {
  @override
  final int approvedAtUtc;
  @override
  final String approvedBy;
  @override
  final String authorName;
  @override
  final String authorFlairBackgroundColor;
  @override
  final String authorFlairCssClass;
  @override
  final String authorFlairTemplateId;
  @override
  final String authorFlairRichText;
  @override
  final String authorFlairText;
  @override
  final String authorFlairTextColor;
  @override
  final String authorFlairType;
  @override
  final String authorFullId;
  @override
  final int bannedAtUtc;
  @override
  final String bannedBy;
  @override
  final String body;
  @override
  final String bodyHtml;
  @override
  final bool canModPost;
  @override
  final String collapsedReason;
  @override
  final int controversialityScore;
  @override
  final int depth;
  @override
  final String distinguishment;
  @override
  final int editedUtc;
  @override
  final bool isCollapsed;
  @override
  final bool isNoFollow;
  @override
  final bool isStickied;
  @override
  final bool isSubmitter;
  @override
  final String linkFullId;
  @override
  final String modNote;
  @override
  final String modReasonBy;
  @override
  final String modReasonTitle;
  @override
  final Iterable<String> modReports;
  @override
  final String parentFullId;
  @override
  final String permalink;
  @override
  final String removalReason;
  @override
  final Iterable<Thing> replies;
  @override
  final int reportCount;
  @override
  final Iterable<String> reportReasons;
  @override
  final bool sendReplies;
  @override
  final String subredditFullId;
  @override
  final String subredditName;
  @override
  final String subredditVisibility;
  @override
  final Iterable<String> userReports;
  @override
  final String id;
  @override
  final int created;
  @override
  final int createdUtc;
  @override
  final int downvoteCount;
  @override
  final bool isLiked;
  @override
  final bool isScoreHidden;
  @override
  final int score;
  @override
  final int upvoteCount;
  @override
  final bool isArchived;
  @override
  final bool canGild;
  @override
  final int gildCount;
  @override
  final bool isSaved;

  factory _$Comment([void updates(CommentBuilder b)]) =>
      (new CommentBuilder()..update(updates)).build();

  _$Comment._(
      {this.approvedAtUtc,
      this.approvedBy,
      this.authorName,
      this.authorFlairBackgroundColor,
      this.authorFlairCssClass,
      this.authorFlairTemplateId,
      this.authorFlairRichText,
      this.authorFlairText,
      this.authorFlairTextColor,
      this.authorFlairType,
      this.authorFullId,
      this.bannedAtUtc,
      this.bannedBy,
      this.body,
      this.bodyHtml,
      this.canModPost,
      this.collapsedReason,
      this.controversialityScore,
      this.depth,
      this.distinguishment,
      this.editedUtc,
      this.isCollapsed,
      this.isNoFollow,
      this.isStickied,
      this.isSubmitter,
      this.linkFullId,
      this.modNote,
      this.modReasonBy,
      this.modReasonTitle,
      this.modReports,
      this.parentFullId,
      this.permalink,
      this.removalReason,
      this.replies,
      this.reportCount,
      this.reportReasons,
      this.sendReplies,
      this.subredditFullId,
      this.subredditName,
      this.subredditVisibility,
      this.userReports,
      this.id,
      this.created,
      this.createdUtc,
      this.downvoteCount,
      this.isLiked,
      this.isScoreHidden,
      this.score,
      this.upvoteCount,
      this.isArchived,
      this.canGild,
      this.gildCount,
      this.isSaved})
      : super._();

  @override
  Comment rebuild(void updates(CommentBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentBuilder toBuilder() => new CommentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Comment &&
        approvedAtUtc == other.approvedAtUtc &&
        approvedBy == other.approvedBy &&
        authorName == other.authorName &&
        authorFlairBackgroundColor == other.authorFlairBackgroundColor &&
        authorFlairCssClass == other.authorFlairCssClass &&
        authorFlairTemplateId == other.authorFlairTemplateId &&
        authorFlairRichText == other.authorFlairRichText &&
        authorFlairText == other.authorFlairText &&
        authorFlairTextColor == other.authorFlairTextColor &&
        authorFlairType == other.authorFlairType &&
        authorFullId == other.authorFullId &&
        bannedAtUtc == other.bannedAtUtc &&
        bannedBy == other.bannedBy &&
        body == other.body &&
        bodyHtml == other.bodyHtml &&
        canModPost == other.canModPost &&
        collapsedReason == other.collapsedReason &&
        controversialityScore == other.controversialityScore &&
        depth == other.depth &&
        distinguishment == other.distinguishment &&
        editedUtc == other.editedUtc &&
        isCollapsed == other.isCollapsed &&
        isNoFollow == other.isNoFollow &&
        isStickied == other.isStickied &&
        isSubmitter == other.isSubmitter &&
        linkFullId == other.linkFullId &&
        modNote == other.modNote &&
        modReasonBy == other.modReasonBy &&
        modReasonTitle == other.modReasonTitle &&
        modReports == other.modReports &&
        parentFullId == other.parentFullId &&
        permalink == other.permalink &&
        removalReason == other.removalReason &&
        replies == other.replies &&
        reportCount == other.reportCount &&
        reportReasons == other.reportReasons &&
        sendReplies == other.sendReplies &&
        subredditFullId == other.subredditFullId &&
        subredditName == other.subredditName &&
        subredditVisibility == other.subredditVisibility &&
        userReports == other.userReports &&
        id == other.id &&
        created == other.created &&
        createdUtc == other.createdUtc &&
        downvoteCount == other.downvoteCount &&
        isLiked == other.isLiked &&
        isScoreHidden == other.isScoreHidden &&
        score == other.score &&
        upvoteCount == other.upvoteCount &&
        isArchived == other.isArchived &&
        canGild == other.canGild &&
        gildCount == other.gildCount &&
        isSaved == other.isSaved;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc(0, approvedAtUtc.hashCode), approvedBy.hashCode), authorName.hashCode), authorFlairBackgroundColor.hashCode), authorFlairCssClass.hashCode), authorFlairTemplateId.hashCode), authorFlairRichText.hashCode), authorFlairText.hashCode), authorFlairTextColor.hashCode), authorFlairType.hashCode), authorFullId.hashCode), bannedAtUtc.hashCode), bannedBy.hashCode), body.hashCode), bodyHtml.hashCode), canModPost.hashCode), collapsedReason.hashCode), controversialityScore.hashCode), depth.hashCode), distinguishment.hashCode), editedUtc.hashCode), isCollapsed.hashCode), isNoFollow.hashCode), isStickied.hashCode), isSubmitter.hashCode), linkFullId.hashCode), modNote.hashCode), modReasonBy.hashCode), modReasonTitle.hashCode), modReports.hashCode), parentFullId.hashCode), permalink.hashCode), removalReason.hashCode), replies.hashCode),
                                                                                reportCount.hashCode),
                                                                            reportReasons.hashCode),
                                                                        sendReplies.hashCode),
                                                                    subredditFullId.hashCode),
                                                                subredditName.hashCode),
                                                            subredditVisibility.hashCode),
                                                        userReports.hashCode),
                                                    id.hashCode),
                                                created.hashCode),
                                            createdUtc.hashCode),
                                        downvoteCount.hashCode),
                                    isLiked.hashCode),
                                isScoreHidden.hashCode),
                            score.hashCode),
                        upvoteCount.hashCode),
                    isArchived.hashCode),
                canGild.hashCode),
            gildCount.hashCode),
        isSaved.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Comment')
          ..add('approvedAtUtc', approvedAtUtc)
          ..add('approvedBy', approvedBy)
          ..add('authorName', authorName)
          ..add('authorFlairBackgroundColor', authorFlairBackgroundColor)
          ..add('authorFlairCssClass', authorFlairCssClass)
          ..add('authorFlairTemplateId', authorFlairTemplateId)
          ..add('authorFlairRichText', authorFlairRichText)
          ..add('authorFlairText', authorFlairText)
          ..add('authorFlairTextColor', authorFlairTextColor)
          ..add('authorFlairType', authorFlairType)
          ..add('authorFullId', authorFullId)
          ..add('bannedAtUtc', bannedAtUtc)
          ..add('bannedBy', bannedBy)
          ..add('body', body)
          ..add('bodyHtml', bodyHtml)
          ..add('canModPost', canModPost)
          ..add('collapsedReason', collapsedReason)
          ..add('controversialityScore', controversialityScore)
          ..add('depth', depth)
          ..add('distinguishment', distinguishment)
          ..add('editedUtc', editedUtc)
          ..add('isCollapsed', isCollapsed)
          ..add('isNoFollow', isNoFollow)
          ..add('isStickied', isStickied)
          ..add('isSubmitter', isSubmitter)
          ..add('linkFullId', linkFullId)
          ..add('modNote', modNote)
          ..add('modReasonBy', modReasonBy)
          ..add('modReasonTitle', modReasonTitle)
          ..add('modReports', modReports)
          ..add('parentFullId', parentFullId)
          ..add('permalink', permalink)
          ..add('removalReason', removalReason)
          ..add('replies', replies)
          ..add('reportCount', reportCount)
          ..add('reportReasons', reportReasons)
          ..add('sendReplies', sendReplies)
          ..add('subredditFullId', subredditFullId)
          ..add('subredditName', subredditName)
          ..add('subredditVisibility', subredditVisibility)
          ..add('userReports', userReports)
          ..add('id', id)
          ..add('created', created)
          ..add('createdUtc', createdUtc)
          ..add('downvoteCount', downvoteCount)
          ..add('isLiked', isLiked)
          ..add('isScoreHidden', isScoreHidden)
          ..add('score', score)
          ..add('upvoteCount', upvoteCount)
          ..add('isArchived', isArchived)
          ..add('canGild', canGild)
          ..add('gildCount', gildCount)
          ..add('isSaved', isSaved))
        .toString();
  }
}

class CommentBuilder implements Builder<Comment, CommentBuilder> {
  _$Comment _$v;

  int _approvedAtUtc;
  int get approvedAtUtc => _$this._approvedAtUtc;
  set approvedAtUtc(int approvedAtUtc) => _$this._approvedAtUtc = approvedAtUtc;

  String _approvedBy;
  String get approvedBy => _$this._approvedBy;
  set approvedBy(String approvedBy) => _$this._approvedBy = approvedBy;

  String _authorName;
  String get authorName => _$this._authorName;
  set authorName(String authorName) => _$this._authorName = authorName;

  String _authorFlairBackgroundColor;
  String get authorFlairBackgroundColor => _$this._authorFlairBackgroundColor;
  set authorFlairBackgroundColor(String authorFlairBackgroundColor) =>
      _$this._authorFlairBackgroundColor = authorFlairBackgroundColor;

  String _authorFlairCssClass;
  String get authorFlairCssClass => _$this._authorFlairCssClass;
  set authorFlairCssClass(String authorFlairCssClass) =>
      _$this._authorFlairCssClass = authorFlairCssClass;

  String _authorFlairTemplateId;
  String get authorFlairTemplateId => _$this._authorFlairTemplateId;
  set authorFlairTemplateId(String authorFlairTemplateId) =>
      _$this._authorFlairTemplateId = authorFlairTemplateId;

  String _authorFlairRichText;
  String get authorFlairRichText => _$this._authorFlairRichText;
  set authorFlairRichText(String authorFlairRichText) =>
      _$this._authorFlairRichText = authorFlairRichText;

  String _authorFlairText;
  String get authorFlairText => _$this._authorFlairText;
  set authorFlairText(String authorFlairText) =>
      _$this._authorFlairText = authorFlairText;

  String _authorFlairTextColor;
  String get authorFlairTextColor => _$this._authorFlairTextColor;
  set authorFlairTextColor(String authorFlairTextColor) =>
      _$this._authorFlairTextColor = authorFlairTextColor;

  String _authorFlairType;
  String get authorFlairType => _$this._authorFlairType;
  set authorFlairType(String authorFlairType) =>
      _$this._authorFlairType = authorFlairType;

  String _authorFullId;
  String get authorFullId => _$this._authorFullId;
  set authorFullId(String authorFullId) => _$this._authorFullId = authorFullId;

  int _bannedAtUtc;
  int get bannedAtUtc => _$this._bannedAtUtc;
  set bannedAtUtc(int bannedAtUtc) => _$this._bannedAtUtc = bannedAtUtc;

  String _bannedBy;
  String get bannedBy => _$this._bannedBy;
  set bannedBy(String bannedBy) => _$this._bannedBy = bannedBy;

  String _body;
  String get body => _$this._body;
  set body(String body) => _$this._body = body;

  String _bodyHtml;
  String get bodyHtml => _$this._bodyHtml;
  set bodyHtml(String bodyHtml) => _$this._bodyHtml = bodyHtml;

  bool _canModPost;
  bool get canModPost => _$this._canModPost;
  set canModPost(bool canModPost) => _$this._canModPost = canModPost;

  String _collapsedReason;
  String get collapsedReason => _$this._collapsedReason;
  set collapsedReason(String collapsedReason) =>
      _$this._collapsedReason = collapsedReason;

  int _controversialityScore;
  int get controversialityScore => _$this._controversialityScore;
  set controversialityScore(int controversialityScore) =>
      _$this._controversialityScore = controversialityScore;

  int _depth;
  int get depth => _$this._depth;
  set depth(int depth) => _$this._depth = depth;

  String _distinguishment;
  String get distinguishment => _$this._distinguishment;
  set distinguishment(String distinguishment) =>
      _$this._distinguishment = distinguishment;

  int _editedUtc;
  int get editedUtc => _$this._editedUtc;
  set editedUtc(int editedUtc) => _$this._editedUtc = editedUtc;

  bool _isCollapsed;
  bool get isCollapsed => _$this._isCollapsed;
  set isCollapsed(bool isCollapsed) => _$this._isCollapsed = isCollapsed;

  bool _isNoFollow;
  bool get isNoFollow => _$this._isNoFollow;
  set isNoFollow(bool isNoFollow) => _$this._isNoFollow = isNoFollow;

  bool _isStickied;
  bool get isStickied => _$this._isStickied;
  set isStickied(bool isStickied) => _$this._isStickied = isStickied;

  bool _isSubmitter;
  bool get isSubmitter => _$this._isSubmitter;
  set isSubmitter(bool isSubmitter) => _$this._isSubmitter = isSubmitter;

  String _linkFullId;
  String get linkFullId => _$this._linkFullId;
  set linkFullId(String linkFullId) => _$this._linkFullId = linkFullId;

  String _modNote;
  String get modNote => _$this._modNote;
  set modNote(String modNote) => _$this._modNote = modNote;

  String _modReasonBy;
  String get modReasonBy => _$this._modReasonBy;
  set modReasonBy(String modReasonBy) => _$this._modReasonBy = modReasonBy;

  String _modReasonTitle;
  String get modReasonTitle => _$this._modReasonTitle;
  set modReasonTitle(String modReasonTitle) =>
      _$this._modReasonTitle = modReasonTitle;

  Iterable<String> _modReports;
  Iterable<String> get modReports => _$this._modReports;
  set modReports(Iterable<String> modReports) =>
      _$this._modReports = modReports;

  String _parentFullId;
  String get parentFullId => _$this._parentFullId;
  set parentFullId(String parentFullId) => _$this._parentFullId = parentFullId;

  String _permalink;
  String get permalink => _$this._permalink;
  set permalink(String permalink) => _$this._permalink = permalink;

  String _removalReason;
  String get removalReason => _$this._removalReason;
  set removalReason(String removalReason) =>
      _$this._removalReason = removalReason;

  Iterable<Thing> _replies;
  Iterable<Thing> get replies => _$this._replies;
  set replies(Iterable<Thing> replies) => _$this._replies = replies;

  int _reportCount;
  int get reportCount => _$this._reportCount;
  set reportCount(int reportCount) => _$this._reportCount = reportCount;

  Iterable<String> _reportReasons;
  Iterable<String> get reportReasons => _$this._reportReasons;
  set reportReasons(Iterable<String> reportReasons) =>
      _$this._reportReasons = reportReasons;

  bool _sendReplies;
  bool get sendReplies => _$this._sendReplies;
  set sendReplies(bool sendReplies) => _$this._sendReplies = sendReplies;

  String _subredditFullId;
  String get subredditFullId => _$this._subredditFullId;
  set subredditFullId(String subredditFullId) =>
      _$this._subredditFullId = subredditFullId;

  String _subredditName;
  String get subredditName => _$this._subredditName;
  set subredditName(String subredditName) =>
      _$this._subredditName = subredditName;

  String _subredditVisibility;
  String get subredditVisibility => _$this._subredditVisibility;
  set subredditVisibility(String subredditVisibility) =>
      _$this._subredditVisibility = subredditVisibility;

  Iterable<String> _userReports;
  Iterable<String> get userReports => _$this._userReports;
  set userReports(Iterable<String> userReports) =>
      _$this._userReports = userReports;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _created;
  int get created => _$this._created;
  set created(int created) => _$this._created = created;

  int _createdUtc;
  int get createdUtc => _$this._createdUtc;
  set createdUtc(int createdUtc) => _$this._createdUtc = createdUtc;

  int _downvoteCount;
  int get downvoteCount => _$this._downvoteCount;
  set downvoteCount(int downvoteCount) => _$this._downvoteCount = downvoteCount;

  bool _isLiked;
  bool get isLiked => _$this._isLiked;
  set isLiked(bool isLiked) => _$this._isLiked = isLiked;

  bool _isScoreHidden;
  bool get isScoreHidden => _$this._isScoreHidden;
  set isScoreHidden(bool isScoreHidden) =>
      _$this._isScoreHidden = isScoreHidden;

  int _score;
  int get score => _$this._score;
  set score(int score) => _$this._score = score;

  int _upvoteCount;
  int get upvoteCount => _$this._upvoteCount;
  set upvoteCount(int upvoteCount) => _$this._upvoteCount = upvoteCount;

  bool _isArchived;
  bool get isArchived => _$this._isArchived;
  set isArchived(bool isArchived) => _$this._isArchived = isArchived;

  bool _canGild;
  bool get canGild => _$this._canGild;
  set canGild(bool canGild) => _$this._canGild = canGild;

  int _gildCount;
  int get gildCount => _$this._gildCount;
  set gildCount(int gildCount) => _$this._gildCount = gildCount;

  bool _isSaved;
  bool get isSaved => _$this._isSaved;
  set isSaved(bool isSaved) => _$this._isSaved = isSaved;

  CommentBuilder();

  CommentBuilder get _$this {
    if (_$v != null) {
      _approvedAtUtc = _$v.approvedAtUtc;
      _approvedBy = _$v.approvedBy;
      _authorName = _$v.authorName;
      _authorFlairBackgroundColor = _$v.authorFlairBackgroundColor;
      _authorFlairCssClass = _$v.authorFlairCssClass;
      _authorFlairTemplateId = _$v.authorFlairTemplateId;
      _authorFlairRichText = _$v.authorFlairRichText;
      _authorFlairText = _$v.authorFlairText;
      _authorFlairTextColor = _$v.authorFlairTextColor;
      _authorFlairType = _$v.authorFlairType;
      _authorFullId = _$v.authorFullId;
      _bannedAtUtc = _$v.bannedAtUtc;
      _bannedBy = _$v.bannedBy;
      _body = _$v.body;
      _bodyHtml = _$v.bodyHtml;
      _canModPost = _$v.canModPost;
      _collapsedReason = _$v.collapsedReason;
      _controversialityScore = _$v.controversialityScore;
      _depth = _$v.depth;
      _distinguishment = _$v.distinguishment;
      _editedUtc = _$v.editedUtc;
      _isCollapsed = _$v.isCollapsed;
      _isNoFollow = _$v.isNoFollow;
      _isStickied = _$v.isStickied;
      _isSubmitter = _$v.isSubmitter;
      _linkFullId = _$v.linkFullId;
      _modNote = _$v.modNote;
      _modReasonBy = _$v.modReasonBy;
      _modReasonTitle = _$v.modReasonTitle;
      _modReports = _$v.modReports;
      _parentFullId = _$v.parentFullId;
      _permalink = _$v.permalink;
      _removalReason = _$v.removalReason;
      _replies = _$v.replies;
      _reportCount = _$v.reportCount;
      _reportReasons = _$v.reportReasons;
      _sendReplies = _$v.sendReplies;
      _subredditFullId = _$v.subredditFullId;
      _subredditName = _$v.subredditName;
      _subredditVisibility = _$v.subredditVisibility;
      _userReports = _$v.userReports;
      _id = _$v.id;
      _created = _$v.created;
      _createdUtc = _$v.createdUtc;
      _downvoteCount = _$v.downvoteCount;
      _isLiked = _$v.isLiked;
      _isScoreHidden = _$v.isScoreHidden;
      _score = _$v.score;
      _upvoteCount = _$v.upvoteCount;
      _isArchived = _$v.isArchived;
      _canGild = _$v.canGild;
      _gildCount = _$v.gildCount;
      _isSaved = _$v.isSaved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Comment other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Comment;
  }

  @override
  void update(void updates(CommentBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Comment build() {
    final _$result = _$v ??
        new _$Comment._(
            approvedAtUtc: approvedAtUtc,
            approvedBy: approvedBy,
            authorName: authorName,
            authorFlairBackgroundColor: authorFlairBackgroundColor,
            authorFlairCssClass: authorFlairCssClass,
            authorFlairTemplateId: authorFlairTemplateId,
            authorFlairRichText: authorFlairRichText,
            authorFlairText: authorFlairText,
            authorFlairTextColor: authorFlairTextColor,
            authorFlairType: authorFlairType,
            authorFullId: authorFullId,
            bannedAtUtc: bannedAtUtc,
            bannedBy: bannedBy,
            body: body,
            bodyHtml: bodyHtml,
            canModPost: canModPost,
            collapsedReason: collapsedReason,
            controversialityScore: controversialityScore,
            depth: depth,
            distinguishment: distinguishment,
            editedUtc: editedUtc,
            isCollapsed: isCollapsed,
            isNoFollow: isNoFollow,
            isStickied: isStickied,
            isSubmitter: isSubmitter,
            linkFullId: linkFullId,
            modNote: modNote,
            modReasonBy: modReasonBy,
            modReasonTitle: modReasonTitle,
            modReports: modReports,
            parentFullId: parentFullId,
            permalink: permalink,
            removalReason: removalReason,
            replies: replies,
            reportCount: reportCount,
            reportReasons: reportReasons,
            sendReplies: sendReplies,
            subredditFullId: subredditFullId,
            subredditName: subredditName,
            subredditVisibility: subredditVisibility,
            userReports: userReports,
            id: id,
            created: created,
            createdUtc: createdUtc,
            downvoteCount: downvoteCount,
            isLiked: isLiked,
            isScoreHidden: isScoreHidden,
            score: score,
            upvoteCount: upvoteCount,
            isArchived: isArchived,
            canGild: canGild,
            gildCount: gildCount,
            isSaved: isSaved);
    replace(_$result);
    return _$result;
  }
}

class _$Resolution extends Resolution {
  @override
  final String url;
  @override
  final int width;
  @override
  final int height;

  factory _$Resolution([void updates(ResolutionBuilder b)]) =>
      (new ResolutionBuilder()..update(updates)).build();

  _$Resolution._({this.url, this.width, this.height}) : super._();

  @override
  Resolution rebuild(void updates(ResolutionBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  ResolutionBuilder toBuilder() => new ResolutionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Resolution &&
        url == other.url &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, url.hashCode), width.hashCode), height.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Resolution')
          ..add('url', url)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class ResolutionBuilder implements Builder<Resolution, ResolutionBuilder> {
  _$Resolution _$v;

  String _url;
  String get url => _$this._url;
  set url(String url) => _$this._url = url;

  int _width;
  int get width => _$this._width;
  set width(int width) => _$this._width = width;

  int _height;
  int get height => _$this._height;
  set height(int height) => _$this._height = height;

  ResolutionBuilder();

  ResolutionBuilder get _$this {
    if (_$v != null) {
      _url = _$v.url;
      _width = _$v.width;
      _height = _$v.height;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Resolution other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Resolution;
  }

  @override
  void update(void updates(ResolutionBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Resolution build() {
    final _$result =
        _$v ?? new _$Resolution._(url: url, width: width, height: height);
    replace(_$result);
    return _$result;
  }
}

class _$Preview extends Preview {
  @override
  final bool enabled;
  @override
  final Iterable<Resolution> resolutions;

  factory _$Preview([void updates(PreviewBuilder b)]) =>
      (new PreviewBuilder()..update(updates)).build();

  _$Preview._({this.enabled, this.resolutions}) : super._();

  @override
  Preview rebuild(void updates(PreviewBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  PreviewBuilder toBuilder() => new PreviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Preview &&
        enabled == other.enabled &&
        resolutions == other.resolutions;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, enabled.hashCode), resolutions.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Preview')
          ..add('enabled', enabled)
          ..add('resolutions', resolutions))
        .toString();
  }
}

class PreviewBuilder implements Builder<Preview, PreviewBuilder> {
  _$Preview _$v;

  bool _enabled;
  bool get enabled => _$this._enabled;
  set enabled(bool enabled) => _$this._enabled = enabled;

  Iterable<Resolution> _resolutions;
  Iterable<Resolution> get resolutions => _$this._resolutions;
  set resolutions(Iterable<Resolution> resolutions) =>
      _$this._resolutions = resolutions;

  PreviewBuilder();

  PreviewBuilder get _$this {
    if (_$v != null) {
      _enabled = _$v.enabled;
      _resolutions = _$v.resolutions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Preview other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Preview;
  }

  @override
  void update(void updates(PreviewBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Preview build() {
    final _$result =
        _$v ?? new _$Preview._(enabled: enabled, resolutions: resolutions);
    replace(_$result);
    return _$result;
  }
}

class _$Link extends Link {
  @override
  final int approvedAtUtc;
  @override
  final String approvedBy;
  @override
  final String authorFlairBackgroundColor;
  @override
  final String authorFlairCssClass;
  @override
  final String authorFlairTemplateId;
  @override
  final String authorFlairRichText;
  @override
  final String authorFlairText;
  @override
  final String authorFlairTextColor;
  @override
  final String authorFullId;
  @override
  final String authorName;
  @override
  final int bannedAtUtc;
  @override
  final String bannedBy;
  @override
  final String categoryName;
  @override
  final bool canModPost;
  @override
  final int commentCount;
  @override
  final Iterable<String> contentCategories;
  @override
  final int crosspostCount;
  @override
  final String domainName;
  @override
  final Distinguishment distinguishment;
  @override
  final int editedUtc;
  @override
  final bool isClicked;
  @override
  final bool isContestMode;
  @override
  final bool isCrosspostable;
  @override
  final bool isHidden;
  @override
  final bool isLocked;
  @override
  final bool isMediaOnly;
  @override
  final bool isMeta;
  @override
  final bool isNoFollow;
  @override
  final bool isOriginalContent;
  @override
  final bool isOver18;
  @override
  final bool isPinned;
  @override
  final bool isRedditMediaDomain;
  @override
  final bool isSelf;
  @override
  final bool isSpoiler;
  @override
  final bool isStickied;
  @override
  final bool isQuarantined;
  @override
  final bool isVideo;
  @override
  final bool isVisited;
  @override
  final String linkFlairBackgroundColor;
  @override
  final String linkFlairCssClass;
  @override
  final String linkFlairTemplateId;
  @override
  final String linkFlairText;
  @override
  final String linkFlairTextColor;
  @override
  final String linkFlairType;
  @override
  final String modNote;
  @override
  final String modReasonBy;
  @override
  final String modReasonTitle;
  @override
  final Iterable<String> modReports;
  @override
  final String parentWhitelistStatus;
  @override
  final String permalink;
  @override
  final String postHint;
  @override
  final Preview preview;
  @override
  final String removalReason;
  @override
  final int reportCount;
  @override
  final Iterable<String> reportReasons;
  @override
  final String selfText;
  @override
  final String selfTextHtml;
  @override
  final bool sendReplies;
  @override
  final String subredditFullId;
  @override
  final String subredditName;
  @override
  final int subredditSubscriberCount;
  @override
  final String suggestedSort;
  @override
  final String subredditVisibility;
  @override
  final String thumbnailUrl;
  @override
  final String title;
  @override
  final String url;
  @override
  final Iterable<String> userReports;
  @override
  final int viewCount;
  @override
  final String whitelistStatus;
  @override
  final String id;
  @override
  final int created;
  @override
  final int createdUtc;
  @override
  final int downvoteCount;
  @override
  final bool isLiked;
  @override
  final bool isScoreHidden;
  @override
  final int score;
  @override
  final int upvoteCount;
  @override
  final bool isArchived;
  @override
  final bool canGild;
  @override
  final int gildCount;
  @override
  final bool isSaved;

  factory _$Link([void updates(LinkBuilder b)]) =>
      (new LinkBuilder()..update(updates)).build();

  _$Link._(
      {this.approvedAtUtc,
      this.approvedBy,
      this.authorFlairBackgroundColor,
      this.authorFlairCssClass,
      this.authorFlairTemplateId,
      this.authorFlairRichText,
      this.authorFlairText,
      this.authorFlairTextColor,
      this.authorFullId,
      this.authorName,
      this.bannedAtUtc,
      this.bannedBy,
      this.categoryName,
      this.canModPost,
      this.commentCount,
      this.contentCategories,
      this.crosspostCount,
      this.domainName,
      this.distinguishment,
      this.editedUtc,
      this.isClicked,
      this.isContestMode,
      this.isCrosspostable,
      this.isHidden,
      this.isLocked,
      this.isMediaOnly,
      this.isMeta,
      this.isNoFollow,
      this.isOriginalContent,
      this.isOver18,
      this.isPinned,
      this.isRedditMediaDomain,
      this.isSelf,
      this.isSpoiler,
      this.isStickied,
      this.isQuarantined,
      this.isVideo,
      this.isVisited,
      this.linkFlairBackgroundColor,
      this.linkFlairCssClass,
      this.linkFlairTemplateId,
      this.linkFlairText,
      this.linkFlairTextColor,
      this.linkFlairType,
      this.modNote,
      this.modReasonBy,
      this.modReasonTitle,
      this.modReports,
      this.parentWhitelistStatus,
      this.permalink,
      this.postHint,
      this.preview,
      this.removalReason,
      this.reportCount,
      this.reportReasons,
      this.selfText,
      this.selfTextHtml,
      this.sendReplies,
      this.subredditFullId,
      this.subredditName,
      this.subredditSubscriberCount,
      this.suggestedSort,
      this.subredditVisibility,
      this.thumbnailUrl,
      this.title,
      this.url,
      this.userReports,
      this.viewCount,
      this.whitelistStatus,
      this.id,
      this.created,
      this.createdUtc,
      this.downvoteCount,
      this.isLiked,
      this.isScoreHidden,
      this.score,
      this.upvoteCount,
      this.isArchived,
      this.canGild,
      this.gildCount,
      this.isSaved})
      : super._();

  @override
  Link rebuild(void updates(LinkBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  LinkBuilder toBuilder() => new LinkBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Link &&
        approvedAtUtc == other.approvedAtUtc &&
        approvedBy == other.approvedBy &&
        authorFlairBackgroundColor == other.authorFlairBackgroundColor &&
        authorFlairCssClass == other.authorFlairCssClass &&
        authorFlairTemplateId == other.authorFlairTemplateId &&
        authorFlairRichText == other.authorFlairRichText &&
        authorFlairText == other.authorFlairText &&
        authorFlairTextColor == other.authorFlairTextColor &&
        authorFullId == other.authorFullId &&
        authorName == other.authorName &&
        bannedAtUtc == other.bannedAtUtc &&
        bannedBy == other.bannedBy &&
        categoryName == other.categoryName &&
        canModPost == other.canModPost &&
        commentCount == other.commentCount &&
        contentCategories == other.contentCategories &&
        crosspostCount == other.crosspostCount &&
        domainName == other.domainName &&
        distinguishment == other.distinguishment &&
        editedUtc == other.editedUtc &&
        isClicked == other.isClicked &&
        isContestMode == other.isContestMode &&
        isCrosspostable == other.isCrosspostable &&
        isHidden == other.isHidden &&
        isLocked == other.isLocked &&
        isMediaOnly == other.isMediaOnly &&
        isMeta == other.isMeta &&
        isNoFollow == other.isNoFollow &&
        isOriginalContent == other.isOriginalContent &&
        isOver18 == other.isOver18 &&
        isPinned == other.isPinned &&
        isRedditMediaDomain == other.isRedditMediaDomain &&
        isSelf == other.isSelf &&
        isSpoiler == other.isSpoiler &&
        isStickied == other.isStickied &&
        isQuarantined == other.isQuarantined &&
        isVideo == other.isVideo &&
        isVisited == other.isVisited &&
        linkFlairBackgroundColor == other.linkFlairBackgroundColor &&
        linkFlairCssClass == other.linkFlairCssClass &&
        linkFlairTemplateId == other.linkFlairTemplateId &&
        linkFlairText == other.linkFlairText &&
        linkFlairTextColor == other.linkFlairTextColor &&
        linkFlairType == other.linkFlairType &&
        modNote == other.modNote &&
        modReasonBy == other.modReasonBy &&
        modReasonTitle == other.modReasonTitle &&
        modReports == other.modReports &&
        parentWhitelistStatus == other.parentWhitelistStatus &&
        permalink == other.permalink &&
        postHint == other.postHint &&
        preview == other.preview &&
        removalReason == other.removalReason &&
        reportCount == other.reportCount &&
        reportReasons == other.reportReasons &&
        selfText == other.selfText &&
        selfTextHtml == other.selfTextHtml &&
        sendReplies == other.sendReplies &&
        subredditFullId == other.subredditFullId &&
        subredditName == other.subredditName &&
        subredditSubscriberCount == other.subredditSubscriberCount &&
        suggestedSort == other.suggestedSort &&
        subredditVisibility == other.subredditVisibility &&
        thumbnailUrl == other.thumbnailUrl &&
        title == other.title &&
        url == other.url &&
        userReports == other.userReports &&
        viewCount == other.viewCount &&
        whitelistStatus == other.whitelistStatus &&
        id == other.id &&
        created == other.created &&
        createdUtc == other.createdUtc &&
        downvoteCount == other.downvoteCount &&
        isLiked == other.isLiked &&
        isScoreHidden == other.isScoreHidden &&
        score == other.score &&
        upvoteCount == other.upvoteCount &&
        isArchived == other.isArchived &&
        canGild == other.canGild &&
        gildCount == other.gildCount &&
        isSaved == other.isSaved;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc(0, approvedAtUtc.hashCode), approvedBy.hashCode), authorFlairBackgroundColor.hashCode), authorFlairCssClass.hashCode), authorFlairTemplateId.hashCode), authorFlairRichText.hashCode), authorFlairText.hashCode), authorFlairTextColor.hashCode), authorFullId.hashCode), authorName.hashCode), bannedAtUtc.hashCode), bannedBy.hashCode), categoryName.hashCode), canModPost.hashCode), commentCount.hashCode), contentCategories.hashCode), crosspostCount.hashCode), domainName.hashCode), distinguishment.hashCode), editedUtc.hashCode), isClicked.hashCode), isContestMode.hashCode), isCrosspostable.hashCode), isHidden.hashCode), isLocked.hashCode), isMediaOnly.hashCode), isMeta.hashCode), isNoFollow.hashCode), isOriginalContent.hashCode), isOver18.hashCode), isPinned.hashCode), isRedditMediaDomain.hashCode), isSelf.hashCode), isSpoiler.hashCode), isStickied.hashCode), isQuarantined.hashCode), isVideo.hashCode), isVisited.hashCode), linkFlairBackgroundColor.hashCode), linkFlairCssClass.hashCode), linkFlairTemplateId.hashCode), linkFlairText.hashCode), linkFlairTextColor.hashCode), linkFlairType.hashCode), modNote.hashCode), modReasonBy.hashCode), modReasonTitle.hashCode), modReports.hashCode), parentWhitelistStatus.hashCode), permalink.hashCode), postHint.hashCode), preview.hashCode), removalReason.hashCode), reportCount.hashCode), reportReasons.hashCode), selfText.hashCode), selfTextHtml.hashCode), sendReplies.hashCode), subredditFullId.hashCode), subredditName.hashCode), subredditSubscriberCount.hashCode), suggestedSort.hashCode),
                                                                                subredditVisibility.hashCode),
                                                                            thumbnailUrl.hashCode),
                                                                        title.hashCode),
                                                                    url.hashCode),
                                                                userReports.hashCode),
                                                            viewCount.hashCode),
                                                        whitelistStatus.hashCode),
                                                    id.hashCode),
                                                created.hashCode),
                                            createdUtc.hashCode),
                                        downvoteCount.hashCode),
                                    isLiked.hashCode),
                                isScoreHidden.hashCode),
                            score.hashCode),
                        upvoteCount.hashCode),
                    isArchived.hashCode),
                canGild.hashCode),
            gildCount.hashCode),
        isSaved.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Link')
          ..add('approvedAtUtc', approvedAtUtc)
          ..add('approvedBy', approvedBy)
          ..add('authorFlairBackgroundColor', authorFlairBackgroundColor)
          ..add('authorFlairCssClass', authorFlairCssClass)
          ..add('authorFlairTemplateId', authorFlairTemplateId)
          ..add('authorFlairRichText', authorFlairRichText)
          ..add('authorFlairText', authorFlairText)
          ..add('authorFlairTextColor', authorFlairTextColor)
          ..add('authorFullId', authorFullId)
          ..add('authorName', authorName)
          ..add('bannedAtUtc', bannedAtUtc)
          ..add('bannedBy', bannedBy)
          ..add('categoryName', categoryName)
          ..add('canModPost', canModPost)
          ..add('commentCount', commentCount)
          ..add('contentCategories', contentCategories)
          ..add('crosspostCount', crosspostCount)
          ..add('domainName', domainName)
          ..add('distinguishment', distinguishment)
          ..add('editedUtc', editedUtc)
          ..add('isClicked', isClicked)
          ..add('isContestMode', isContestMode)
          ..add('isCrosspostable', isCrosspostable)
          ..add('isHidden', isHidden)
          ..add('isLocked', isLocked)
          ..add('isMediaOnly', isMediaOnly)
          ..add('isMeta', isMeta)
          ..add('isNoFollow', isNoFollow)
          ..add('isOriginalContent', isOriginalContent)
          ..add('isOver18', isOver18)
          ..add('isPinned', isPinned)
          ..add('isRedditMediaDomain', isRedditMediaDomain)
          ..add('isSelf', isSelf)
          ..add('isSpoiler', isSpoiler)
          ..add('isStickied', isStickied)
          ..add('isQuarantined', isQuarantined)
          ..add('isVideo', isVideo)
          ..add('isVisited', isVisited)
          ..add('linkFlairBackgroundColor', linkFlairBackgroundColor)
          ..add('linkFlairCssClass', linkFlairCssClass)
          ..add('linkFlairTemplateId', linkFlairTemplateId)
          ..add('linkFlairText', linkFlairText)
          ..add('linkFlairTextColor', linkFlairTextColor)
          ..add('linkFlairType', linkFlairType)
          ..add('modNote', modNote)
          ..add('modReasonBy', modReasonBy)
          ..add('modReasonTitle', modReasonTitle)
          ..add('modReports', modReports)
          ..add('parentWhitelistStatus', parentWhitelistStatus)
          ..add('permalink', permalink)
          ..add('postHint', postHint)
          ..add('preview', preview)
          ..add('removalReason', removalReason)
          ..add('reportCount', reportCount)
          ..add('reportReasons', reportReasons)
          ..add('selfText', selfText)
          ..add('selfTextHtml', selfTextHtml)
          ..add('sendReplies', sendReplies)
          ..add('subredditFullId', subredditFullId)
          ..add('subredditName', subredditName)
          ..add('subredditSubscriberCount', subredditSubscriberCount)
          ..add('suggestedSort', suggestedSort)
          ..add('subredditVisibility', subredditVisibility)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('title', title)
          ..add('url', url)
          ..add('userReports', userReports)
          ..add('viewCount', viewCount)
          ..add('whitelistStatus', whitelistStatus)
          ..add('id', id)
          ..add('created', created)
          ..add('createdUtc', createdUtc)
          ..add('downvoteCount', downvoteCount)
          ..add('isLiked', isLiked)
          ..add('isScoreHidden', isScoreHidden)
          ..add('score', score)
          ..add('upvoteCount', upvoteCount)
          ..add('isArchived', isArchived)
          ..add('canGild', canGild)
          ..add('gildCount', gildCount)
          ..add('isSaved', isSaved))
        .toString();
  }
}

class LinkBuilder implements Builder<Link, LinkBuilder> {
  _$Link _$v;

  int _approvedAtUtc;
  int get approvedAtUtc => _$this._approvedAtUtc;
  set approvedAtUtc(int approvedAtUtc) => _$this._approvedAtUtc = approvedAtUtc;

  String _approvedBy;
  String get approvedBy => _$this._approvedBy;
  set approvedBy(String approvedBy) => _$this._approvedBy = approvedBy;

  String _authorFlairBackgroundColor;
  String get authorFlairBackgroundColor => _$this._authorFlairBackgroundColor;
  set authorFlairBackgroundColor(String authorFlairBackgroundColor) =>
      _$this._authorFlairBackgroundColor = authorFlairBackgroundColor;

  String _authorFlairCssClass;
  String get authorFlairCssClass => _$this._authorFlairCssClass;
  set authorFlairCssClass(String authorFlairCssClass) =>
      _$this._authorFlairCssClass = authorFlairCssClass;

  String _authorFlairTemplateId;
  String get authorFlairTemplateId => _$this._authorFlairTemplateId;
  set authorFlairTemplateId(String authorFlairTemplateId) =>
      _$this._authorFlairTemplateId = authorFlairTemplateId;

  String _authorFlairRichText;
  String get authorFlairRichText => _$this._authorFlairRichText;
  set authorFlairRichText(String authorFlairRichText) =>
      _$this._authorFlairRichText = authorFlairRichText;

  String _authorFlairText;
  String get authorFlairText => _$this._authorFlairText;
  set authorFlairText(String authorFlairText) =>
      _$this._authorFlairText = authorFlairText;

  String _authorFlairTextColor;
  String get authorFlairTextColor => _$this._authorFlairTextColor;
  set authorFlairTextColor(String authorFlairTextColor) =>
      _$this._authorFlairTextColor = authorFlairTextColor;

  String _authorFullId;
  String get authorFullId => _$this._authorFullId;
  set authorFullId(String authorFullId) => _$this._authorFullId = authorFullId;

  String _authorName;
  String get authorName => _$this._authorName;
  set authorName(String authorName) => _$this._authorName = authorName;

  int _bannedAtUtc;
  int get bannedAtUtc => _$this._bannedAtUtc;
  set bannedAtUtc(int bannedAtUtc) => _$this._bannedAtUtc = bannedAtUtc;

  String _bannedBy;
  String get bannedBy => _$this._bannedBy;
  set bannedBy(String bannedBy) => _$this._bannedBy = bannedBy;

  String _categoryName;
  String get categoryName => _$this._categoryName;
  set categoryName(String categoryName) => _$this._categoryName = categoryName;

  bool _canModPost;
  bool get canModPost => _$this._canModPost;
  set canModPost(bool canModPost) => _$this._canModPost = canModPost;

  int _commentCount;
  int get commentCount => _$this._commentCount;
  set commentCount(int commentCount) => _$this._commentCount = commentCount;

  Iterable<String> _contentCategories;
  Iterable<String> get contentCategories => _$this._contentCategories;
  set contentCategories(Iterable<String> contentCategories) =>
      _$this._contentCategories = contentCategories;

  int _crosspostCount;
  int get crosspostCount => _$this._crosspostCount;
  set crosspostCount(int crosspostCount) =>
      _$this._crosspostCount = crosspostCount;

  String _domainName;
  String get domainName => _$this._domainName;
  set domainName(String domainName) => _$this._domainName = domainName;

  Distinguishment _distinguishment;
  Distinguishment get distinguishment => _$this._distinguishment;
  set distinguishment(Distinguishment distinguishment) =>
      _$this._distinguishment = distinguishment;

  int _editedUtc;
  int get editedUtc => _$this._editedUtc;
  set editedUtc(int editedUtc) => _$this._editedUtc = editedUtc;

  bool _isClicked;
  bool get isClicked => _$this._isClicked;
  set isClicked(bool isClicked) => _$this._isClicked = isClicked;

  bool _isContestMode;
  bool get isContestMode => _$this._isContestMode;
  set isContestMode(bool isContestMode) =>
      _$this._isContestMode = isContestMode;

  bool _isCrosspostable;
  bool get isCrosspostable => _$this._isCrosspostable;
  set isCrosspostable(bool isCrosspostable) =>
      _$this._isCrosspostable = isCrosspostable;

  bool _isHidden;
  bool get isHidden => _$this._isHidden;
  set isHidden(bool isHidden) => _$this._isHidden = isHidden;

  bool _isLocked;
  bool get isLocked => _$this._isLocked;
  set isLocked(bool isLocked) => _$this._isLocked = isLocked;

  bool _isMediaOnly;
  bool get isMediaOnly => _$this._isMediaOnly;
  set isMediaOnly(bool isMediaOnly) => _$this._isMediaOnly = isMediaOnly;

  bool _isMeta;
  bool get isMeta => _$this._isMeta;
  set isMeta(bool isMeta) => _$this._isMeta = isMeta;

  bool _isNoFollow;
  bool get isNoFollow => _$this._isNoFollow;
  set isNoFollow(bool isNoFollow) => _$this._isNoFollow = isNoFollow;

  bool _isOriginalContent;
  bool get isOriginalContent => _$this._isOriginalContent;
  set isOriginalContent(bool isOriginalContent) =>
      _$this._isOriginalContent = isOriginalContent;

  bool _isOver18;
  bool get isOver18 => _$this._isOver18;
  set isOver18(bool isOver18) => _$this._isOver18 = isOver18;

  bool _isPinned;
  bool get isPinned => _$this._isPinned;
  set isPinned(bool isPinned) => _$this._isPinned = isPinned;

  bool _isRedditMediaDomain;
  bool get isRedditMediaDomain => _$this._isRedditMediaDomain;
  set isRedditMediaDomain(bool isRedditMediaDomain) =>
      _$this._isRedditMediaDomain = isRedditMediaDomain;

  bool _isSelf;
  bool get isSelf => _$this._isSelf;
  set isSelf(bool isSelf) => _$this._isSelf = isSelf;

  bool _isSpoiler;
  bool get isSpoiler => _$this._isSpoiler;
  set isSpoiler(bool isSpoiler) => _$this._isSpoiler = isSpoiler;

  bool _isStickied;
  bool get isStickied => _$this._isStickied;
  set isStickied(bool isStickied) => _$this._isStickied = isStickied;

  bool _isQuarantined;
  bool get isQuarantined => _$this._isQuarantined;
  set isQuarantined(bool isQuarantined) =>
      _$this._isQuarantined = isQuarantined;

  bool _isVideo;
  bool get isVideo => _$this._isVideo;
  set isVideo(bool isVideo) => _$this._isVideo = isVideo;

  bool _isVisited;
  bool get isVisited => _$this._isVisited;
  set isVisited(bool isVisited) => _$this._isVisited = isVisited;

  String _linkFlairBackgroundColor;
  String get linkFlairBackgroundColor => _$this._linkFlairBackgroundColor;
  set linkFlairBackgroundColor(String linkFlairBackgroundColor) =>
      _$this._linkFlairBackgroundColor = linkFlairBackgroundColor;

  String _linkFlairCssClass;
  String get linkFlairCssClass => _$this._linkFlairCssClass;
  set linkFlairCssClass(String linkFlairCssClass) =>
      _$this._linkFlairCssClass = linkFlairCssClass;

  String _linkFlairTemplateId;
  String get linkFlairTemplateId => _$this._linkFlairTemplateId;
  set linkFlairTemplateId(String linkFlairTemplateId) =>
      _$this._linkFlairTemplateId = linkFlairTemplateId;

  String _linkFlairText;
  String get linkFlairText => _$this._linkFlairText;
  set linkFlairText(String linkFlairText) =>
      _$this._linkFlairText = linkFlairText;

  String _linkFlairTextColor;
  String get linkFlairTextColor => _$this._linkFlairTextColor;
  set linkFlairTextColor(String linkFlairTextColor) =>
      _$this._linkFlairTextColor = linkFlairTextColor;

  String _linkFlairType;
  String get linkFlairType => _$this._linkFlairType;
  set linkFlairType(String linkFlairType) =>
      _$this._linkFlairType = linkFlairType;

  String _modNote;
  String get modNote => _$this._modNote;
  set modNote(String modNote) => _$this._modNote = modNote;

  String _modReasonBy;
  String get modReasonBy => _$this._modReasonBy;
  set modReasonBy(String modReasonBy) => _$this._modReasonBy = modReasonBy;

  String _modReasonTitle;
  String get modReasonTitle => _$this._modReasonTitle;
  set modReasonTitle(String modReasonTitle) =>
      _$this._modReasonTitle = modReasonTitle;

  Iterable<String> _modReports;
  Iterable<String> get modReports => _$this._modReports;
  set modReports(Iterable<String> modReports) =>
      _$this._modReports = modReports;

  String _parentWhitelistStatus;
  String get parentWhitelistStatus => _$this._parentWhitelistStatus;
  set parentWhitelistStatus(String parentWhitelistStatus) =>
      _$this._parentWhitelistStatus = parentWhitelistStatus;

  String _permalink;
  String get permalink => _$this._permalink;
  set permalink(String permalink) => _$this._permalink = permalink;

  String _postHint;
  String get postHint => _$this._postHint;
  set postHint(String postHint) => _$this._postHint = postHint;

  PreviewBuilder _preview;
  PreviewBuilder get preview => _$this._preview ??= new PreviewBuilder();
  set preview(PreviewBuilder preview) => _$this._preview = preview;

  String _removalReason;
  String get removalReason => _$this._removalReason;
  set removalReason(String removalReason) =>
      _$this._removalReason = removalReason;

  int _reportCount;
  int get reportCount => _$this._reportCount;
  set reportCount(int reportCount) => _$this._reportCount = reportCount;

  Iterable<String> _reportReasons;
  Iterable<String> get reportReasons => _$this._reportReasons;
  set reportReasons(Iterable<String> reportReasons) =>
      _$this._reportReasons = reportReasons;

  String _selfText;
  String get selfText => _$this._selfText;
  set selfText(String selfText) => _$this._selfText = selfText;

  String _selfTextHtml;
  String get selfTextHtml => _$this._selfTextHtml;
  set selfTextHtml(String selfTextHtml) => _$this._selfTextHtml = selfTextHtml;

  bool _sendReplies;
  bool get sendReplies => _$this._sendReplies;
  set sendReplies(bool sendReplies) => _$this._sendReplies = sendReplies;

  String _subredditFullId;
  String get subredditFullId => _$this._subredditFullId;
  set subredditFullId(String subredditFullId) =>
      _$this._subredditFullId = subredditFullId;

  String _subredditName;
  String get subredditName => _$this._subredditName;
  set subredditName(String subredditName) =>
      _$this._subredditName = subredditName;

  int _subredditSubscriberCount;
  int get subredditSubscriberCount => _$this._subredditSubscriberCount;
  set subredditSubscriberCount(int subredditSubscriberCount) =>
      _$this._subredditSubscriberCount = subredditSubscriberCount;

  String _suggestedSort;
  String get suggestedSort => _$this._suggestedSort;
  set suggestedSort(String suggestedSort) =>
      _$this._suggestedSort = suggestedSort;

  String _subredditVisibility;
  String get subredditVisibility => _$this._subredditVisibility;
  set subredditVisibility(String subredditVisibility) =>
      _$this._subredditVisibility = subredditVisibility;

  String _thumbnailUrl;
  String get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String _title;
  String get title => _$this._title;
  set title(String title) => _$this._title = title;

  String _url;
  String get url => _$this._url;
  set url(String url) => _$this._url = url;

  Iterable<String> _userReports;
  Iterable<String> get userReports => _$this._userReports;
  set userReports(Iterable<String> userReports) =>
      _$this._userReports = userReports;

  int _viewCount;
  int get viewCount => _$this._viewCount;
  set viewCount(int viewCount) => _$this._viewCount = viewCount;

  String _whitelistStatus;
  String get whitelistStatus => _$this._whitelistStatus;
  set whitelistStatus(String whitelistStatus) =>
      _$this._whitelistStatus = whitelistStatus;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _created;
  int get created => _$this._created;
  set created(int created) => _$this._created = created;

  int _createdUtc;
  int get createdUtc => _$this._createdUtc;
  set createdUtc(int createdUtc) => _$this._createdUtc = createdUtc;

  int _downvoteCount;
  int get downvoteCount => _$this._downvoteCount;
  set downvoteCount(int downvoteCount) => _$this._downvoteCount = downvoteCount;

  bool _isLiked;
  bool get isLiked => _$this._isLiked;
  set isLiked(bool isLiked) => _$this._isLiked = isLiked;

  bool _isScoreHidden;
  bool get isScoreHidden => _$this._isScoreHidden;
  set isScoreHidden(bool isScoreHidden) =>
      _$this._isScoreHidden = isScoreHidden;

  int _score;
  int get score => _$this._score;
  set score(int score) => _$this._score = score;

  int _upvoteCount;
  int get upvoteCount => _$this._upvoteCount;
  set upvoteCount(int upvoteCount) => _$this._upvoteCount = upvoteCount;

  bool _isArchived;
  bool get isArchived => _$this._isArchived;
  set isArchived(bool isArchived) => _$this._isArchived = isArchived;

  bool _canGild;
  bool get canGild => _$this._canGild;
  set canGild(bool canGild) => _$this._canGild = canGild;

  int _gildCount;
  int get gildCount => _$this._gildCount;
  set gildCount(int gildCount) => _$this._gildCount = gildCount;

  bool _isSaved;
  bool get isSaved => _$this._isSaved;
  set isSaved(bool isSaved) => _$this._isSaved = isSaved;

  LinkBuilder();

  LinkBuilder get _$this {
    if (_$v != null) {
      _approvedAtUtc = _$v.approvedAtUtc;
      _approvedBy = _$v.approvedBy;
      _authorFlairBackgroundColor = _$v.authorFlairBackgroundColor;
      _authorFlairCssClass = _$v.authorFlairCssClass;
      _authorFlairTemplateId = _$v.authorFlairTemplateId;
      _authorFlairRichText = _$v.authorFlairRichText;
      _authorFlairText = _$v.authorFlairText;
      _authorFlairTextColor = _$v.authorFlairTextColor;
      _authorFullId = _$v.authorFullId;
      _authorName = _$v.authorName;
      _bannedAtUtc = _$v.bannedAtUtc;
      _bannedBy = _$v.bannedBy;
      _categoryName = _$v.categoryName;
      _canModPost = _$v.canModPost;
      _commentCount = _$v.commentCount;
      _contentCategories = _$v.contentCategories;
      _crosspostCount = _$v.crosspostCount;
      _domainName = _$v.domainName;
      _distinguishment = _$v.distinguishment;
      _editedUtc = _$v.editedUtc;
      _isClicked = _$v.isClicked;
      _isContestMode = _$v.isContestMode;
      _isCrosspostable = _$v.isCrosspostable;
      _isHidden = _$v.isHidden;
      _isLocked = _$v.isLocked;
      _isMediaOnly = _$v.isMediaOnly;
      _isMeta = _$v.isMeta;
      _isNoFollow = _$v.isNoFollow;
      _isOriginalContent = _$v.isOriginalContent;
      _isOver18 = _$v.isOver18;
      _isPinned = _$v.isPinned;
      _isRedditMediaDomain = _$v.isRedditMediaDomain;
      _isSelf = _$v.isSelf;
      _isSpoiler = _$v.isSpoiler;
      _isStickied = _$v.isStickied;
      _isQuarantined = _$v.isQuarantined;
      _isVideo = _$v.isVideo;
      _isVisited = _$v.isVisited;
      _linkFlairBackgroundColor = _$v.linkFlairBackgroundColor;
      _linkFlairCssClass = _$v.linkFlairCssClass;
      _linkFlairTemplateId = _$v.linkFlairTemplateId;
      _linkFlairText = _$v.linkFlairText;
      _linkFlairTextColor = _$v.linkFlairTextColor;
      _linkFlairType = _$v.linkFlairType;
      _modNote = _$v.modNote;
      _modReasonBy = _$v.modReasonBy;
      _modReasonTitle = _$v.modReasonTitle;
      _modReports = _$v.modReports;
      _parentWhitelistStatus = _$v.parentWhitelistStatus;
      _permalink = _$v.permalink;
      _postHint = _$v.postHint;
      _preview = _$v.preview?.toBuilder();
      _removalReason = _$v.removalReason;
      _reportCount = _$v.reportCount;
      _reportReasons = _$v.reportReasons;
      _selfText = _$v.selfText;
      _selfTextHtml = _$v.selfTextHtml;
      _sendReplies = _$v.sendReplies;
      _subredditFullId = _$v.subredditFullId;
      _subredditName = _$v.subredditName;
      _subredditSubscriberCount = _$v.subredditSubscriberCount;
      _suggestedSort = _$v.suggestedSort;
      _subredditVisibility = _$v.subredditVisibility;
      _thumbnailUrl = _$v.thumbnailUrl;
      _title = _$v.title;
      _url = _$v.url;
      _userReports = _$v.userReports;
      _viewCount = _$v.viewCount;
      _whitelistStatus = _$v.whitelistStatus;
      _id = _$v.id;
      _created = _$v.created;
      _createdUtc = _$v.createdUtc;
      _downvoteCount = _$v.downvoteCount;
      _isLiked = _$v.isLiked;
      _isScoreHidden = _$v.isScoreHidden;
      _score = _$v.score;
      _upvoteCount = _$v.upvoteCount;
      _isArchived = _$v.isArchived;
      _canGild = _$v.canGild;
      _gildCount = _$v.gildCount;
      _isSaved = _$v.isSaved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Link other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Link;
  }

  @override
  void update(void updates(LinkBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Link build() {
    _$Link _$result;
    try {
      _$result = _$v ??
          new _$Link._(
              approvedAtUtc: approvedAtUtc,
              approvedBy: approvedBy,
              authorFlairBackgroundColor: authorFlairBackgroundColor,
              authorFlairCssClass: authorFlairCssClass,
              authorFlairTemplateId: authorFlairTemplateId,
              authorFlairRichText: authorFlairRichText,
              authorFlairText: authorFlairText,
              authorFlairTextColor: authorFlairTextColor,
              authorFullId: authorFullId,
              authorName: authorName,
              bannedAtUtc: bannedAtUtc,
              bannedBy: bannedBy,
              categoryName: categoryName,
              canModPost: canModPost,
              commentCount: commentCount,
              contentCategories: contentCategories,
              crosspostCount: crosspostCount,
              domainName: domainName,
              distinguishment: distinguishment,
              editedUtc: editedUtc,
              isClicked: isClicked,
              isContestMode: isContestMode,
              isCrosspostable: isCrosspostable,
              isHidden: isHidden,
              isLocked: isLocked,
              isMediaOnly: isMediaOnly,
              isMeta: isMeta,
              isNoFollow: isNoFollow,
              isOriginalContent: isOriginalContent,
              isOver18: isOver18,
              isPinned: isPinned,
              isRedditMediaDomain: isRedditMediaDomain,
              isSelf: isSelf,
              isSpoiler: isSpoiler,
              isStickied: isStickied,
              isQuarantined: isQuarantined,
              isVideo: isVideo,
              isVisited: isVisited,
              linkFlairBackgroundColor: linkFlairBackgroundColor,
              linkFlairCssClass: linkFlairCssClass,
              linkFlairTemplateId: linkFlairTemplateId,
              linkFlairText: linkFlairText,
              linkFlairTextColor: linkFlairTextColor,
              linkFlairType: linkFlairType,
              modNote: modNote,
              modReasonBy: modReasonBy,
              modReasonTitle: modReasonTitle,
              modReports: modReports,
              parentWhitelistStatus: parentWhitelistStatus,
              permalink: permalink,
              postHint: postHint,
              preview: _preview?.build(),
              removalReason: removalReason,
              reportCount: reportCount,
              reportReasons: reportReasons,
              selfText: selfText,
              selfTextHtml: selfTextHtml,
              sendReplies: sendReplies,
              subredditFullId: subredditFullId,
              subredditName: subredditName,
              subredditSubscriberCount: subredditSubscriberCount,
              suggestedSort: suggestedSort,
              subredditVisibility: subredditVisibility,
              thumbnailUrl: thumbnailUrl,
              title: title,
              url: url,
              userReports: userReports,
              viewCount: viewCount,
              whitelistStatus: whitelistStatus,
              id: id,
              created: created,
              createdUtc: createdUtc,
              downvoteCount: downvoteCount,
              isLiked: isLiked,
              isScoreHidden: isScoreHidden,
              score: score,
              upvoteCount: upvoteCount,
              isArchived: isArchived,
              canGild: canGild,
              gildCount: gildCount,
              isSaved: isSaved);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'preview';
        _preview?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Link', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$Message extends Message {
  @override
  final String authorName;
  @override
  final String body;
  @override
  final String context;
  @override
  final String firstMessage;
  @override
  final bool isLiked;
  @override
  final String linkTitle;
  @override
  final String subredditName;
  @override
  final bool wasComment;
  @override
  final String id;
  @override
  final int created;
  @override
  final int createdUtc;

  factory _$Message([void updates(MessageBuilder b)]) =>
      (new MessageBuilder()..update(updates)).build();

  _$Message._(
      {this.authorName,
      this.body,
      this.context,
      this.firstMessage,
      this.isLiked,
      this.linkTitle,
      this.subredditName,
      this.wasComment,
      this.id,
      this.created,
      this.createdUtc})
      : super._();

  @override
  Message rebuild(void updates(MessageBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageBuilder toBuilder() => new MessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Message &&
        authorName == other.authorName &&
        body == other.body &&
        context == other.context &&
        firstMessage == other.firstMessage &&
        isLiked == other.isLiked &&
        linkTitle == other.linkTitle &&
        subredditName == other.subredditName &&
        wasComment == other.wasComment &&
        id == other.id &&
        created == other.created &&
        createdUtc == other.createdUtc;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc($jc(0, authorName.hashCode),
                                            body.hashCode),
                                        context.hashCode),
                                    firstMessage.hashCode),
                                isLiked.hashCode),
                            linkTitle.hashCode),
                        subredditName.hashCode),
                    wasComment.hashCode),
                id.hashCode),
            created.hashCode),
        createdUtc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Message')
          ..add('authorName', authorName)
          ..add('body', body)
          ..add('context', context)
          ..add('firstMessage', firstMessage)
          ..add('isLiked', isLiked)
          ..add('linkTitle', linkTitle)
          ..add('subredditName', subredditName)
          ..add('wasComment', wasComment)
          ..add('id', id)
          ..add('created', created)
          ..add('createdUtc', createdUtc))
        .toString();
  }
}

class MessageBuilder implements Builder<Message, MessageBuilder> {
  _$Message _$v;

  String _authorName;
  String get authorName => _$this._authorName;
  set authorName(String authorName) => _$this._authorName = authorName;

  String _body;
  String get body => _$this._body;
  set body(String body) => _$this._body = body;

  String _context;
  String get context => _$this._context;
  set context(String context) => _$this._context = context;

  String _firstMessage;
  String get firstMessage => _$this._firstMessage;
  set firstMessage(String firstMessage) => _$this._firstMessage = firstMessage;

  bool _isLiked;
  bool get isLiked => _$this._isLiked;
  set isLiked(bool isLiked) => _$this._isLiked = isLiked;

  String _linkTitle;
  String get linkTitle => _$this._linkTitle;
  set linkTitle(String linkTitle) => _$this._linkTitle = linkTitle;

  String _subredditName;
  String get subredditName => _$this._subredditName;
  set subredditName(String subredditName) =>
      _$this._subredditName = subredditName;

  bool _wasComment;
  bool get wasComment => _$this._wasComment;
  set wasComment(bool wasComment) => _$this._wasComment = wasComment;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _created;
  int get created => _$this._created;
  set created(int created) => _$this._created = created;

  int _createdUtc;
  int get createdUtc => _$this._createdUtc;
  set createdUtc(int createdUtc) => _$this._createdUtc = createdUtc;

  MessageBuilder();

  MessageBuilder get _$this {
    if (_$v != null) {
      _authorName = _$v.authorName;
      _body = _$v.body;
      _context = _$v.context;
      _firstMessage = _$v.firstMessage;
      _isLiked = _$v.isLiked;
      _linkTitle = _$v.linkTitle;
      _subredditName = _$v.subredditName;
      _wasComment = _$v.wasComment;
      _id = _$v.id;
      _created = _$v.created;
      _createdUtc = _$v.createdUtc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Message other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Message;
  }

  @override
  void update(void updates(MessageBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Message build() {
    final _$result = _$v ??
        new _$Message._(
            authorName: authorName,
            body: body,
            context: context,
            firstMessage: firstMessage,
            isLiked: isLiked,
            linkTitle: linkTitle,
            subredditName: subredditName,
            wasComment: wasComment,
            id: id,
            created: created,
            createdUtc: createdUtc);
    replace(_$result);
    return _$result;
  }
}

class _$More extends More {
  @override
  final int count;
  @override
  final Iterable<String> thingIds;
  @override
  final int depth;
  @override
  final String parentFullId;
  @override
  final String id;

  factory _$More([void updates(MoreBuilder b)]) =>
      (new MoreBuilder()..update(updates)).build();

  _$More._({this.count, this.thingIds, this.depth, this.parentFullId, this.id})
      : super._();

  @override
  More rebuild(void updates(MoreBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  MoreBuilder toBuilder() => new MoreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is More &&
        count == other.count &&
        thingIds == other.thingIds &&
        depth == other.depth &&
        parentFullId == other.parentFullId &&
        id == other.id;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, count.hashCode), thingIds.hashCode), depth.hashCode),
            parentFullId.hashCode),
        id.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('More')
          ..add('count', count)
          ..add('thingIds', thingIds)
          ..add('depth', depth)
          ..add('parentFullId', parentFullId)
          ..add('id', id))
        .toString();
  }
}

class MoreBuilder implements Builder<More, MoreBuilder> {
  _$More _$v;

  int _count;
  int get count => _$this._count;
  set count(int count) => _$this._count = count;

  Iterable<String> _thingIds;
  Iterable<String> get thingIds => _$this._thingIds;
  set thingIds(Iterable<String> thingIds) => _$this._thingIds = thingIds;

  int _depth;
  int get depth => _$this._depth;
  set depth(int depth) => _$this._depth = depth;

  String _parentFullId;
  String get parentFullId => _$this._parentFullId;
  set parentFullId(String parentFullId) => _$this._parentFullId = parentFullId;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  MoreBuilder();

  MoreBuilder get _$this {
    if (_$v != null) {
      _count = _$v.count;
      _thingIds = _$v.thingIds;
      _depth = _$v.depth;
      _parentFullId = _$v.parentFullId;
      _id = _$v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(More other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$More;
  }

  @override
  void update(void updates(MoreBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$More build() {
    final _$result = _$v ??
        new _$More._(
            count: count,
            thingIds: thingIds,
            depth: depth,
            parentFullId: parentFullId,
            id: id);
    replace(_$result);
    return _$result;
  }
}

class _$Subreddit extends Subreddit {
  @override
  final int activeUserCount;
  @override
  final int bannerBackgroundColor;
  @override
  final String bannerImageUrl;
  @override
  final String description;
  @override
  final String displayName;
  @override
  final String headerImageUrl;
  @override
  final String iconImageUrl;
  @override
  final bool isPublic;
  @override
  final bool isOver18;
  @override
  final int keyColor;
  @override
  final int primaryColor;
  @override
  final String publicDescription;
  @override
  final int subscriberCount;
  @override
  final bool userIsModerator;
  @override
  final bool userIsSubscriber;
  @override
  final String id;
  @override
  final int created;
  @override
  final int createdUtc;

  factory _$Subreddit([void updates(SubredditBuilder b)]) =>
      (new SubredditBuilder()..update(updates)).build();

  _$Subreddit._(
      {this.activeUserCount,
      this.bannerBackgroundColor,
      this.bannerImageUrl,
      this.description,
      this.displayName,
      this.headerImageUrl,
      this.iconImageUrl,
      this.isPublic,
      this.isOver18,
      this.keyColor,
      this.primaryColor,
      this.publicDescription,
      this.subscriberCount,
      this.userIsModerator,
      this.userIsSubscriber,
      this.id,
      this.created,
      this.createdUtc})
      : super._();

  @override
  Subreddit rebuild(void updates(SubredditBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  SubredditBuilder toBuilder() => new SubredditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Subreddit &&
        activeUserCount == other.activeUserCount &&
        bannerBackgroundColor == other.bannerBackgroundColor &&
        bannerImageUrl == other.bannerImageUrl &&
        description == other.description &&
        displayName == other.displayName &&
        headerImageUrl == other.headerImageUrl &&
        iconImageUrl == other.iconImageUrl &&
        isPublic == other.isPublic &&
        isOver18 == other.isOver18 &&
        keyColor == other.keyColor &&
        primaryColor == other.primaryColor &&
        publicDescription == other.publicDescription &&
        subscriberCount == other.subscriberCount &&
        userIsModerator == other.userIsModerator &&
        userIsSubscriber == other.userIsSubscriber &&
        id == other.id &&
        created == other.created &&
        createdUtc == other.createdUtc;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            0,
                                                                            activeUserCount
                                                                                .hashCode),
                                                                        bannerBackgroundColor
                                                                            .hashCode),
                                                                    bannerImageUrl
                                                                        .hashCode),
                                                                description
                                                                    .hashCode),
                                                            displayName
                                                                .hashCode),
                                                        headerImageUrl
                                                            .hashCode),
                                                    iconImageUrl.hashCode),
                                                isPublic.hashCode),
                                            isOver18.hashCode),
                                        keyColor.hashCode),
                                    primaryColor.hashCode),
                                publicDescription.hashCode),
                            subscriberCount.hashCode),
                        userIsModerator.hashCode),
                    userIsSubscriber.hashCode),
                id.hashCode),
            created.hashCode),
        createdUtc.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Subreddit')
          ..add('activeUserCount', activeUserCount)
          ..add('bannerBackgroundColor', bannerBackgroundColor)
          ..add('bannerImageUrl', bannerImageUrl)
          ..add('description', description)
          ..add('displayName', displayName)
          ..add('headerImageUrl', headerImageUrl)
          ..add('iconImageUrl', iconImageUrl)
          ..add('isPublic', isPublic)
          ..add('isOver18', isOver18)
          ..add('keyColor', keyColor)
          ..add('primaryColor', primaryColor)
          ..add('publicDescription', publicDescription)
          ..add('subscriberCount', subscriberCount)
          ..add('userIsModerator', userIsModerator)
          ..add('userIsSubscriber', userIsSubscriber)
          ..add('id', id)
          ..add('created', created)
          ..add('createdUtc', createdUtc))
        .toString();
  }
}

class SubredditBuilder implements Builder<Subreddit, SubredditBuilder> {
  _$Subreddit _$v;

  int _activeUserCount;
  int get activeUserCount => _$this._activeUserCount;
  set activeUserCount(int activeUserCount) =>
      _$this._activeUserCount = activeUserCount;

  int _bannerBackgroundColor;
  int get bannerBackgroundColor => _$this._bannerBackgroundColor;
  set bannerBackgroundColor(int bannerBackgroundColor) =>
      _$this._bannerBackgroundColor = bannerBackgroundColor;

  String _bannerImageUrl;
  String get bannerImageUrl => _$this._bannerImageUrl;
  set bannerImageUrl(String bannerImageUrl) =>
      _$this._bannerImageUrl = bannerImageUrl;

  String _description;
  String get description => _$this._description;
  set description(String description) => _$this._description = description;

  String _displayName;
  String get displayName => _$this._displayName;
  set displayName(String displayName) => _$this._displayName = displayName;

  String _headerImageUrl;
  String get headerImageUrl => _$this._headerImageUrl;
  set headerImageUrl(String headerImageUrl) =>
      _$this._headerImageUrl = headerImageUrl;

  String _iconImageUrl;
  String get iconImageUrl => _$this._iconImageUrl;
  set iconImageUrl(String iconImageUrl) => _$this._iconImageUrl = iconImageUrl;

  bool _isPublic;
  bool get isPublic => _$this._isPublic;
  set isPublic(bool isPublic) => _$this._isPublic = isPublic;

  bool _isOver18;
  bool get isOver18 => _$this._isOver18;
  set isOver18(bool isOver18) => _$this._isOver18 = isOver18;

  int _keyColor;
  int get keyColor => _$this._keyColor;
  set keyColor(int keyColor) => _$this._keyColor = keyColor;

  int _primaryColor;
  int get primaryColor => _$this._primaryColor;
  set primaryColor(int primaryColor) => _$this._primaryColor = primaryColor;

  String _publicDescription;
  String get publicDescription => _$this._publicDescription;
  set publicDescription(String publicDescription) =>
      _$this._publicDescription = publicDescription;

  int _subscriberCount;
  int get subscriberCount => _$this._subscriberCount;
  set subscriberCount(int subscriberCount) =>
      _$this._subscriberCount = subscriberCount;

  bool _userIsModerator;
  bool get userIsModerator => _$this._userIsModerator;
  set userIsModerator(bool userIsModerator) =>
      _$this._userIsModerator = userIsModerator;

  bool _userIsSubscriber;
  bool get userIsSubscriber => _$this._userIsSubscriber;
  set userIsSubscriber(bool userIsSubscriber) =>
      _$this._userIsSubscriber = userIsSubscriber;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  int _created;
  int get created => _$this._created;
  set created(int created) => _$this._created = created;

  int _createdUtc;
  int get createdUtc => _$this._createdUtc;
  set createdUtc(int createdUtc) => _$this._createdUtc = createdUtc;

  SubredditBuilder();

  SubredditBuilder get _$this {
    if (_$v != null) {
      _activeUserCount = _$v.activeUserCount;
      _bannerBackgroundColor = _$v.bannerBackgroundColor;
      _bannerImageUrl = _$v.bannerImageUrl;
      _description = _$v.description;
      _displayName = _$v.displayName;
      _headerImageUrl = _$v.headerImageUrl;
      _iconImageUrl = _$v.iconImageUrl;
      _isPublic = _$v.isPublic;
      _isOver18 = _$v.isOver18;
      _keyColor = _$v.keyColor;
      _primaryColor = _$v.primaryColor;
      _publicDescription = _$v.publicDescription;
      _subscriberCount = _$v.subscriberCount;
      _userIsModerator = _$v.userIsModerator;
      _userIsSubscriber = _$v.userIsSubscriber;
      _id = _$v.id;
      _created = _$v.created;
      _createdUtc = _$v.createdUtc;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Subreddit other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Subreddit;
  }

  @override
  void update(void updates(SubredditBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Subreddit build() {
    final _$result = _$v ??
        new _$Subreddit._(
            activeUserCount: activeUserCount,
            bannerBackgroundColor: bannerBackgroundColor,
            bannerImageUrl: bannerImageUrl,
            description: description,
            displayName: displayName,
            headerImageUrl: headerImageUrl,
            iconImageUrl: iconImageUrl,
            isPublic: isPublic,
            isOver18: isOver18,
            keyColor: keyColor,
            primaryColor: primaryColor,
            publicDescription: publicDescription,
            subscriberCount: subscriberCount,
            userIsModerator: userIsModerator,
            userIsSubscriber: userIsSubscriber,
            id: id,
            created: created,
            createdUtc: createdUtc);
    replace(_$result);
    return _$result;
  }
}

class _$Listing<T extends Thing> extends Listing<T> {
  @override
  final String nextId;
  @override
  final String previousId;
  @override
  final Iterable<T> things;

  factory _$Listing([void updates(ListingBuilder<T> b)]) =>
      (new ListingBuilder<T>()..update(updates)).build();

  _$Listing._({this.nextId, this.previousId, this.things}) : super._() {
    if (T == dynamic) {
      throw new BuiltValueMissingGenericsError('Listing', 'T');
    }
  }

  @override
  Listing<T> rebuild(void updates(ListingBuilder<T> b)) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingBuilder<T> toBuilder() => new ListingBuilder<T>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Listing &&
        nextId == other.nextId &&
        previousId == other.previousId &&
        things == other.things;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc(0, nextId.hashCode), previousId.hashCode), things.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Listing')
          ..add('nextId', nextId)
          ..add('previousId', previousId)
          ..add('things', things))
        .toString();
  }
}

class ListingBuilder<T extends Thing>
    implements Builder<Listing<T>, ListingBuilder<T>> {
  _$Listing<T> _$v;

  String _nextId;
  String get nextId => _$this._nextId;
  set nextId(String nextId) => _$this._nextId = nextId;

  String _previousId;
  String get previousId => _$this._previousId;
  set previousId(String previousId) => _$this._previousId = previousId;

  Iterable<T> _things;
  Iterable<T> get things => _$this._things;
  set things(Iterable<T> things) => _$this._things = things;

  ListingBuilder();

  ListingBuilder<T> get _$this {
    if (_$v != null) {
      _nextId = _$v.nextId;
      _previousId = _$v.previousId;
      _things = _$v.things;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Listing<T> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Listing<T>;
  }

  @override
  void update(void updates(ListingBuilder<T> b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Listing<T> build() {
    final _$result = _$v ??
        new _$Listing<T>._(
            nextId: nextId, previousId: previousId, things: things);
    replace(_$result);
    return _$result;
  }
}
