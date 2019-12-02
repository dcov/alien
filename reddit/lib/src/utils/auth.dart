import 'package:uuid/uuid.dart';

const String _kAuthorizationUrl = 'https://www.reddit.com/api/v1/authorize.compact';

class AuthSession {

  factory AuthSession(String clientId, String redirectUri, Iterable<String> scopes) {
    final String state = Uuid().v4().toString().substring(0, 10);
    final String url = '${_kAuthorizationUrl}'
                       '?client_id=${clientId}'
                       '&response_type=code'
                       '&state=${state}'
                       '&redirect_uri=${redirectUri}'
                       '&duration=permanent'
                       '${scopes.isNotEmpty
                            ? '&scope=${scopes.join(' ')}'
                            : ''}';
    return AuthSession._(url, state);
  }

  AuthSession._(this.url, this.state);

  final String url;
  final String state;
}
