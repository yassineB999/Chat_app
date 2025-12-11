import 'package:dartz/dartz.dart';
import 'package:nexuschatfe/core/error/failures.dart';

/// Base class for use cases that require parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
