import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart';

import '../model/post.dart';
import '../logic/saveable.dart';
import '../logic/voting.dart';
import '../ui/circle_divider.dart';
import '../ui/custom_render_object.dart';
import '../ui/formatting.dart';
import '../ui/media_thumbnail.dart';
import '../ui/options_bottom_sheet.dart';
import '../ui/post_route.dart';
import '../ui/pressable.dart';
import '../ui/slidable.dart';
import '../ui/theming.dart';
import '../ui/view_extensions.dart';
import '../ui/votable_utils.dart';

void _showPostOptionsBottomSheet({
    required BuildContext context,
    required Post post
  }) {
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
    Key? key,
    required Widget title,
    required Widget details,
    Widget? thumbnail
  }) : super(
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
          parentUsesSize: true)!;

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
    if (titleSize!.height >= thumbnailSize.height) {
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

    if ((detailsSize!.height + titleSize.height) < thumbnailSize.height) {
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
    Key? key,
    required this.post,
    required this.pathPrefix,
    required this.includeSubredditName
  }) : super(key: key);

  final Post post;

  final String pathPrefix;

  final bool includeSubredditName;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Connector(
      builder: (BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: theming.dividerColor))),
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
                    preBackgroundColor: theming.dividerColor),
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
                preBackgroundColor: theming.dividerColor)
            ],
            child: Pressable(
              behavior: HitTestBehavior.opaque,
              onPress: () {
                PostRoute.goTo(
                  context,
                  post,
                  PostRoute.pathFrom(post, pathPrefix));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0),
                child: _PostTileLayout(
                  title: Text(
                    post.title,
                    style: (post.hasBeenViewed)
                        ? theming.disabledTitleText
                        : theming.titleText),
                  details: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.0,
                      children: HorizontalCircleDivider.divide(<Widget>[
                        if (includeSubredditName)
                          Text(
                            'r/${post.subredditName}',
                            style: theming.detailText),
                        Text(
                          'u/${post.authorName}',
                          style: theming.detailText),
                        Text(
                          formatElapsedUtc(post.createdAtUtc),
                          style: theming.detailText),
                        Text(
                          '${formatCount(post.score)} points',
                          style: applyVoteDirColorToText(theming.detailText, post.voteDir)),
                        Text(
                          '${formatCount(post.commentCount)} comments',
                          style: theming.detailText)
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
                                    media: post.media!))))))
                      : null)))));
      });
  }
}
