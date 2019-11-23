part of 'targets.dart';

mixin TargetsMixin<W extends StatefulWidget> on State<W> {

  void handlePush(Target target) => context.dispatch(TargetsPush(target: target));

  void handlePop(Target target) => context.dispatch(TargetsPop(target: target));

  TargetEntry createEntry(Target target) => mapTarget(target, MapTarget.entry);

  Widget buildTile(BuildContext context, Target target) => mapTarget(target, MapTarget.tile);
}

