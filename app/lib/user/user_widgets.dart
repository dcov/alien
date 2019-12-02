part of 'user.dart';

class UserTile extends StatelessWidget {

	UserTile({
		Key key,
		@required this.user,
		@required this.onLogIn,
		@required this.onLogOut,
	}) : super(key: key);

	final User user;

  final VoidCallback onLogIn;

  final VoidCallback onLogOut;

	@override
	Widget build(BuildContext context) {
		return CustomTile(
		  onTap: onLogIn,
		  icon: Pressable(
		    onPress: onLogOut,
		    child: Icon(Icons.close)
		  ),
			title: Text(user.name),
		);
	}
}

