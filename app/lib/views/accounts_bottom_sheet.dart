import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/init.dart';
import '../models/accounts.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../widgets/tile.dart';

import 'login_screen.dart';

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
      icon: Icon(Icons.person),
      title: Text(
        user != null ? user.name : 'Anonymous',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}

void _switchUser(BuildContext context, User to) {
  /// Switch the currently signed in user
  context.dispatch(SwitchUser(to: to));

  /// Pop the bottom sheet
  Navigator.of(context, rootNavigator: true).pop();
}

void showAccountsBottomSheet({
    @required BuildContext context,
    @required Accounts accounts,
    @required Auth auth
  }) {
  assert(context != null);
  assert(accounts != null);
  assert(auth != null);
  final dividerColor = Colors.grey.shade700;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController controller) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACCOUNTS',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: dividerColor)))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Divider(
                  height: 2.0,
                  color: dividerColor)),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: <Widget>[
                    ...accounts.users.map((User user) {
                         return _AccountTile(
                           user: user,
                           isCurrentAccount: accounts.currentUser == user,
                           onTap: () {
                             if (user != accounts.currentUser)
                               _switchUser(context, user);
                           });
                       }),
                    _AccountTile(
                      isCurrentAccount: accounts.currentUser == null,
                      onTap: () {
                        if (accounts.currentUser != null)
                          _switchUser(context, null);
                      }),
                    CustomTile(
                      onTap: () => showLoginScreen(context: context, auth: auth),
                      icon: Icon(Icons.add),
                      title: Text(
                        'Add account',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500))),
                  ]))
            ]);
        });
    });
}

