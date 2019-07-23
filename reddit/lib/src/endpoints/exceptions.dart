import 'package:reddit/values.dart';

/// An exception that is thrown whenever an endpoint is called that requires a
/// [Token] backed by a [RefreshToken], but is instead backed by the device.
class BearerException {
  factory BearerException() => const BearerException._();
  const BearerException._();
}

/// An exception that is thrown whenever an endpoint is called that requires a
/// [Token] backed by a [RefreshToken], and the backing [RefreshToken] does not
/// have the required [Scope] access.
class ScopeException {
  ScopeException(this.scope);
  final Scope scope;
}