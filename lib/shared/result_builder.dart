import 'package:csj/shared/result_state.dart';
import 'package:flutter/material.dart';

import 'app_error.dart';
import 'error_widget.dart';

class ResultBuilder<T> extends StatelessWidget {
  final ResultState<T> state;
  final Widget Function(T data) onSuccess;
  final Widget Function(AppError error)? onError;
  final Widget Function(String? message)? onLoading;

  const ResultBuilder({
    super.key,
    required this.state,
    required this.onSuccess,
    this.onError,
    this.onLoading,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      Loading<T> loading => onLoading?.call(loading.message) ??
          const Center(child: CircularProgressIndicator()),
      Success<T> success => onSuccess(success.data),
      Error<T> error => onError?.call(error.error) ??
          CustomErrorWidget(error: error.error.message),
      // TODO: Handle this case.
      ResultState<T>() => throw UnimplementedError(),
    };
  }
}