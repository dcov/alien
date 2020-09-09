import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/accounts.dart';
import '../models/accounts.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../widgets/tile.dart';

class _AccountTile extends StatelessWidget {

  _AccountTile({
    Key key,
    this.user,
    @required this.isCurrentAccount,
    @required this.onTap,
  }) : assert(isCurrentAccount != null),
       assert(onTap != null),
       super(key: key);

  final User user;

  final bool isCurrentAccount;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: onTap,
      title: Text(user != null ? user.name : 'Anonymous'));
  }
}

void showAccountsBottomSheet({
    @required BuildContext context,
    @required Accounts accounts,
    @required Auth auth
  }) {
  assert(context != null);
  assert(accounts != null);
  assert(auth != null);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.5,
        builder: (_, ScrollController controller) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Accounts')),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: <Widget>[
                    ...accounts.users.map((User user) {
                         return _AccountTile(
                           user: user,
                           isCurrentAccount: accounts.currentUser == user,
                           onTap: () {

                           });
                       }),
                    _AccountTile(
                      isCurrentAccount: accounts.currentUser == null,
                      onTap: () {
                      }),
                  ]))
            ]);
        });
    });
}

