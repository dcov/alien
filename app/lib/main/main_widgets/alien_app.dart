part of '../main.dart';

class AlienApp extends StatelessWidget {

  AlienApp({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Theming theming = store.get();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theming.data,
        home: Material(
          child: Builder(
            builder: (BuildContext context) {
              final double topPadding = MediaQuery.of(context).padding.top;
              return _MainLayout(
                topBarHeight: topPadding + 56.0,
                bottomBarHeight: 56.0,
                frontDrop: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: topPadding + 32.0,
                      ),
                      child: ListView(
                        children: List.generate(10, (index) {
                          return ListTile(
                            title: Text('Front #${index}'),
                          );
                        }),
                      )
                    ),
                    Padding(
                      padding: MediaQuery.of(context).padding,
                      child: Material(
                        color: const Color(0xFFE0E0E0),
                        elevation: 2.0,
                        child: SizedBox(
                          height: 56.0,
                          child: NavigationToolbar(
                            middle: Text('Alien'),
                          )
                        ),
                      ),
                    ),
                  ]
                ),
                rearChild: ListView(
                  children: List.generate(10, (index) {
                    return ListTile(
                      title: Text('Rear #${index}'),
                    );
                  }),
                ),
                bottomBar: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.menu),
                    )
                  ],
                ),
              );
            }
          )
        ),
      );
    },
  ); 
}
