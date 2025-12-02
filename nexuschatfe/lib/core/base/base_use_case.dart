import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for stream-based use cases
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
