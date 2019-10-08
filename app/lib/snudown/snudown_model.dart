part of 'snudown.dart';

abstract class Snudown implements Model {

  factory Snudown(String data) {
    final Snudown result = _$Snudown(
      nodes: const <Node>[],
      models: const <String, Model>{}
    );
    parseSnudown(result, data);
    return result;
  }

  List<Node> get nodes;

  Map<String, Model> get models;
}
