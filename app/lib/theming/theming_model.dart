part of 'theming.dart';

enum ThemeType {
  light,
  dark
}

class ThemingState extends Model {

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
