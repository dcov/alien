import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../logic/media.dart';
import '../models/media.dart';
import '../widgets/pressable.dart';

import 'media_page.dart';

class MediaThumbnail extends StatelessWidget {

  MediaThumbnail({
    Key key,
    @required this.media
  }) : super(key: key);

  final Media media;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      Widget result;
      switch (media.thumbnailStatus) {
        case ThumbnailStatus.notLoaded:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            context.then(Then(LoadThumbnail(media: this.media)));
          });
          continue renderStatic;
        renderStatic:
        case ThumbnailStatus.loading:
        case ThumbnailStatus.notFound:
          result = Icon(
            Icons.link,
            color: Colors.white);
          break;
        case ThumbnailStatus.loaded:
          result = CachedNetworkImage(
            imageUrl: media.thumbnail,
            fit: BoxFit.contain);
          break;
      }

      return Pressable(
        behavior: HitTestBehavior.opaque,
        onPress: () => showMediaPage(
          context: context,
          media: media),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(media.thumbnailStatus),
            child: result),
          layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
            return Material(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  ...previousChildren,
                  currentChild,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black87),
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                heightFactor: 1.0,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  Uri.parse(media.source).host,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.white)))),
                            Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.launch,
                                size: 10.0,
                                color: Colors.white))
                          ])))),
                ]));
          }));
    });
}

