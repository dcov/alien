import 'package:flutter/material.dart';

import '../widgets/page.dart';
import '../widgets/pressable.dart';
import '../widgets/tile.dart';

import 'user_model.dart';

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

class UserPage extends Page {

  UserPage({
    RouteSettings settings,
    @required this.user,
  }) : super(settings: settings);

  final User user;

  @override
  Widget buildPage(BuildContext context, _, __) {
    return Material();
  }
}

