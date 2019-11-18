part of 'auth.dart';

class AuthBar extends StatelessWidget {

  AuthBar({
    Key key,
    @required this.auth,
    this.trailing,
  }) : super(key: key);

  final Auth auth;

  final Widget trailing;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, _) {
      return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top
        ),
        child: SizedBox(
          height: 48.0,
          child: Row(children: <Widget>[
            Text(
              auth.currentUser?.username ?? 'Not signed in',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Pressable(
              onPress: () => LoginScreen.show(
                context: context,
                login: auth.login
              ),
              child: Icon(Icons.person)
            ),
            if (trailing != null)
              trailing,
          ])
        )
      );
    }
  );
}

