
class Auth {

  Auth({
    this.appId,
    this.appRedirect,
  });

  final String appId;

  final String appRedirect;
}

abstract class AuthOwner {
  Auth get auth;
}

