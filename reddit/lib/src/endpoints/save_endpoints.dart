part of 'endpoints.dart';

extension SaveEndpoints on RedditClient {

  Future<void> postSave(String fullSaveableId) {
    return post('/api/save', body: 'id=${fullSaveableId}');
  }

  Future<void> postUnsave(String fullSaveableId) {
    return post('/api/unsave', body: 'id=${fullSaveableId}');
  }
}

