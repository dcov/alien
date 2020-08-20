import 'package:elmer/elmer.dart';

part 'user.g.dart';

abstract class User extends Model {

  factory User({
    String token,
    String name
  }) = _$User;

  String get token;

  String get name;
}

