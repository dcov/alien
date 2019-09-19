import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../browse/browse.dart';
import '../routing/routing.dart';
import '../subreddit/subreddit.dart';

part 'layout.dart';
part 'switcher.dart';
part 'targets.dart';

class Scaffolding extends StatefulWidget {

  Scaffolding({ Key key }) : super(key: key);

  @override
  _ScaffoldingState createState() => _ScaffoldingState();
}

class _ScaffoldingState extends State<Scaffolding>
    with SingleTickerProviderStateMixin {

  final GlobalKey<_LayoutState> _layoutKey = GlobalKey<_LayoutState>();

  @override
  Widget build(_) => Router(
    builder: (BuildContext _,
              List<RoutingTarget> targets,
              RoutingTarget oldTarget,
              RoutingTarget newTarget,
              RoutingTransition transition) {
      
      return NotificationListener<PushNotification>(
        onNotification: (_) {
          final _LayoutState layout = _layoutKey.currentState;
          if (!layout.overlapIsVisible) {
            layout.showOverlap();
          }
          return true;
        },
        child: _Layout(
          key: _layoutKey,
          overlappedBuilder: (BuildContext context, Animation<double> animation) {
            return Material(
              child: Padding(
                padding: EdgeInsets.only(top: 72.0),
                child: ListView.builder(
                  itemCount: targets.length,
                  itemBuilder: (BuildContext _, int index) {
                    return _buildTarget(targets[index], false);
                  },
                )
              )
            );
          },
          overlapBuilder: (BuildContext context, Animation<double> animation) {
            return _buildTarget(newTarget, true);
          },
        )
      );
    }
  );
}
