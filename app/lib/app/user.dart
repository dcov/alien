import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'account.dart';

class UserModel extends AccountModel {

  UserModel(Account thing)
    : super(thing);
}

class UserTile extends StatelessWidget {

  UserTile({
    Key key,
    @required this.model
  }) : super(key: key);

  final UserModel model;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      icon: Icon(Icons.account_box),
      title: Text(model.username),
    );
  }
}