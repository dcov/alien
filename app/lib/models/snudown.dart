import 'package:mal/mal.dart';
import 'package:markdown/markdown.dart';

part 'snudown.g.dart';

abstract class Snudown implements Model {

  factory Snudown({
    List<Node> nodes,
    Map<String, Object> links
  }) = _$Snudown;

  List<Node> get nodes;

  Map<String, Object> get links;
}

