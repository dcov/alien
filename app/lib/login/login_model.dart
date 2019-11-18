part of 'login.dart';

abstract class Permission implements Model {

  factory Permission({ @required Scope scope }) => _$Permission(scope: scope);

  Scope get scope;

  String name;

  String description;

  bool enabled;
}

enum LoginPermissionsStatus {
  notLoaded,
  loading,
  available
}

abstract class Login implements Model {

  factory Login({
      @required String clientId,
      @required String redirectUri,
      @required Set<Scope> scopes
    }) {
    return _$Login(
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: scopes,
      permissions: scopes.map((Scope scope) {
        return Permission(scope: scope);
      }).toSet(),
      permissionsStatus: LoginPermissionsStatus.notLoaded,
    );
  }

  String get clientId;

  String get redirectUri;

  Set<Scope> get scopes;

  Set<Permission> get permissions;

  LoginPermissionsStatus permissionsStatus;

  AuthSession session;
}

