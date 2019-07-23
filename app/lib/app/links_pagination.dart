import 'package:reddit/values.dart';
import 'package:flutter/widgets.dart';

import 'link.dart';
import 'pagination.dart';
import 'param.dart';

class LinksPaginationModelSideEffects {

  const LinksPaginationModelSideEffects();

  LinkModel createLinkModel(Link link) => LinkModel(link);
}

abstract class LinksPaginationModel extends PaginationModel {

  LinksPaginationModel([ this._sideEffects = const LinksPaginationModelSideEffects() ]);

  ParamModel get sort;

  final LinksPaginationModelSideEffects _sideEffects;

  @override
  LinkModel createThing(Link thing) => _sideEffects.createLinkModel(thing);
}

class LinksPaginationScrollView extends PaginationScrollView {

  LinksPaginationScrollView({
    Key key,
    @required this.includeSubredditName,
    @required LinksPaginationModel model 
  }) : super(key: key, model: model);

  final bool includeSubredditName;

  @override
  Widget buildChild(BuildContext context, LinkModel childModel) {
    return LinkTile(
      layout: LinkTileLayout.compact,
      includeSubredditName: includeSubredditName,
      model: childModel
    );
  }
}