import 'package:flutter/material.dart' hide Page;

import '../models/browse_model.dart';
import '../widgets/page.dart';
import '../widgets/widget_extensions.dart';

import 'defaults_sliver.dart';
import 'home_page.dart';
import 'subscriptions_sliver.dart';

class BrowsePage extends Page {

  BrowsePage({
    RouteSettings settings,
    @required this.browse,
  }) : super(settings: settings);

  final Browse browse;

  @override
  Widget buildPage(BuildContext context, _, __) {
    assert(this.isFirst);
    return Material(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                middle: Text("Browse")))),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                if (browse.home != null)
                  SliverToBoxAdapter(child: HomeTile(home: browse.home)),
                if (browse.subscriptions != null) ...[
                  SubscriptionsSliver(
                    subscriptions: browse.subscriptions),
                ],
                if (browse.defaults != null) ...[
                    DefaultsSliver(defaults: browse.defaults)
                ]
              ])),
        ]));
  }
}

