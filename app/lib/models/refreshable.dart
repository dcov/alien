import 'package:elmer/elmer.dart';

part 'refreshable.g.dart';

abstract class Refreshable<T> extends Model {

  factory Refreshable({
    bool refreshing,
    List<T> items
  }) = _$Refreshable;

  bool refreshing;

  List<T> get items;
}

