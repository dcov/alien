
class Auth {

  Auth({
    required this.appId,
    required this.appRedirect,
  });

  final String appId;

  final String appRedirect;
}

abstract class AuthOwner {
  Auth get auth;
}
