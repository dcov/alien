part of 'session.dart';

abstract class Session extends Model {

  Session._();

  
}

class AnonymousSession extends Session {

  AnonymousSession() : super._();
}

class UserSession extends Session {

  UserSession({
    this.user,
  }) : super._();

  final User user;

  @override
  Iterable<Model> get models sync* {
    yield user;
    yield* super.models;
  }
}
