import 'package:muex/muex.dart';

part 'refreshable.g.dart';

abstract class Refreshable<T> implements Model {

  factory Refreshable({
    bool refreshing,
    List<T> items
  }) = _$Refreshable;

  bool refreshing;

  List<T> get items;
}

