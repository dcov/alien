import 'package:cached_network_image/cached_network_image.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../logic/media.dart';
import '../models/media.dart';
import '../widgets/pressable.dart';
import '../widgets/web_view_control.dart';
import '../widgets/widget_extensions.dart';

class _WebPage extends StatelessWidget {

  _WebPage({
    Key key,
    @required this.url
  }) : super(key: key);

  final String url;

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                leading: CloseButton())))),
        Expanded(
          child: WebViewControl(
            url: url)),
        Material(
          child: SizedBox(
            height: context.mediaPadding.bottom))
      ]);
  }
}

void _showMediaPage({
    @required BuildContext context,
    @required Media media
  }) {
  assert(context != null);
  assert(media != null);
  Navigator.of(context, rootNavigator: true)
    .push(MaterialPageRoute(builder: (_) => _WebPage(url: media.source)));
}

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
            context.dispatch(LoadThumbnail(media: this.media));
          });
          continue renderLoading;
        renderLoading:
        case ThumbnailStatus.loading:
          result = Center(child: CircularProgressIndicator());
          break;
        case ThumbnailStatus.notFound:
          result = Icon(Icons.broken_image);
          break;
        case ThumbnailStatus.loaded:
          result = Image(
              image: CachedNetworkImageProvider(media.thumbnail),
              fit: BoxFit.contain);
          break;
      }

      return Pressable(
        behavior: HitTestBehavior.opaque,
        onPress: () => _showMediaPage(
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

