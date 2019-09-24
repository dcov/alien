part of 'scaffolding.dart';

class _Switcher extends StatefulWidget {

  _Switcher({
    Key key,
    @required this.oldTarget,
    @required this.newTarget,
    @required this.transition
  }) : super(key: key);

  final RoutingTarget oldTarget;
  final RoutingTarget newTarget;
  final RoutingTransition transition;

  @override
  _SwitcherState createState() => _SwitcherState();
}

class _SwitcherState extends State<_Switcher> {
  
  final List<_Change> _changes = <_Change>[];
  RoutingTarget _currTarget;

  @override
  Widget build(BuildContext context) {
    if (widget.newTarget == _currTarget) {
    }
  }
}

class _Change extends StatefulWidget {

  _Change({
    Key key
  }) : super(key: key);

  _ChangeState createState() => _ChangeState();
}

class _ChangeState extends State<_Change>
  with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return null;
  }
}
