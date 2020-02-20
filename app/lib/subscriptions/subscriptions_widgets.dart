import 'package:flutter/widgets.dart';

import '../widgets/tile.dart';

import 'subscriptions_model.dart';

class SubscriptionsTile extends StatelessWidget {

  SubscriptionsTile({
    Key key,
    @required this.subscriptions
  }) : super(key: key);

  final Subscriptions subscriptions;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () { },
      title: Text('Subscriptions')
    );
  }
}

