part of 'login.dart';

const Duration _kSwitchDuration = Duration(milliseconds: 250);

class LoginScreen extends StatelessWidget {

  LoginScreen({
    Key key,
    @required this.login,
  }) : super(key: key);

  final Login login;

  static void show({ BuildContext context, Login login }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => LoginScreen(login: login)
      )
    );
  }

  @override
  Widget build(_) => Connector(
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

