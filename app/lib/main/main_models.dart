part of 'main.dart';

enum ThemeType {
  light,
  dark
}

class ThemeState {
  ThemeState(this.data, this.type);
  final ThemeData data;
  final ThemeType type;
}

class Theming extends Model {

  ThemeData get data => _data;
  ThemeData _data;
  set data(ThemeData value) {
    _data = set(_data, value);
  }

  ThemeType get type => _type;
  ThemeType _type;
  set type(ThemeType value) {
    _type = set(_type, value);
  }
}
