import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart';

import '../models/post.dart';
import '../logic/saveable.dart';
import '../logic/voting.dart';
import '../widgets/circle_divider.dart';
import '../widgets/custom_render_object.dart';
import '../widgets/formatting.dart';
import '../widgets/options_bottom_sheet.dart';
import '../widgets/pressable.dart';
import '../widgets/slidable.dart';

import 'media_thumbnail.dart';
import 'post_page.dart';
import 'view_extensions.dart';
import 'votable_utils.dart';

void _showPostOptionsBottomSheet({
    @required BuildContext context,
    @required Post post
  }) {
  assert(context != null);
  assert(post != null);
  showOptionsBottomSheet(
    context: context,
    options: <Option>[
      if (context.userIsSignedIn)
        Option(
          onSelected: () {
            context.then(Then(ToggleSaved(saveable: post)));
          },
          title: post.isSaved ? 'Unsave' : 'Save',
          icon: post.isSaved ? Icons.save : Icons.save_outlined)
    ]);
}

enum _PostTileLayoutSlot {
  title,
  details,
  thumbnail
}

class _PostTileLayout extends CustomRenderObjectWidget {

  _PostTileLayout({
    Key key,
    @required Widget title,
    @required Widget details,
    Widget thumbnail
  }) : assert(title != null),
       assert(details != null),
       super(
         key: key,
         children: <dynamic, Widget>{
           _PostTileLayoutSlot.title : title,
           _PostTileLayoutSlot.details : details,
           if (thumbnail != null)
            _PostTileLayoutSlot.thumbnail : thumbnail
         });

  @override
  _RenderPostTileLayout createRenderObject(BuildContext context) => _RenderPostTileLayout();
}

class _RenderPostTileLayout extends RenderBox
    with CustomRenderObjectMixin<RenderBox>,
         CustomRenderBoxDefaultsMixin {

  @override
  List<dynamic> get hitTestOrdering => const <dynamic>[
    _PostTileLayoutSlot.thumbnail,
    _PostTileLayoutSlot.title,
    _PostTileLayoutSlot.details
  ];

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth);
    assert(hasChild(_PostTileLayoutSlot.title));
    assert(hasChild(_PostTileLayoutSlot.details));

    final maxSize = constraints.biggest;

    /// Layout and position the thumbnail if there is one.
    var thumbnailSize = Size.zero;
    if (hasChild(_PostTileLayoutSlot.thumbnail)) {
      thumbnailSize = layoutChild(
          _PostTileLayoutSlot.thumbnail,
          BoxConstraints.tightFor(width: maxSize.width * 0.25),
          parentUsesSize: true);

      positionChild(
          _PostTileLayoutSlot.thumbnail,
          Offset(maxSize.width - thumbnailSize.width, 0.0));
    }

    /// Layout and position the title
    final titleSize = layoutChild(
        _PostTileLayoutSlot.title,
        BoxConstraints.loose(Size(maxSize.width - thumbnailSize.width, maxSize.height)),
        parentUsesSize: true);

    positionChild(
        _PostTileLayoutSlot.title,
        Offset.zero);

    /// Determine the max width of the details section, and the starting height of the layout
    double maxDetailsWidth;
    if (titleSize.height >= thumbnailSize.height) {
      /// The title is as tall or taller than the thumbnail so the details won't overlap with the thumbnail if given the
      /// max width
      maxDetailsWidth = maxSize.width;
    } else {
      /// The thumbnail is taller than the title so the details could end up overlapping with the thumbnail if given the max
      /// width.
      maxDetailsWidth = maxSize.width - thumbnailSize.width;
    }

    /// Layout and position the details section.
    final detailsSize = layoutChild(
        _PostTileLayoutSlot.details,
        BoxConstraints.loose(Size(maxDetailsWidth, maxSize.height)),
        parentUsesSize: true);

    if ((detailsSize.height + titleSize.height) < thumbnailSize.height) {
      positionChild(
        _PostTileLayoutSlot.details,
        Offset(0.0, titleSize.height + (thumbnailSize.height - titleSize.height - detailsSize.height)));

      size = Size(maxSize.width, thumbnailSize.height);
    } else {
      positionChild(
          _PostTileLayoutSlot.details,
          Offset(0.0, titleSize.height));
      size = Size(
          maxSize.width,
          titleSize.height + detailsSize.height);
    }
  }
}

class PostTile extends StatelessWidget {

  PostTile({
    Key key,
    @required this.post,
    @required this.includeSubredditName
  }) : assert(post != null),
       assert(includeSubredditName != null),
       super(key: key);

  final Post post;

  final bool includeSubredditName;

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200))),
          child: Slidable(
            actions: <SlidableAction>[
              if (context.userIsSignedIn)
                ...[
                  SlidableAction(
                    onTriggered: () {
                      context.then(Then(Upvote(votable: post)));
                    },
                    icon: Icons.arrow_upward,
                    iconColor: Colors.white,
                    backgroundColor: getVoteDirColor(VoteDir.up),
                    preBackgroundColor: Colors.grey),
                  SlidableAction(
                    onTriggered: () {
                      context.then(Then(Downvote(votable: post)));
                    },
                    icon: Icons.arrow_downward,
                    iconColor: Colors.white,
                    backgroundColor: getVoteDirColor(VoteDir.down)),
                ],
              SlidableAction(
                onTriggered: () {
                  _showPostOptionsBottomSheet(
                    context: context,
                    post: post);
                },
                icon: Icons.more_horiz,
                iconColor: Colors.white,
                backgroundColor: Colors.black54,
                preBackgroundColor: Colors.grey)
            ],
            child: Pressable(
              behavior: HitTestBehavior.opaque,
              onPress: () {
                showPostPage(
                  context: context,
                  post: post);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0),
                child: _PostTileLayout(
                  title: Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: post.hasBeenViewed ? Colors.black54 : Colors.black)),
                  details: Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.0,
                      children: HorizontalCircleDivider.divide(<Widget>[
                        if (includeSubredditName)
                          Text(
                            'r/${post.subredditName}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54)),
                        Text(
                          'u/${post.authorName}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54)),
                        Text(
                          formatElapsedUtc(post.createdAtUtc),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54)),
                        Text(
                          '${formatCount(post.score)} points',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: getVotableColor(post))),
                        Text(
                          '${formatCount(post.commentCount)} comments',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54))
                      ]))),
                  thumbnail: post.media != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Material(
                            child: InkWell(
                              child: ClipPath(
                                clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                                child: AspectRatio(
                                  aspectRatio: 15/12,
                                  child: MediaThumbnail(
                                    media: post.media))))))
                      : null)))));
      });
  }
}

