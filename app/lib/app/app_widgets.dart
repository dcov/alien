part of 'app.dart';

class AlienApp extends StatelessWidget {

  AlienApp({ Key key }) : super(key: key);

  static PageRoute<T> _pageRouteBuilder<T>(
      RouteSettings settings,
      WidgetBuilder builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: builder
    );
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final AppState state = store.get();
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        color: Colors.deepOrange,
        builder: (_, Widget child) {
          return Themer(
            child: child,
          );
        },
        pageRouteBuilder: _pageRouteBuilder,
        home: state.initialized ? Scaffolding() : SplashScreen()
      );
    },
  );
}

class SplashScreen extends StatelessWidget {

  SplashScreen({ Key key });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
