part of 'user.dart';

class User extends Model {

  User(this.token, this.username);

  final String token;

  final String username;

  ModelSet<Scope> get permissions => _permissions;
  ModelSet<Scope> _permissions;
  set permissions(ModelSet<Scope> value) {
    _permissions = set(_permissions, value);
  }
}
