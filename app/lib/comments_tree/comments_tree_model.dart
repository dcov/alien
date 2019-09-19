part of 'comments_tree.dart';

abstract class CommentsTree extends Model {

  factory CommentsTree({
    @required String fullPostId,
    @required String permalink,
    CommentsSort sort = CommentsSort.best,
  }) {
    return _$CommentsTree(
      fullPostId: fullPostId,
      isRefreshing: false,
      permalink: permalink,
      sort: sort,
      things: const <Thing>[]
    );
  }

  String get fullPostId;

  bool isRefreshing;

  String get permalink;

  CommentsSort sort;

  List<Thing> get things;
}
