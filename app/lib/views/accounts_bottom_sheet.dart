import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/init.dart';
import '../models/accounts.dart';
import '../models/user.dart';
import '../widgets/pressable.dart';

import 'login_screen.dart';

Future<bool> _showRemoveConfirmationDialog({
    @required BuildContext context,
    @required User user,
  }) {
  assert(context != null);
  assert(user != null);
  return showDialog<bool>(
    context: context,
    useRootNavigator: true,
    child: AlertDialog(
      title: Text(
        'Logout ${user.name}'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
          child: Text('Confirm')),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(false);
          },
          child: Text('Cancel'))
      ]));
}

void _removeUser(BuildContext context, User user) async {
  final remove = await _showRemoveConfirmationDialog(
    context: context,
    user: user);

  if (remove) {
    context.dispatch(LogOutUser(user: user));

    /// Pop the accounts bottom sheet
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _AccountTile extends StatelessWidget {

  _AccountTile({
    Key key,
    this.user,
    @required this.isCurrentAccount,
    @required this.onSelect,
    this.onRemove,
  }) : assert(isCurrentAccount != null),
       assert(onSelect != null),
       assert((onRemove != null && user != null) || (onRemove == null && user == null)),
       super(key: key);

  final User user;

  final bool isCurrentAccount;

  final VoidCallback onSelect;

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPress: onSelect,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Text(
              user != null ? user.name : 'Anonymous',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500)),
            Spacer(),
            if (onRemove != null)
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: PressableIcon(
                  onPress: onRemove,
                  icon: Icons.close))
          ])));
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
  }) {
  assert(context != null);
  assert(accounts != null);
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
                           onSelect: () {
                             if (user != accounts.currentUser)
                               _switchUser(context, user);
                           },
                           onRemove: () => _removeUser(context, user));
                       }),
                    _AccountTile(
                      isCurrentAccount: accounts.currentUser == null,
                      onSelect: () {
                        if (accounts.currentUser != null)
                          _switchUser(context, null);
                      }),
                    Pressable(
                      onPress: () => showLoginScreen(context: context),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add),
                          Text(
                            'Add account',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                        ])),
                  ]))
            ]);
        });
    });
}

