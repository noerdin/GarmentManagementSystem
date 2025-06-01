class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  factory AppError.network() => AppError(
    message: 'Network connection error. Please check your internet.',
    code: 'NETWORK_ERROR',
  );

  factory AppError.notFound(String item) => AppError(
    message: '$item not found',
    code: 'NOT_FOUND',
  );

  factory AppError.unauthorized() => AppError(
    message: 'You are not authorized to perform this action',
    code: 'UNAUTHORIZED',
  );

  factory AppError.generic(String message) => AppError(
    message: message,
    code: 'GENERIC_ERROR',
  );
}