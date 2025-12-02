import 'package:equatable/equatable.dart';

/// Base failure class for all errors
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network/connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Client failures (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure(super.message);
}

/// Unauthorized failures (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Validation failures (422)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(super.message, {this.errors});

  @override
  List<Object> get props => [message, errors ?? {}];
}
