part of 'more.dart';

abstract class More extends Model implements Thing {

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
