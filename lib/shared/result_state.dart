import 'app_error.dart';

abstract class ResultState<T> {
  const ResultState();
}

class Loading<T> extends ResultState<T> {
  final String? message;
  const Loading({this.message});
}

class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ResultState<T> {
  final AppError error;
  const Error(this.error);
}