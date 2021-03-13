import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../widgets/pressable.dart';
import '../widgets/widget_extensions.dart';

class _OptionTile extends StatelessWidget {

  _OptionTile({
    Key? key,
    required this.onPress,
    required this.title,
    required this.icon,
    this.subtext
  }) : super(key: key);

  final VoidCallback onPress;

  final String title;

  final IconData icon;

  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPress: onPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(icon)),
            Column(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                   fontSize: 14.0,
                   fontWeight: FontWeight.w500)),
                if (subtext != null)
                  Text(subtext!)
              ])
          ])));
  }
}

void _showLicensePage({ required BuildContext context }) {
  /*context.rootNavigator.push(
    DraggablePageRoute(
      builder: (_) {
        return LicensePage();
      }));*/
}

class _AboutPageView extends StatelessWidget {

  _AboutPageView({
    Key? key,
    required this.packageInfo
  }) : super(key: key);

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    return Material(child: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          toolbarHeight: 48.0,
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 1.0,
          pinned: true,
          centerTitle: true,
          leading: PressableIcon(
            onPress: () => context.rootNavigator.pop(),
            icon: Icons.arrow_back_ios_rounded,
            iconColor: Colors.black),
          title: Text(
            'About',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
              color: Colors.black))),
        SliverToBoxAdapter(
          child: FutureBuilder<PackageInfo>(
            future: packageInfo,
            builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              String version;
              String buildNumber;
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  final data = snapshot.requireData;
                  version = data.version;
                  buildNumber = data.buildNumber;
                  break;
                default:
                  version = buildNumber = 'N/A';
                  break;
              }
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Alien for Reddit',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500)),
                    Text('Version: $version'),
                    Text('Build: $buildNumber'),
                  ]));
            })),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            Divider(),
            _OptionTile(
              onPress: () => _showLicensePage(context: context),
              title: 'Licenses',
              icon: Icons.list)
          ]))
      ]));
  }
}

void _showAboutPage({ required BuildContext context }) {
  /*final packageInfoFuture = PackageInfo.fromPlatform();
  context.rootNavigator.push(
    DraggablePageRoute(
      builder: (_) {
        return _AboutPageView(
          packageInfo: packageInfoFuture);
      }));*/
}

class _SettingsPageView extends StatelessWidget {

  _SettingsPageView({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          toolbarHeight: 48.0,
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 1.0,
          pinned: true,
          centerTitle: true,
          leading: PressableIcon(
            onPress: () => context.rootNavigator.pop(),
            icon: Icons.arrow_back_ios_rounded,
            iconColor: Colors.black),
          title: Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16.0))),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            _OptionTile(
              onPress: () => _showAboutPage(context: context),
              title: 'About',
              icon: Icons.contact_support_rounded)
          ])),
      ]));
  }
}

void showSettingsPage({ required BuildContext context }) {
  /*context.rootNavigator.push(
    DraggablePageRoute(
      builder: (_) => _SettingsPageView()));*/
}
