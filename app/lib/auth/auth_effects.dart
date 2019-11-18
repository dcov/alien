part of 'auth.dart';

class RetrieveAccounts extends Effect {

  const RetrieveAccounts();

  @override
  dynamic perform(Deps deps) async {
    final Box box = await deps.hive.openBox('auth');
    box.get('users');
  }
}

class StoreAccounts extends Effect {

  const StoreAccounts();

  @override
  dynamic perform(Deps deps) async {
    final Box box = await deps.hive.openBox('auth');
  }
}

