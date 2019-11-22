part of 'auth.dart';

class AuthButton extends StatelessWidget {

  AuthButton({
    Key key,
    @required this.auth,
  }) : super(key: key);

  final Auth auth;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPress: () {},
      child: SizedBox(
        height: 48.0,
        width: 48.0,
        child: Center(
          child: Icon(Icons.person),
        )
      )
    );
  }
}

class AuthEntry extends ShellAreaEntry {

  AuthEntry({ @required this.auth });

  final Auth auth;

  @override
  String get title => 'Switch Account';

  @override
  Widget buildBody(_) => Connector(
    builder: (_, __) {
      return ListView.builder(
        itemBuilder: (_, int index) {
        }
      );
    }
  );
}

