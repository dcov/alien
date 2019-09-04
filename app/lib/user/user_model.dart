part of 'user.dart';

abstract class User extends Model {

  String get token;

  String get username;

  Set<Scope> permissions;
}
