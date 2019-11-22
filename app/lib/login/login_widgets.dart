part of 'login.dart';

const Duration _kSwitchDuration = Duration(milliseconds: 250);

class LoginEntry extends ShellAreaEntry {

  LoginEntry({ @required this.login });

  final Login login;

  @override
  String get title => 'Login to Reddit';

  @override
  List<Widget> buildTopActions(BuildContext context) {
    return <Widget>[
      Pressable(
        onPress: () {},
        child: SizedBox(
          width: 48.0,
          height: 48.0,
          child: Icon(Icons.edit)
        )
      ),
    ];
  }

  @override
  Widget buildBody(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      final LoginPermissionsStatus status = login.permissionsStatus;
      final ValueKey statusKey = ValueKey(login.permissionsStatus);
      return Material(
        color: Colors.black54,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top
            ),
            child: SizedBox(
              height: 48.0,
              child: Row(children: <Widget>[
                AnimatedSwitcher(
                  duration: _kSwitchDuration,
                  child: KeyedSubtree(
                    key: statusKey,
                    child: status == LoginPermissionsStatus.loading
                        ? const SizedBox()
                        : Text('Login to Reddit')
                  ),
                ),
                AnimatedSwitcher(
                  duration: _kSwitchDuration,
                  child: KeyedSubtree(
                    key: statusKey,
                    child: status == LoginPermissionsStatus.loading
                        ? const CircularProgressIndicator()
                        : WebView(
                            initialUrl: login.session.url,
                            onWebViewCreated: (WebViewController controller) {}
                          ),
                  )
                ),
              ])
            )
          ),
        ])
      );
    }
  );
}

