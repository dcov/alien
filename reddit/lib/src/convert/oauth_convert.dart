import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:reddit/values.dart';

RefreshToken buildRefreshToken(Map obj) => RefreshToken((b) => b
  ..scopes = SetBuilder<Scope>(obj["scope"].split(" ").map((value) => Scope.from(value)))
  ..value = obj["refresh_token"]
);

RefreshToken decodeRefreshToken(String json) => buildRefreshToken(jsonDecode(json));

Token buildToken(Map obj) => Token((b) => b
  ..expiresIn = obj["expires_in"]
  ..value = obj["access_token"]
);

Token decodeToken(String json) => buildToken(jsonDecode(json));