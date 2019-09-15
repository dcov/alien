part of 'utils.dart';

bool userIsSignedIn(Store store) {
  return store.get<Authorization>().currentUser != null;
}

String getUserToken(Store store, [ModelKey userKey]) {
  User user;
  if (userKey != null) {
    user = store.get<User>(userKey);
  } else {
    user = store.get<Authorization>().currentUser;
  }
  return user.token;
}
