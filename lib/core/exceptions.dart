enum ApiErrorType { noInternet, timeout, badStatus, badFormat, unknown }

/// Error jaringan/data yang sudah diterjemahkan menjadi pesan untuk pengguna.
/// Lapisan tampilan cukup membaca [message].
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  factory ApiException.noInternet() => const ApiException(
    ApiErrorType.noInternet,
    'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
  );

  factory ApiException.timeout() => const ApiException(
    ApiErrorType.timeout,
    'Server BMKG terlalu lama merespons. Coba lagi beberapa saat lagi.',
  );

  factory ApiException.badStatus(int? statusCode) => ApiException(
    ApiErrorType.badStatus,
    'Server BMKG mengembalikan status HTTP ${statusCode ?? '-'}.',
    statusCode: statusCode,
  );

  factory ApiException.badFormat([String? detail]) => ApiException(
    ApiErrorType.badFormat,
    detail == null
        ? 'Format data dari BMKG tidak dikenali.'
        : 'Format data dari BMKG tidak dikenali: $detail',
  );

  factory ApiException.unknown() => const ApiException(
    ApiErrorType.unknown,
    'Terjadi kesalahan tak terduga saat mengambil data.',
  );

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${type.name}): $message';
}
