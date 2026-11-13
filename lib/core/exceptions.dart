import 'strings.dart';

enum ApiErrorType {
  noInternet,
  timeout,
  badStatus,
  notFound,
  badFormat,
  unknown,
}

/// Error jaringan/data yang sudah diterjemahkan menjadi pesan untuk pengguna.
/// Lapisan tampilan cukup membaca [message].
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  factory ApiException.noInternet() =>
      const ApiException(ApiErrorType.noInternet, Str.errTidakAdaInternet);

  factory ApiException.timeout() =>
      const ApiException(ApiErrorType.timeout, Str.errTimeout);

  factory ApiException.badStatus(int? statusCode) => ApiException(
    ApiErrorType.badStatus,
    Str.errStatusHttp(statusCode),
    statusCode: statusCode,
  );

  /// BMKG membalas 404 bila kode wilayah tidak punya data prakiraan.
  factory ApiException.notFound() => const ApiException(
    ApiErrorType.notFound,
    Str.errDataTidakAda,
    statusCode: 404,
  );

  factory ApiException.badFormat([String? detail]) => ApiException(
    ApiErrorType.badFormat,
    detail == null ? Str.errFormat : Str.errFormatDetail(detail),
  );

  factory ApiException.unknown() =>
      const ApiException(ApiErrorType.unknown, Str.errTakTerduga);

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${type.name}): $message';
}
