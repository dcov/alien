part of 'user.dart';

abstract class User implements Model {

  String get token;

  String get username;

  Set<Scope> permissions;
}
