import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/post.dart';
import 'reddit/types.dart';
import 'widgets/clickable.dart';
import 'widgets/custom_render_object.dart';
import 'widgets/formatting.dart';
import 'widgets/page_router.dart';

import 'media_thumbnail.dart';
import 'post_page.dart';
import 'presentation_extensions.dart';
import 'votable_views.dart';

class PostTile extends StatelessWidget {

  PostTile({
    Key? key,
    required this.post,
    required this.includeSubredditName
  }) : super(key: key);

  final Post post;

  final bool includeSubredditName;

  @override
  Widget build(BuildContext _) {
    return Connector(builder: (BuildContext context) {
      final userIsSignedIn = context.userIsSignedIn;
      return Clickable(
        opaque: true,
        onClick: () {
          context.push(PostPage(post: post));
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Colors.grey,
              ),
            ),
          ),
          child: _ClassicLayout(
            score: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                width: 32.0,
                child: Column(
                  children: <Widget>[
                    VoteButton(
                      votable: post,
                      voteDir: VoteDir.up,
                    ),
                    ScoreText(votable: post),
                    VoteButton(
                      votable: post,
                      voteDir: VoteDir.down,
                    ),
                  ],
                ),
              ),
            ),
            thumbnail: Padding(
              padding: EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0),
              child: SizedBox(
                width: 96.0,
                height: 72.0,
                child: Center(
                  child: post.media != null 
                    ? MediaThumbnail(media: post.media!)
                    : Icon(Icons.list),
                ),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: 8.0, right: 16.0),
              child: Text(
                post.title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            details: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Wrap(
                children: <Widget>[
                  if (includeSubredditName)
                    Text(
                      'r/${post.subredditName} ',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    'Posted by u/${post.authorName} ',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${formatElapsedUtc(post.createdAtUtc)}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            options: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.comment,
                    size: 12.0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      '${formatCount(post.commentCount)} Comments',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (userIsSignedIn) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(
                        post.isSaved ? Icons.bookmark_added : Icons.bookmark,
                        size: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        post.isSaved ? 'Unsave' : 'Save',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

enum _ClassicLayoutSlot {
  score,
  thumbnail,
  title,
  details,
  options,
}

class _ClassicLayout extends CustomRenderObjectWidget {

  _ClassicLayout({
    Key? key,
    required Widget score,
    Widget? thumbnail,
    required Widget title,
    required Widget details,
    required Widget options,
  }) : super(
    key: key,
    children: <dynamic, Widget>{
      _ClassicLayoutSlot.score : score,
      if (thumbnail != null)
        _ClassicLayoutSlot.thumbnail : thumbnail,
      _ClassicLayoutSlot.title : title,
      _ClassicLayoutSlot.details : details,
      _ClassicLayoutSlot.options : options,
    },
  );

  @override
  _RenderClassicLayout createRenderObject(BuildContext _) {
    return _RenderClassicLayout();
  }
}

class _RenderClassicLayout extends RenderBox
    with CustomRenderObjectMixin<RenderBox>,
         CustomRenderBoxDefaultsMixin {

  @override
  List<dynamic> get hitTestOrdering => const <dynamic>[
    _ClassicLayoutSlot.options,
    _ClassicLayoutSlot.details,
    _ClassicLayoutSlot.title,
    _ClassicLayoutSlot.thumbnail,
    _ClassicLayoutSlot.score,
  ];

  @override
  void performLayout() {
    assert(hasChild(_ClassicLayoutSlot.score));
    assert(hasChild(_ClassicLayoutSlot.title));
    assert(hasChild(_ClassicLayoutSlot.details));
    assert(hasChild(_ClassicLayoutSlot.options));
    assert(constraints.hasBoundedWidth);

    final biggest = constraints.biggest;
    final maxWidth = biggest.width;
    final maxHeight = biggest.height;

    final scoreSize = layoutChild(
      _ClassicLayoutSlot.score,
      BoxConstraints.loose(biggest),
      parentUsesSize: true,
    )!;

    positionChild(_ClassicLayoutSlot.score, Offset.zero);

    var thumbnailSize = Size.zero;
    if (hasChild(_ClassicLayoutSlot.thumbnail)) {
      thumbnailSize = layoutChild(
        _ClassicLayoutSlot.thumbnail,
        BoxConstraints.loose(Size(maxWidth - scoreSize.width, maxHeight)),
        parentUsesSize: true,
      )!;

      positionChild(_ClassicLayoutSlot.thumbnail, Offset(scoreSize.width, 0.0));
    }

    final remainingMaxWidth = maxWidth - scoreSize.width - thumbnailSize.width;
    final remainingOffsetX = scoreSize.width + thumbnailSize.width;

    final titleSize = layoutChild(
      _ClassicLayoutSlot.title,
      BoxConstraints.loose(Size(remainingMaxWidth, maxHeight)),
      parentUsesSize: true
    )!;

    positionChild(_ClassicLayoutSlot.title, Offset(remainingOffsetX, 0.0));

    final detailsSize = layoutChild(
      _ClassicLayoutSlot.details,
      BoxConstraints.loose(Size(remainingMaxWidth, maxHeight)),
      parentUsesSize: true,
    )!;

    positionChild(
      _ClassicLayoutSlot.details,
      Offset(
        remainingOffsetX,
        titleSize.height,
      ),
    );

    final optionsSize = layoutChild(
      _ClassicLayoutSlot.options,
      BoxConstraints.loose(Size(remainingMaxWidth, maxHeight)),
      parentUsesSize: true,
    )!;

    positionChild(
      _ClassicLayoutSlot.options,
      Offset(
        remainingOffsetX,
        titleSize.height + detailsSize.height,
      ),
    );

    size = Size(
      maxWidth,
      math.max(
        scoreSize.height,
        math.max(
          thumbnailSize.height,
          titleSize.height + detailsSize.height + optionsSize.height,
        ),
      ),
    );
  }
}
