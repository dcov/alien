part of 'authorization.dart';

class Authorization extends Model {

  Authorization({
    @required this.clientId,
    @required this.redirectUri
  }) {
    this._users = ModelSet<User>(this);
  }

  final String clientId;

  final String redirectUri;

  User get currentUser => _currentUser;
  User _currentUser;
  set currentUser(User value) {
    _currentUser = set(_currentUser, value);
  }

  ModelSet<User> get users => _users;
  ModelSet<User> _users;
}
