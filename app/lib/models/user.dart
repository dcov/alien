
abstract class User {

  User(this.name);

  final String name;
}

class AppUser extends User {

  AppUser({
    String name,
    this.token
  }) : super(name);

  final String token;
}

class ScriptUser extends User {
  ScriptUser(String name) : super(name);
}

