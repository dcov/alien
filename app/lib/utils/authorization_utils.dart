part of 'utils.dart';

String getUserToken(Store store, [ModelKey userKey]) {
  User user;
  if (userKey != null) {
    user = store.get<User>(userKey);
  } else {
    user = store.get<Authorization>().currentUser;
  }
  return user.token;
}
