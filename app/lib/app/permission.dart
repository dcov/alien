import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class PermissionModel extends Model {

  PermissionModel(this._info, this._enabled);

  bool get enabled => _enabled;
  bool _enabled;

  String get description => _info.description;

  String get id => _info.id;

  String get name => _info.name;

  final ScopeInfo _info;

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }
}

class PermissionTile extends StatelessWidget {

  PermissionTile({
    Key key,
    @required this.model
  }) : super(key: key);

  final PermissionModel model;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AnimatedBuilder(
        animation: model,
        builder: (BuildContext context, Widget _) {
          return Checkbox(
            value: model.enabled,
            onChanged: (bool _) => model.toggle(),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          );
        }
      ),
      title: Text(model.name),
      subtitle: Text(model.description),
    );
  }
}