import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'link_comments.dart';
import 'media.dart';
import 'param.dart';
import 'route.dart';
import 'saveable.dart';
import 'snudown.dart';
import 'thing.dart';
import 'votable.dart';

class LinkModelSideEffects {

  const LinkModelSideEffects();

  LinkCommentsModel createLinkCommentsModel(
    String fullLinkId,
    String permalink,
    CommentsSort suggestedSort
  ) {
    return LinkCommentsModel(
      fullLinkId,
      permalink,
      suggestedSort
    );
  }

  MediaModel createMediaModel(
    String source,
    String title,
    String thumbnail,
    MediaType type
  ) {
    return MediaModel(
      source,
      title,
      thumbnail,
      true,
      type
    );
  }

  SnudownModel createSnudownModel(String data) {
    return SnudownModel(data);
  }
}

class LinkModel extends RouteModel with ThingModelMixin, VotableModelMixin, SaveableModelMixin {

  LinkModel(Link thing, [ this._sideEffects = const LinkModelSideEffects() ])
    : comments = _sideEffects.createLinkCommentsModel(
        thing.fullId,
        thing.permalink,
        CommentsSort.best
      ) {
    _authorFlairText = thing.authorFlairText;
    _authorName = thing.authorName;
    _commentCount = thing.commentCount;
    _createdUtc = thing.createdUtc;
    _domainName = thing.domainName;
    _editedUtc = thing.editedUtc;
    _isOver18 = thing.isOver18;
    _isSelf = thing.isSelf;
    _isVisited = thing.isVisited;
    _preview = thing.preview;
    _subredditName = thing.subredditName;
    _title = thing.title;
    _url = thing.url;
    _permalink = thing.permalink;

    if (thing.selfText != null && thing.selfText.isNotEmpty) {
      _selfText = Optional.of(_sideEffects.createSnudownModel(thing.selfText));
    } else {
      _selfText = Optional.absent();
    }

    if (!thing.isSelf) {
      final String source = thing.url;

      String thumbnail = thing.thumbnailUrl
        ?? thing.preview?.resolutions?.firstWhere((_) => true, orElse: () => null)?.url;
      
      _media = Optional.of(_sideEffects.createMediaModel(source, thing.title, thumbnail, null));
    } else {
      _media = Optional.absent();
    }

    initThingModel(thing);
    initVotableModel(thing);
    initSaveableModel(thing);
  }

  String get authorFlairText => _authorFlairText;
  String _authorFlairText;

  String get authorName => _authorName;
  String _authorName;

  int get commentCount => _commentCount;
  int _commentCount;

  final LinkCommentsModel comments;

  int get createdUtc => _createdUtc;
  int _createdUtc;

  String get domainName => _domainName;
  String _domainName;

  int get editedUtc => _editedUtc;
  int _editedUtc;

  bool get isOver18 => _isOver18;
  bool _isOver18;

  bool get isSelf => _isSelf;
  bool _isSelf;

  bool get isVisited => _isVisited;
  bool _isVisited;

  Optional<MediaModel> get media => _media;
  Optional<MediaModel> _media;

  String get permalink => _permalink;
  String _permalink;

  Preview get preview => _preview;
  Preview _preview;

  Optional<SnudownModel> get selfText => _selfText;
  Optional<SnudownModel> _selfText;

  String get subredditName => _subredditName;
  String _subredditName;

  String get title => _title;
  String _title;

  String get url => _url;
  String _url;

  final LinkModelSideEffects _sideEffects;

  @override
  void didPush() {
    comments.refresh();
  }

  @override
  void didPop() {
    comments.dispose();
  }

  @override
  void didMatchThing(Link thing) {
    super.didMatchThing(thing);
  }
}

enum LinkTileLayout {
  compact
}

class LinkTile extends StatelessWidget {

  LinkTile({
    Key key,
    @required this.layout,
    @required this.includeSubredditName,
    this.accentColor,
    @required this.model,
    this.disableCommentsNavigation = false,
  }) : super(key: key);

  final LinkTileLayout layout;
  final bool includeSubredditName;
  final Color accentColor;
  final LinkModel model;
  final bool disableCommentsNavigation;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case LinkTileLayout.compact:
        return _buildCompactLayout(
          context: context,
          showSubreddit: includeSubredditName,
          accentColor: accentColor,
        );
    }
    return null;
  }

  Widget _buildCompactLayout({
    BuildContext context,
    bool showSubreddit,
    Color accentColor,
  }) {

    Widget thumbnail = const EmptyBox();
    model.media.ifPresent((MediaModel mediaModel) {
      thumbnail = Padding(
        padding: Insets.halfLeft,
        child: Material(
          child: InkWell(
            onTap: () => showMedia(context: context, model: mediaModel),
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)
                )
              ),
              child: SizedBox(
                width: 70,
                height: 60,
                child: MediaThumbnail(
                  accentColor: accentColor,
                  model: mediaModel,
                )
              )
            )
          )
        )
      );
    });

    List<Widget> metaRow = showSubreddit
      ? <Widget>[
          CaptionText('r/${model.subredditName}'),
        ]
      : List<Widget>();

    return MaterialContainer(
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context)
        )
      ),
      child: InkWell(
        onTap: disableCommentsNavigation
          ? null
          : () => Navigator.push(context, LinkPageRoute(model: model)),
        child: Padding(
          padding: Insets.fullAll,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Body1Text(model.title),
                    Padding(
                      padding: Insets.quarterTop,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: CircleDivider.insert(metaRow..addAll(<Widget>[
                          CaptionText('u/${model.authorName}'),
                          CaptionText(formatElapsedUtc(model.createdUtc)),
                        ]))
                      )
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: CircleDivider.insert(<Widget>[
                        ValueBuilder(
                          valueGetter: () => model.isLiked,
                          listenable: model,
                          builder: (BuildContext context, bool isLiked, _) {
                            return CaptionText(
                            '${formatCount(model.score)} points',
                            color: isLiked == true? Colors.deepOrange :
                                  isLiked == false ? Colors.indigoAccent : null
                            );
                          }
                        ),
                        CaptionText('${formatCount(model.commentCount)} comments')
                      ]),
                    )
                  ]
                )
              ),
              thumbnail
            ],
          ),
        )
      )
    );
  }
}

class LinkPageRoute<T> extends ModelPageRoute<T, LinkModel> {

  LinkPageRoute({ RouteSettings settings, @required LinkModel model })
    : super(settings: settings, model: model);

  @override
  Widget build(BuildContext context) {
    return _LinkPage(model: model);
  }

  @override
  Widget buildBottomHandle(BuildContext context) {
    return _LinkPageBottomHandle(model: model);
  }
}

enum _LinkPageOption {
  refresh,
  sort
}

class _LinkPage extends View<LinkModel> {

  _LinkPage({ Key key, @required LinkModel model })
    : super(key: key, model: model);

  @override
  _LinkPageState createState() => _LinkPageState();
}

class _LinkPageState extends ViewState<LinkModel, _LinkPage> {

  Widget _buildHeading(BuildContext context) {
    final List<Widget> children = <Widget>[
      LinkTile(
        layout: LinkTileLayout.compact,
        includeSubredditName: false,
        model: model,
        disableCommentsNavigation: true,
      )
    ];
    model.selfText.ifPresent((SnudownModel snudownModel) {
      children.add(
        Material(
          type: MaterialType.card,
          child: Padding(
            padding: Insets.fullAll,
            child: Snudown(
              scrollable: false,
              model: snudownModel
            )
          )
        )
      );
    });
    return Column(
      children: children
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 72.0),
          child: LinkCommentsScrollView(
            heading: _buildHeading(context),
            model: model.comments
          )
        ),
        Padding(
          padding: EdgeInsets.only(top: 24.0),
          child: MaterialToolbar(
            leading: BackButton(),
            middle: SubheadText(
              model.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}

class _LinkPageBottomHandle extends StatelessWidget {

  _LinkPageBottomHandle({ Key key, @required this.model })
    : super(key: key);

  final LinkModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                showMenuAt<_LinkPageOption>(
                  context: context,
                  items: <PopupMenuEntry<_LinkPageOption>>[
                    PopupMenuItem(
                      value: _LinkPageOption.refresh,
                      child: Text('Refresh'),
                    ),
                    PopupMenuItem(
                      value: _LinkPageOption.sort,
                      child: Text('Sort'),
                    )
                  ]
                ).then((_LinkPageOption option) {
                  switch (option) {
                    case _LinkPageOption.refresh:
                      model.comments.refresh();
                      break;
                    case _LinkPageOption.sort:
                      showParamMenu(
                        context: context,
                        model: model.comments.sort
                      );
                  }
                });
              },
              icon: Icon(Icons.more_vert),
            );
          }
        )
      ],
    );
  }
}