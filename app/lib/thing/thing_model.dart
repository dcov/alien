part of 'thing.dart';

@abs
abstract class Thing extends Model {

  String get id;

  String get kind;

  String get fullId => '${kind}_$id';
}
