part of '../app.dart';

class AppHome extends StatefulWidget {

  AppHome({
    Key key,
  }) : super(key: key);

  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {

  final GlobalKey<_AppScaffoldState> _scaffoldKey = GlobalKey<_AppScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AppScaffold(
        key: _scaffoldKey,
        draggableAmount: 24.0,
        overlapped: ,
        topOverlapBuilder: (BuildContext context, double value) {
          return Material(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.0)
              )
            ),
          );
        },
        bottomOverlapBuilder: (BuildContext context, double value) {
          return Material(
            shape: OutwardBorder.top(24 * value)
          );
        },
      ),
    );
  }
}
