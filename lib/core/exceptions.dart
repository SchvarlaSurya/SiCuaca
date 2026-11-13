enum ApiErrorType {
  noInternet,
  timeout,
  badStatus,
  notFound,
  badFormat,
  unknown,
}

/// Error jaringan/data. [message] hanya untuk log; teks untuk pengguna
/// dipilih widget dari [type] sesuai bahasa aktif (lihat `pesanGalat` di
/// core/l10n.dart).
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  factory ApiException.noInternet() =>
      const ApiException(ApiErrorType.noInternet, 'no internet connection');

  factory ApiException.timeout() =>
      const ApiException(ApiErrorType.timeout, 'request timed out');

  factory ApiException.badStatus(int? statusCode) => ApiException(
    ApiErrorType.badStatus,
    'unexpected HTTP status $statusCode',
    statusCode: statusCode,
  );

  /// BMKG membalas 404 bila kode wilayah tidak punya data prakiraan.
  factory ApiException.notFound() => const ApiException(
    ApiErrorType.notFound,
    'no data for this area',
    statusCode: 404,
  );

  factory ApiException.badFormat([String? detail]) => ApiException(
    ApiErrorType.badFormat,
    detail == null ? 'unrecognised data format' : 'unrecognised data: $detail',
  );

  factory ApiException.unknown() =>
      const ApiException(ApiErrorType.unknown, 'unexpected error');

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${type.name}): $message';
}
