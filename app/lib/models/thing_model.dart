import 'package:elmer/elmer.dart';

@abs
abstract class Thing implements Model {

  String get id;

  String get kind;
}
