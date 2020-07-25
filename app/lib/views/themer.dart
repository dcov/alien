import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/theming_model.dart';

class Themer extends StatelessWidget {

  Themer({
    Key key,
    @required this.theming,
    @required this.child,
  }) : super(key: key);

  final Theming theming;

  final Widget child;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return AnimatedTheme(
        data: theming.data,
        child: this.child,
      );
    },
  );
}

