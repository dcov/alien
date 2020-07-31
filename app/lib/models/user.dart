import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

part 'user.g.dart';

abstract class User implements Model {

  factory User({
    @required String token,
    @required String name,
  }) = _$User;

  String get token;

  String get name;
}

