part of 'theming.dart';

class UpdateTheme extends Event {

  UpdateTheme({
    @required this.type
  });

  final ThemeType type;

  @override
  void update(Store store) {
    store.get<Theming>()
      ..data = () {
          switch (this.type) {
            case ThemeType.light:
              return ThemeData.light();
            case ThemeType.dark:
              return ThemeData.dark();
          }
          return null;
        }()
      ..type  = this.type;
  }
}
