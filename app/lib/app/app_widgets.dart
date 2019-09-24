part of 'app.dart';

class AlienApp extends StatelessWidget {

  AlienApp({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final AppState state = store.get();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.deepOrange,
        builder: (_, Widget child) {
          return Themer(
            child: child,
          );
        },
        home: state.initialized ? Scaffolding() : SplashScreen()
      );
    },
  );
}

class SplashScreen extends StatelessWidget {

  SplashScreen({ Key key });

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
