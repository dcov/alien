part of 'comments_tree.dart';

abstract class More implements Thing {

  factory More.fromData(MoreData data) {
    return _$More(
      isLoading: false,
      count: data.count,
      depth: data.depth,
      thingIds: data.thingIds,
      id: data.id,
      kind: data.kind
    );
  }

  int get count;

  int get depth;

  bool isLoading;

  List<String> get thingIds;
}

abstract class CommentsTree implements Model {

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

