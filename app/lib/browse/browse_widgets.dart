part of 'browse.dart';

class BrowseEntry extends ScaffoldEntry {

  BrowseEntry({ this.browse });

  final Browse browse;

  @override
  String get title => 'Browse';

  @override
  Widget buildTopContent(BuildContext context) {
    return null;
  }

  @override
  Widget buildTopActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildBody(BuildContext context) {
    return null;
  }

  @override
  Widget buildBottomActions(BuildContext context) {
    return null;
  }
}

class BrowseTile extends StatelessWidget {

  BrowseTile({
    Key key,
    @required this.browse
  }) : super(key: key);

  final Browse browse;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () {},
      icon: Icon(CustomIcons.subreddit),
      title: Text('Browse'),
    );
  }
}
