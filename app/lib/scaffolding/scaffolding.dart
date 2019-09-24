import 'dart:math' as math;

import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../authorization/authorization.dart';
import '../browse/browse.dart';
import '../post/post.dart';
import '../routing/routing.dart';
import '../subreddit/subreddit.dart';

part 'layout.dart';
part 'overlap.dart';
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
  Widget build(_) => Connector(
    builder: (_, Store store, EventDispatch dispatch) {
      final Authorization auth = store.get();
      return Router(
        builder: (BuildContext _,
                  List<RoutingTarget> targets,
                  RoutingTarget oldTarget,
                  RoutingTarget newTarget,
                  RoutingTransition transition) {
          
          if (newTarget == null) {
            final _LayoutState layout = _layoutKey.currentState;
            if (layout != null && layout.overlapIsVisible) {
              layout.hideOverlap();
            }
          }

          final Widget switcher = _Switcher(
            oldTarget: oldTarget,
            newTarget: newTarget,
            transition: transition,
          );
          
          return WillPopScope(
            onWillPop: () {
              bool result = true;
              if (newTarget != null) {
                dispatch(_mapTarget(newTarget, _MapType.pop_event));
                result = false;
              }
              return Future.value(result);
            },
            child: NotificationListener<PushNotification>(
              onNotification: (_) {
                final _LayoutState layout = _layoutKey.currentState;
                if (!layout.overlapIsVisible) {
                  layout.showOverlap();
                }
                return true;
              },
              child: _Layout(
                key: _layoutKey,
                canDrag: newTarget != null,
                overlappedBuilder: (BuildContext context,
                                    Animation<double> animation) {
                  return Material(
                    child: Padding(
                      padding: EdgeInsets.only(top: 72.0),
                      child: ListView.builder(
                        itemCount: targets.length,
                        itemBuilder: (BuildContext _, int index) {
                          return _mapTarget(targets[index], _MapType.tile);
                        },
                      )
                    )
                  );
                },
                overlapBuilder: (BuildContext context,
                                 Animation<double> animation) {
                  return _Overlap(
                    animation: animation,
                    expanded: switcher,
                    collapsed: Material(
                      child: Padding(
                        padding: MediaQuery.of(context).padding,
                        child: SizedBox(
                          height: 56.0,
                          child: NavigationToolbar(
                            centerMiddle: false,
                            middle: Text(
                              auth.currentUser?.username ?? 'Sign in'),
                            trailing: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            )
          );
        }
      );
    }
  );
}
