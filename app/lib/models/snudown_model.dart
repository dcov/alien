import 'package:elmer/elmer.dart';
import 'package:markdown/markdown.dart';

import 'snudown_parser.dart' as parser;

part 'snudown_model.g.dart';

abstract class Snudown implements Model {

  factory Snudown.fromRaw(String data) {
    final Snudown result = _$Snudown(
      nodes: const <Node>[],
      models: const <String, Model>{}
    );
    parser.parseRawInto(data, result);
    return result;
  }

  List<Node> get nodes;

  Map<String, Model> get models;
}
