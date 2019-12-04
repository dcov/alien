part of 'auth.dart';

class AuthButton extends StatelessWidget {

  AuthButton({
    Key key,
    @required this.auth,
  }) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPress: () => context.push(AuthEntry(auth: auth)),
      child: SizedBox(
        height: 48.0,
        width: 48.0,
        child: Center(
          child: Icon(Icons.person),
        )
      )
    );
  }
}

class AuthEntry extends ShellAreaEntry {

  AuthEntry({ @required this.auth });

  final Auth auth;

  @override
  String get title => 'Accounts';

  @override
  Widget buildBody(_) => Connector(
    builder: (BuildContext context, __) {
      if (auth.authenticating) {
        return Center(
          child: CircularProgressIndicator()
        );
      }

      return PaddedScrollView(
        slivers: <Widget>[
          SliverList(delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == auth.users.length) {
                return _LoginTile(auth: auth);
              }

              return UserTile(
                onLogIn: () => context.dispatch(LogInUser(user: auth.users[index])),
                onLogOut: () => context.dispatch(LogOutUser(user: auth.users[index])),
                user: auth.users[index],
              );
            },
            childCount: auth.users.length + 1,
          ))
        ]
      );
    }
  );
}

class _LoginTile extends StatelessWidget {

  _LoginTile({
    Key key,
    @required this.auth,
  }) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () {
        context..dispatch(LoginStart())
               ..push(_LoginEntry(auth: auth));
      },
      icon: Icon(Icons.add),
      title: Text('Add account'),
    );
  }
}

const Duration _kSwitchDuration = Duration(milliseconds: 250);

class _LoginEntry extends ShellAreaEntry {

  _LoginEntry({ @required this.auth });

  final Auth auth;

  @override
  String get title => 'Login';

  @override
  List<Widget> buildTopActions(BuildContext context) {
    return <Widget>[
      Pressable(
        onPress: () => context.push(_PermissionsEntry(auth: auth)),
        child: SizedBox(
          width: 48.0,
          height: 48.0,
          child: Icon(Icons.edit)
        )
      ),
    ];
  }

  @override
  Widget buildBody(_) => Connector(
    builder: (BuildContext context, __) {
      if (auth.authenticating) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          context.pop();
        });
      }

      final Widget result = (auth.permissionsStatus == PermissionsStatus.loading)
          ? const CircularProgressIndicator()
          : WebViewControl(
              url: auth.session.url,
              onPageFinished: (String url) {
                if (!auth.authenticating)
                  context.dispatch(CheckUrl(url: url));
              }
            );

      return AnimatedSwitcher(
        duration: _kSwitchDuration,
        child: KeyedSubtree(
          key: ValueKey(auth.permissionsStatus),
          child: Padding(
            padding: context.bodyAreaPadding,
            child: result
          )
        )
      );
    }
  );
}

class _PermissionsEntry extends ShellAreaEntry {

  _PermissionsEntry({ @required this.auth });

  final Auth auth;

  @override
  String get title => 'Permissions'; 

  @override
  Widget buildBody(BuildContext context) {
    return PaddedScrollView(
      slivers: <Widget>[
        SliverList(delegate: SliverChildBuilderDelegate(
          (_, int index) => _PermissionTile(
            permission: auth.permissions[index]
          ),
          childCount: auth.permissions.length,
        ))
      ]
    );
  }

  @override
  List<Widget> buildBottomActions(BuildContext context) {
    return <Widget>[
      Pressable(
        onPress: () {
          context..dispatch(ResetPermissions())
                 ..pop(this);
        },
        child: Text('Cancel'),
      ),
      Pressable(
        onPress: () {
          context..dispatch(ResetAuthSession())
                 ..pop(this);
        },
        child: Text('Confirm'),
      ),
    ];
  }
}

class _PermissionTile extends StatelessWidget {

  _PermissionTile({
    Key key,
    @required this.permission,
  }) : super(key: key);

  final Permission permission;

  @override
  Widget build(_) => Connector(
    builder: (_, EventDispatch dispatch) {
      return Pressable(
        onPress: () {},
        child: Row(
          children: <Widget>[
            Checkbox(
              onChanged: (_) {
                dispatch(TogglePermission(
                  permission: permission
                ));
              },
              value: permission.enabled,
            ),
            Expanded(child: Text(permission.name))
          ]
        ),
      );
    }
  );
}

