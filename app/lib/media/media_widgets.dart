part of 'media.dart';

class MediaThumbnail extends StatelessWidget {

  MediaThumbnail({
    Key key,
    @required this.media
  }) : super(key: key);

  final Media media;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      Widget result;
      switch (media.thumbnailStatus) {
        case ThumbnailStatus.notLoaded:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            dispatch(LoadThumbnail(media: this.media));
          });
          continue loading;
        loading:
        case ThumbnailStatus.loading:
          result = Center(child: CircularProgressIndicator());
          break;
        case ThumbnailStatus.notFound:
          result = Icon(Icons.broken_image);
          break;
        case ThumbnailStatus.loaded:
          result = Image(image: CachedNetworkImageProvider(media.thumbnail));
          break;
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(media.thumbnailStatus),
          child: result
        )
      );
    }
  );
}

