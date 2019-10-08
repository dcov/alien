import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class CoordinatorEntry {

  Widget buildTopArea(BuildContext context) => null;

  Widget buildBackdrop(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}

class Coordinator extends StatefulWidget {

  Coordinator({
    Key key,
    this.initialEntries = const <CoordinatorEntry>[]
  }) : super(key: key);

  final List<CoordinatorEntry> initialEntries;

  @override
  CoordinatorState createState() => CoordinatorState();
}

class CoordinatorState extends State<Coordinator> {

  final List<CoordinatorEntry> _entries = <CoordinatorEntry>[];

  @override
  void initState() {
    super.initState();
    assert(widget.initialEntries != null);
    _entries.addAll(widget.initialEntries);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
      },
    );
  }
}