part of '../post.dart';

class PostDepthTile extends StatelessWidget {

  PostDepthTile({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () => context.push(post),
      depth: post.depth,
      icon: Icon(Icons.comment),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

