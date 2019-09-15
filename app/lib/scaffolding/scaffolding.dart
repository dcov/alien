import 'dart:math' as math;

import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../browse/browse.dart';
import '../routing/routing.dart';

part 'layout.dart';
part 'targets.dart';

class Scaffolding extends StatefulWidget {

  Scaffolding({ Key key }) : super(key: key);

  @override
  _ScaffoldingState createState() => _ScaffoldingState();
}

class _ScaffoldingState extends State<Scaffolding>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(_) => Router(
    builder: (BuildContext _,
              List<RoutingTarget> targets,
              RoutingTarget oldTarget,
              RoutingTarget newTarget,
              RoutingTransition transition) {

      return _ScaffoldingLayout(
        overlappedBuilder: (BuildContext context, Animation<double> animation) {
          return _TargetsBody(
            targets: targets,
          );
        },
        overlapBuilder: (BuildContext context, Animation<double> animation) {
          return _buildTarget(newTarget, true);
        },
      );
    }
  );
}
