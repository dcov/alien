part of '../app.dart';

class AlienApp extends StatelessWidget {

  AlienApp({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final ThemingState themingState = store.get();
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        color: themingState.data.primaryColor,
        builder: (BuildContext context, Widget child) {
          return Theming(
            child: child,
          );
        },
        home: AppHome(
        ),
      );
    },
  );
}
