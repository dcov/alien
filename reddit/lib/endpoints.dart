import 'package:meta/meta.dart';

import 'src/endpoints/interactor.dart';
import 'src/endpoints/account.dart';
import 'src/endpoints/any.dart';
import 'src/endpoints/history.dart';
import 'src/endpoints/identity.dart';
import 'src/endpoints/my_subreddits.dart';
import 'src/endpoints/private_messages.dart';
import 'src/endpoints/read.dart';
import 'src/endpoints/save.dart';
import 'src/endpoints/vote.dart';

import 'client.dart';
import 'values.dart';

export 'src/endpoints/exceptions.dart';
export 'src/endpoints/values.dart';

class RedditInteractor extends EndpointInteractor with AnyEndpointsMixin,
  AccountEndpointsMixin, HistoryEndpointsMixin, IdentityEndpointsMixin,
  MySubredditsEndpointsMixin, PrivateMessagesEndpointsMixin, ReadEndpointsMixin,
  SaveEndpointsMixin, VoteEndpointsMixin {

  RedditInteractor({ @required RedditClient client, RefreshToken refreshToken })
    : super(client, refreshToken);
}