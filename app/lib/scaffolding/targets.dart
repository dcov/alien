part of 'scaffolding.dart';

Widget _buildTarget(RoutingTarget target, bool isPage) {
  if (target is Browse)
    return isPage ? BrowsePage(browseKey: target.key)
                  : BrowseTile(browseKey: target.key);
  else if (target is Subreddit)
    return isPage ? SubredditPage(subredditKey: target.key)
                  : SubredditTile(subredditKey: target.key);
  
  return const SizedBox();
}

class _TargetsBody extends StatelessWidget {

  _TargetsBody({
    Key key,
    @required this.targets,
  }) : super(key: key);

  final List<RoutingTarget> targets;

  @override
  Widget build(BuildContext context) {
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
  }
}
