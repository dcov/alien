import 'package:elmer/elmer.dart';
import 'package:markdown/markdown.dart';

part 'snudown.g.dart';

abstract class Snudown implements Model {

  factory Snudown.fromRaw(String data) {
    // TODO: move this functionality into the logic/ file.
    final Snudown result = _$Snudown(
      nodes: const <Node>[],
      models: const <String, Model>{}
    );
    // parser.parseRawInto(data, result);
    return result;
  }

  List<Node> get nodes;

  Map<String, Model> get models;
}
