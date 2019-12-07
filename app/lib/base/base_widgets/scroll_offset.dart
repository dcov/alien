part of '../base.dart';

class ScrollOffset {
  double value = 0.0;
}

mixin ScrollOffsetMixin<W extends StatefulWidget> on State<W> {

  @protected
  ScrollController controller;

  @protected
  ScrollOffset get offset;

  @protected
  @mustCallSuper
  void didChangeOffset() {
    offset.value = controller.offset;
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController(initialScrollOffset: offset.value);
    controller.addListener(didChangeOffset);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class TrackingScrollView extends StatefulWidget {

  TrackingScrollView({
    Key key,
    @required this.offset,
    this.slivers = const <Widget>[],
  }) : super(key: key);

  final ScrollOffset offset;

  final List<Widget> slivers;

  @override
  _TrackingScrollViewState createState() => _TrackingScrollViewState();
}

class _TrackingScrollViewState extends State<TrackingScrollView> with ScrollOffsetMixin {

  @override
  ScrollOffset get offset => widget.offset;

  @override
  Widget build(BuildContext context) {
    return PaddedScrollView(
      controller: controller,
      slivers: widget.slivers
    );
  }
}

