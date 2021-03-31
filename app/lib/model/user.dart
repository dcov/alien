
abstract class User {

  User(this.name);

  final String name;
}

class AppUser extends User {

  AppUser({
    required String name,
    required this.token
  }) : super(name);

  final String token;
}

class ScriptUser extends User {
  ScriptUser(String name) : super(name);
}
