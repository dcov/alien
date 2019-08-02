part of 'thing.dart';

abstract class Thing extends Model {

  Thing(this.id);

  final String id;

  String get kind;

  String get fullId => '${kind}_$id';
}
