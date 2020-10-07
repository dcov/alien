import '../client/client.dart';
import '../types/data/data.dart';
import '../types/parameters/parameters.dart';

part 'any_endpoints.dart';
part 'identity_endpoints.dart';
part 'my_subreddits_endpoints.dart';
part 'read_endpoints.dart';
part 'save_endpoints.dart';
part 'subscribe_endpoints.dart';
part 'vote_endpoints.dart';

const String _kRawJsonArgs = '.json?raw_json=1';

String _formatTimeSortAsArg(TimeSort sortFrom, [String prefix='&']) {
  if (sortFrom == null)
    return '';
  return '${prefix}t=$sortFrom';
}

