import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'permission.dart';

class PermissionEditorModelSideEffects {

  const PermissionEditorModelSideEffects();

  PermissionModel createPermission(ScopeInfo info, bool enabled) {
    return PermissionModel(info, enabled);
  }
}

typedef PermissionEditorCallback = void Function(Iterable<Scope> enabled);

class PermissionEditorModel extends Model {

  PermissionEditorModel(
    Iterable<ScopeInfo> infos,
    Iterable<Scope> enabled,
    this._onPermissionsUpdated, [
    PermissionEditorModelSideEffects sideEffects = const PermissionEditorModelSideEffects(),
  ]) : this.permissions = infos.map((info) {
        return sideEffects.createPermission(
          info, enabled.contains(Scope.from(info.id)));
      }).toSet();

  final Iterable<PermissionModel> permissions;

  final PermissionEditorCallback _onPermissionsUpdated;

  void finish() {
    final enabled = Set<Scope>();
    for (final permission in permissions) {
      if (permission.enabled) {
        enabled.add(Scope.from(permission.id));
      }
    }
    _onPermissionsUpdated(enabled);
  }
}

class PermissionEditorMenu extends StatelessWidget {

  PermissionEditorMenu({
    Key key,
    @required this.model
  }) : super(key: key);

  final PermissionEditorModel model;

  static void show(BuildContext context, PermissionEditorModel model) {
    Navigator.push(
      context,
      FadeRoute(
        builder: (BuildContext context) {
          return PermissionEditorMenu(model: model);
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 48.0,
          child: NavigationToolbar(
            leading: BackButton(),
            middle: Text('Edit Permissions'),
            trailing: IconButton(
              onPressed: () {
                Navigator.pop(context);
                model.finish();
              },
              icon: Icon(Icons.check),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: model.permissions.map<Widget>((PermissionModel permissionModel) {
              return PermissionTile(model: permissionModel);
            }).toList(),
          )
        )
      ],
    );
  }
}