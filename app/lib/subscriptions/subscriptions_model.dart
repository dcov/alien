part of 'subscriptions.dart';

class Subscriptions extends Model {

  Subscriptions() {
    this._subreddits = ModelList<Subreddit>(this);
  }

  ModelList<Subreddit> get subreddits => _subreddits; 
  ModelList<Subreddit> _subreddits;
}
