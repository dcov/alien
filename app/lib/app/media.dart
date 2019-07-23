import 'dart:async';

import 'package:scraper/scraper.dart' as scraper;
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'base.dart';

class MediaModelSideEffects with CacheMixin, RunnerMixin {

  const MediaModelSideEffects();

  Future<String> getThumbnail(String url) async {
    final Map<String, String> thumbnailCache = getThumbnailCache();
    if (thumbnailCache.containsKey(url))
      return thumbnailCache[url];
    
    final String thumbnail = await _scrapeThumbnail(url);
    thumbnailCache[url] = thumbnail;
    return thumbnail;
  }

  Future<String> _scrapeThumbnail(String url) {
    return run(scraper.getThumbnail, url).then((String result) {
      getThumbnailCache()[url] = result;
      return result;
    });
  }
}

enum MediaType {
  web,
  video,
  image,
}

class MediaModel extends Model {

  MediaModel(
    String source, [
    String title,
    String thumbnail,
    bool scrapeThumbnail = false,
    this._type,
    this._sideEffects = const MediaModelSideEffects()
  ]) : this._source = source,
       this.title = title ?? source {
    _thumbnail = scrapeThumbnail ? Delayable.fromDelayable(thumbnail)
                                 : Delayable.fromNullable(thumbnail);
    if (_type == null || _thumbnail.isDelayed)
      _parseSource();

    if (_thumbnail.isDelayed) {
      _loadThumbnail();
    }
  }

  final String title;

  String get source => _source;
  String _source;

  Delayable<String> get thumbnail => _thumbnail;
  Delayable<String> _thumbnail;

  MediaType get type => _type;
  MediaType _type;

  final MediaModelSideEffects _sideEffects;

  void _parseSource() {
    final Uri uri = Uri.parse(source);
    final String host = uri.host;

    void trySetThumbnailAsSource() {
      if (_thumbnail.isDelayed)
        _thumbnail = Delayable.of(source);
    }

    if (host.endsWith('reddit.com') || host.endsWith('redd.it')) {
      if (host.startsWith('v')) {
        _type ??= MediaType.video;
        // _source = '$_source/DASHPlaylist.mpd';
      } else if (host.startsWith('i')) {
        _type ??= MediaType.image;
        trySetThumbnailAsSource();
      }
    } else {
      _type = MediaType.web;
    }
  }

  void _loadThumbnail() {
    _sideEffects.getThumbnail(source).then((thumbnail) {
      _thumbnail = Delayable.fromNullable(thumbnail);
      notifyListeners();
    });
  }
}

class MediaThumbnail extends StatelessWidget {

  MediaThumbnail({
    Key key,
    this.accentColor,
    this.model
  }) : super(key: key);

  final Color accentColor;
  final MediaModel model;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (BuildContext context, _) {
        Widget result;
        model.thumbnail.check(
          onPresent: (url) {
            result = Image(
              image: CachedNetworkImageProvider(url),
              fit: BoxFit.cover,
            );
          },
          onDelayed: () {
            result = Center(child: CircularProgressIndicator(
              valueColor: accentColor == null ? null : AlwaysStoppedAnimation(accentColor),
            ));
          },
          onAbsent: () {
            result = Icon(Icons.image);
          }
        );
        return result;
      },
    );
  }
}

enum _WebPageOption {
  openExternal
}

class _WebPage extends StatelessWidget {

  _WebPage({ Key key, @required this.model })
    : super(key: key);

  final MediaModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 72.0,
            child: MediaPadding(
              child: NavigationToolbar(
                centerMiddle: false,
                leading: CloseButton(),
                middle: Text(
                  model.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  tooltip: 'Options',
                  onSelected: (_WebPageOption option) {
                    switch (option) {
                      case _WebPageOption.openExternal:
                        launcher.launch(model.source);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<_WebPageOption>>[
                      PopupMenuItem(
                        value: _WebPageOption.openExternal,
                        child: Text('Open in External'),
                      )
                    ];
                  },
                ),
              )
            ),
          ),
          Expanded(
            child: WebView(
              initialUrl: model.source,
              javascriptMode: JavascriptMode.unrestricted,
            )
          )
        ],
      )
    );
  }
}

class _VideoPage extends View<MediaModel> {

  _VideoPage({ Key key, @required MediaModel model })
    : super(key: key, model: model);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends ViewState<MediaModel, _VideoPage> {

  VideoPlayerController _controller;

  VideoPlayerValue get _value => _controller.value;

  void _initController() {
    _controller = VideoPlayerController.network(model.source);
    _controller.initialize().then((_) => setState(() { }));
    _controller.addListener(() {
      final VideoPlayerValue value =_controller.value;
      if (value.isBuffering) {
        print('is buffering');
      }
    });
  }

  @override
  void initModel() {
    super.initModel();
    _initController();
  }

  @override
  void didUpdateModel(MediaModel oldModel) {
    super.didUpdateModel(oldModel);
    _controller?.dispose();
    _initController();
  }

  @override
  void disposeModel() {
    _controller.dispose();
    super.disposeModel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          child: MediaPadding(
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                centerMiddle: false,
                leading: CloseButton(),
                middle: Text(
                  model.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            if (_value.isPlaying || _value.isLooping) {
              _controller.pause();
            } else {
              _controller.play();
            }
          }),
          child: Center(
            child: _value.initialized
              ? AspectRatio(
                  aspectRatio: _value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const EmptyBox()
          )
        ),
        Center(
          child: !_value.isPlaying
            ? Icon(Icons.play_arrow)
            : const EmptyBox()
        )
      ],
    );
  }
}

void showMedia({ BuildContext context, MediaModel model }) {
  switch (model.type) {
    case MediaType.video:
    case MediaType.image:
    case MediaType.web:
      launcher.launch(model.source);
      break;
  }
}