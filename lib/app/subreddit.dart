import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'links_pagination.dart';
import 'param.dart';
import 'route.dart';
import 'subreddit_links.dart';
import 'thing.dart';

class SubredditModelSideEffects {

  const SubredditModelSideEffects();

  SubredditLinksModel createSubredditLinksModel(String subredditName) {
    return SubredditLinksModel(subredditName);
  }
}

class SubredditModel extends RouteModel with ThingModelMixin {
  
  SubredditModel(
    Subreddit thing, [
    SubredditModelSideEffects sideEffects = const SubredditModelSideEffects()
  ]) : links = sideEffects.createSubredditLinksModel(thing.displayName) {
    _activeUserCount = thing.activeUserCount;
    _bannerBackgroundColor = thing.bannerBackgroundColor;
    _bannerImageUrl = thing.bannerImageUrl;
    _createdUtc = thing.createdUtc;
    _description = thing.description;
    _displayName = thing.displayName;
    _headerImageUrl = thing.headerImageUrl;
    _iconImageUrl = thing.iconImageUrl;
    _isPublic = thing.isPublic;
    _isOver18 = thing.isOver18;
    _isSubscriber = thing.userIsSubscriber;
    _keyColor = thing.keyColor;
    _primaryColor = thing.primaryColor != null ? Color(thing.primaryColor) : null;
    _subscriberCount = thing.subscriberCount;
    initThingModel(thing);
  }

  int get activeUserCount => _activeUserCount;
  int _activeUserCount;

  int get bannerBackgroundColor => _bannerBackgroundColor;
  int _bannerBackgroundColor;

  String get bannerImageUrl => _bannerImageUrl;
  String _bannerImageUrl;

  int get createdUtc => _createdUtc;
  int _createdUtc;

  String get description => _description;
  String _description;

  String get displayName => _displayName;
  String _displayName;

  String get headerImageUrl => _headerImageUrl;
  String _headerImageUrl;

  String get iconImageUrl => _iconImageUrl;
  String _iconImageUrl;

  bool get isPublic => _isPublic;
  bool _isPublic;

  bool get isOver18 => _isOver18;
  bool _isOver18;

  bool get isSubscriber => _isSubscriber;
  bool _isSubscriber;

  int get keyColor => _keyColor;
  int _keyColor;

  final SubredditLinksModel links;

  Color get primaryColor => _primaryColor;
  Color _primaryColor;

  int get subscriberCount => _subscriberCount;
  int _subscriberCount;

  @override
  void didPush() {
    links.refresh();
  }

  @override
  void didPop() {
    links.dispose();
  }

  @override
  void didMatchThing(Thing thing) {
  }
}

class SubredditTile extends StatelessWidget {

  SubredditTile({ Key key, @required this.model })
    : super(key: key);

  final SubredditModel model;
  
  Widget build(BuildContext context) {
    return ListItem(
      onTap: () => Navigator.push(context, SubredditPageRoute(model: model)),
      icon: Icon(
        AlienIcons.subreddit,
        color: Colors.blueGrey,
      ),
      title: Body2Text(model.displayName)
    ); 
  }
}

class SubredditPageRoute<T> extends ModelPageRoute<T, SubredditModel> {

  SubredditPageRoute({ RouteSettings settings, SubredditModel model })
    : super(settings: settings, model: model);

  @override
  Widget build(BuildContext context) {
    return _SubredditPage(model: model);
  }

  @override
  Widget buildBottomHandle(BuildContext context) {
    return _SubredditPageBottomHandle(model: model);
  }
}

enum _SubredditPageOption {
  refresh,
  sort,
}

class _SubredditPage extends View<SubredditModel> {

  _SubredditPage({ Key key, @required SubredditModel model })
    : super(key: key, model: model);

  @override
  SubredditPageState createState() => SubredditPageState();
}

class SubredditPageState extends ViewState<SubredditModel, _SubredditPage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 72.0),
          child: LinksPaginationScrollView(
            includeSubredditName: false,
            model: model.links
          ),
        ),
        MediaPadding(
          child: MaterialToolbar(
            leading: BackButton(),
            middle: SubheadText(
              model.displayName,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubredditPageBottomHandle extends StatelessWidget {

  _SubredditPageBottomHandle({ Key key, @required this.model })
    : super(key: key);

  final SubredditModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                showMenuAt<_SubredditPageOption>(
                  context: context,
                  items: <PopupMenuEntry<_SubredditPageOption>>[
                    PopupMenuItem(
                      value: _SubredditPageOption.refresh,
                      child: Text('Refresh'),
                    ),
                    PopupMenuItem(
                      value: _SubredditPageOption.sort,
                      child: Text('Sort'),
                    )
                  ]
                ).then((_SubredditPageOption option) {
                  switch (option) {
                    case _SubredditPageOption.refresh:
                      model.links.refresh();
                      break;
                    case _SubredditPageOption.sort:
                      showParamMenu(
                        context: context,
                        model: model.links.sort
                      );
                  }
                });
              },
              icon: Icon(Icons.more_vert),
            );
          },
        )
      ],
    );
  }
}