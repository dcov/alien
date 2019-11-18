part of 'login.dart';

class InitLogin extends Event {

  InitLogin({ @required this.login });

  final Login login;

  @override
  dynamic update(_) {
    if (login.permissionsStatus != LoginPermissionsStatus.notLoaded)
      return null;

    login.permissionsStatus = LoginPermissionsStatus.loading;
    return GetPermissions(login: login);
  }
}

class PermissionsLoaded extends Event {

  PermissionsLoaded({
    @required this.login,
    @required this.data,
  });

  final Login login;
  final Iterable<ScopeData> data;

  @override
  dynamic update(_) {
    login.permissionsStatus = LoginPermissionsStatus.available;
    login.session = AuthSession(
      login.clientId,
      login.redirectUri,
      login.scopes.map((Scope scope) => scope.name)
    );
  }
}

class PermissionsLoadingFailed extends Event {

  PermissionsLoadingFailed({ @required this.login });

  final Login login;

  @override
  dynamic update(_) {
    login.permissionsStatus = LoginPermissionsStatus.notLoaded;
  }
}

