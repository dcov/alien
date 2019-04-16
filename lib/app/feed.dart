import 'package:flutter/material.dart';

import 'base.dart';
import 'links_pagination.dart';
import 'param.dart';
import 'route.dart';

abstract class FeedModel extends RouteModel {

  String get feedName;

  String get description;

  IconData get iconData;

  LinksPaginationModel get links;

  Color get primaryColor;

  @override
  void didPush() {
    links.refresh();
  }

  @override
  void didPop() {
    links.dispose();
  }
}

class FeedTile extends StatelessWidget {

  FeedTile({
    Key key,
    @required this.model,
  }) : super(key: key);

  final FeedModel model;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(context, FeedPageRoute(model: model)),
      leading: CircleIcon(
        model.iconData,
        circleColor: model.primaryColor,
        iconColor: Theme.of(context).canvasColor,
      ),
      title: Body2Text(
        model.feedName,
      ),
      subtitle: Text(
        model.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class FeedPageRoute<T> extends ModelPageRoute<T, FeedModel> {

  FeedPageRoute({ RouteSettings settings, @required FeedModel model })
    : super(settings: settings, model: model);

  @override
  Widget build(BuildContext context) {
    return _FeedPage(model: model);
  }

  @override
  Widget buildBottomHandle(BuildContext context) {
    return _FeedPageBottomHandle(model: model);
  }
}

enum _FeedPageOption {
  refresh,
  sort,
}

class _FeedPage extends View<FeedModel> {

  _FeedPage({ Key key, @required FeedModel model })
    : super(key: key, model: model);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends ViewState<FeedModel, _FeedPage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 72.0),
          child: LinksPaginationScrollView(
            includeSubredditName: true,
            model: model.links,
          ),
        ),
        MediaPadding(
          child: MaterialToolbar(
            leading: BackButton(),
            middle: SubheadText(
              model.feedName,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}

class _FeedPageBottomHandle extends StatelessWidget {

  _FeedPageBottomHandle({
    Key key,
    @required this.model,
  }) : super(key: key);

  final FeedModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                showMenuAt<_FeedPageOption>(
                  context: context,
                  items: <PopupMenuEntry<_FeedPageOption>>[
                    PopupMenuItem(
                      value: _FeedPageOption.refresh,
                      child: Text('Refresh'),
                    ),
                    PopupMenuItem(
                      value: _FeedPageOption.sort,
                      child: Text('Sort'),
                    )
                  ]
                ).then((_FeedPageOption option) {
                  switch (option) {
                    case _FeedPageOption.refresh:
                      model.links.refresh();
                      break;
                    case _FeedPageOption.sort:
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