import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final DioException? failure;

  const DataState(this.data, this.failure);
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data, null);
}

class DataError<T> extends DataState<T> {
  const DataError(DioException failure) : super(null, failure);
}
