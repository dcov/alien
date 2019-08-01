part of '../endpoints.dart';

mixin SaveEndpoints on EndpointInteractor {

  Future<void> postSave(String fullSaveableId) {
    return post('${_kOAuthUrl}/api/save', 'id=${fullSaveableId}');
  }

  Future<void> postUnsave(String fullSaveableId) {
    return post('${_kOAuthUrl}/api/unsave', 'id=${fullSaveableId}');
  }
}
