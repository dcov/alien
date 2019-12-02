part of '../parameters.dart';

class Scope extends Parameter {
  static const Scope account = Scope._('account');
  static const Scope creddits = Scope._('creddits');
  static const Scope edit = Scope._('edit');
  static const Scope flair = Scope._('flair');
  static const Scope history = Scope._('history');
  static const Scope identity = Scope._('identity');
  static const Scope liveManage = Scope._('livemanage');
  static const Scope modConfig = Scope._('modconfig');
  static const Scope modContributors = Scope._('modcontributors');
  static const Scope modFlair = Scope._('modflair');
  static const Scope modLog = Scope._('modlog');
  static const Scope modMail = Scope._('modmail');
  static const Scope modOthers = Scope._('modothers');
  static const Scope modPosts = Scope._('modposts');
  static const Scope modSelf = Scope._('modself');
  static const Scope modWiki = Scope._('modwiki');
  static const Scope mySubreddits = Scope._('mysubreddits');
  static const Scope privateMessages = Scope._('privatemessages');
  static const Scope read = Scope._('read');
  static const Scope report = Scope._('report');
  static const Scope save = Scope._('save');
  static const Scope submit = Scope._('submit');
  static const Scope subscribe = Scope._('subscribe');
  static const Scope vote = Scope._('vote');
  static const Scope wikiEdit = Scope._('wikiedit');
  static const Scope wikiRead = Scope._('wikiread');

  const Scope._(String name) : super._(name);

  static const Iterable<Scope> values = const <Scope>{
    account, creddits, edit, flair, history, identity, liveManage, modConfig,
    modContributors, modFlair, modLog, modMail, modOthers, modPosts, modSelf,
    modWiki, mySubreddits, privateMessages, read, report, save, submit,
    subscribe, vote, wikiEdit, wikiRead
  };

  static Scope from(String value) {
    final String name = value.toLowerCase();
    for (final Scope scope in values) {
      if (scope.name == name) {
        return scope;
      }
    }
    return null;
  }
}

class VoteDir extends Parameter {
  static const VoteDir up = VoteDir._('up', '1');
  static const VoteDir down = VoteDir._('down', '-1');
  static const VoteDir none = VoteDir._('none', '0');

  const VoteDir._(String name, String value) : super._(name, value);
}
