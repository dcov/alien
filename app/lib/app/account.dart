import 'package:reddit/values.dart';

import 'base.dart';
import 'thing.dart';

class AccountModel extends Model with ThingModelMixin {

  AccountModel(Account thing) {
    _commentKarma = thing.commentKarma;
    _createdUtc = thing.createdUtc;
    _iconImageUrl = thing.iconImageUrl;
    _isFriend = thing.isFriend;
    _isGold = thing.isGold;
    _isMod = thing.isMod;
    _isOver18 = thing.isOver18;
    _linkKarma = thing.linkKarma;
    _username = thing.username;
    initThingModel(thing);
  }

  int get commentKarma => _commentKarma;
  int _commentKarma;

  int get createdUtc => _createdUtc;
  int _createdUtc;

  String get iconImageUrl => _iconImageUrl;
  String _iconImageUrl;

  bool get isFriend => _isFriend;
  bool _isFriend;

  bool get isGold => _isGold;
  bool _isGold;

  bool get isMod => _isMod;
  bool _isMod;

  bool get isOver18 => _isOver18;
  bool _isOver18;

  int get linkKarma => _linkKarma;
  int _linkKarma;

  String get username => _username;
  String _username;

  @override
  void didMatchThing(Account thing) {
    // TODO: implement didMatchThing
  }
}