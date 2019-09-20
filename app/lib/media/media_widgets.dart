part of 'media.dart';

class MediaThumbnail extends StatelessWidget {

  MediaThumbnail({
    Key key,
    @required this.mediaKey
  }) : super(key: key);

  final ModelKey mediaKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final ThumbnailUrl thumbnailUrl = store.get<Media>(this.mediaKey).thumbnailUrl;
      if (thumbnailUrl is ThumbnailUrlValue) {
        return Image(
          image: CachedNetworkImageProvider(thumbnailUrl.value),
        );
      } else if (thumbnailUrl is ThumbnailUrlLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (thumbnailUrl is! ThumbnailUrlNotFound) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          dispatch(LoadMediaThumbnail(mediaKey: this.mediaKey));
        });
      }

      return Icon(Icons.broken_image);
    }
  );
}
