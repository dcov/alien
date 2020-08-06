import 'package:elmer/elmer.dart';
import 'package:markdown/markdown.dart';

part 'snudown.mdl.dart';

@model
mixin $Snudown {

  List<Node> get nodes;

  Map<String, Model> get models;
}
