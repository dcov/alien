part of 'login.dart';

class GetPermissions extends Effect {

  GetPermissions({ @required this.login });

  final Login login;

  @override
  dynamic perform(Deps deps) async {
    try {
      final Iterable<ScopeData> data = await deps.client
              .asDevice()
              .getScopeDescriptions(login.scopes);
      return PermissionsLoaded(
        login: login,
        data: data
      );
    } catch (_) {
      return PermissionsLoadingFailed(login: login);
    }
  }
}

