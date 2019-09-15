import 'package:meta/meta.dart';

import '../../types.dart';

part 'endpoints/any_endpoints.dart';
part 'endpoints/identity_endpoints.dart';
part 'endpoints/my_subreddits_endpoints.dart';
part 'endpoints/read_endpoints.dart';
part 'endpoints/save_endpoints.dart';
part 'endpoints/subscribe_endpoints.dart';
part 'endpoints/vote_endpoints.dart';

const String _kOAuthUrl = 'https://oauth.reddit.com';

const String _kModUrl = 'https://mod.reddit.com';

const String _kRawJsonArgs = '.json?raw_json=1';

abstract class EndpointInteractor {

  @protected
  Future<String> get(String url);

  @protected
  Future<String> post(String url, [String body]);

  @protected
  Future<String> patch(String url, [String body]);

  @protected
  Future<String> delete(String url);
}
