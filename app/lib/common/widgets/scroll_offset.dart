import 'package:flutter/widgets.dart';

class ScrollOffset {
  double value = 0.0;
}

mixin ScrollOffsetMixin<W extends StatefulWidget> on State<W> {

  @protected
  ScrollController controller;

  @protected
  ScrollOffset get offset;

  @override
  void initState() {
    super.initState();
    controller = ScrollController(
      initialScrollOffset: offset.value
    )..addListener(() {
      offset.value = controller.offset;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
