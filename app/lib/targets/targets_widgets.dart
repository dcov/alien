part of 'targets.dart';

mixin TargetsMixin<W extends StatefulWidget> on State<W> implements RouterMixin<W> {

  @override
  void didPush(Target target) => context.dispatch(TargetsPush(target: target));

  @override
  void didPop(Target target) => context.dispatch(TargetsPop(target: target));

  @override
  RouterEntry createEntry(Target target) => mapTarget(target, MapTarget.entry);

  @protected
  Widget buildTile(BuildContext _, Target target) => mapTarget(target, MapTarget.tile);
}

