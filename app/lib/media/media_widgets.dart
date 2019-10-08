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
      switch (media.thumbnailStatus) {
        case ThumbnailStatus.notLoaded:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            dispatch(LoadThumbnail(media: this.media));
          });
          continue loading;
        loading:
        case ThumbnailStatus.loading:
          return Center(child: CircularProgressIndicator());
        case ThumbnailStatus.notFound:
          return Icon(Icons.broken_image);
        case ThumbnailStatus.loaded:
          return Image(image: CachedNetworkImageProvider(media.thumbnail));
      }
      return Container();
    }
  );
}
