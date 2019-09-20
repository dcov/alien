part of 'snudown.dart';

abstract class Snudown extends Model {

  factory Snudown() {
    return _$Snudown(
      nodes: const <Node>[],
      models: const <String, Model>{}
    );
  }

  List<Node> get nodes;

  Map<String, Model> get models;
}
