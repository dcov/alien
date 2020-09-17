import 'package:elmer/elmer.dart';
import 'package:markdown/markdown.dart';

part 'snudown.g.dart';

abstract class Snudown extends Model {

  factory Snudown({
    List<Node> nodes,
    Map<String, Model> models
  }) = _$Snudown;

  List<Node> get nodes;

  Map<String, Model> get models;
}

