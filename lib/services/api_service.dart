import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/gempa.dart';

/// Satu-satunya pintu ke API BMKG. Semua error dio diubah menjadi
/// [ApiException] sehingga lapisan lain tidak perlu mengenal dio.
class ApiService {
  ApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              responseType: ResponseType.json,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<Gempa> fetchAutoGempa() async {
    final json = await _getJson(ApiConstants.autoGempaUrl);
    try {
      return Gempa.fromAutoGempaJson(json);
    } on FormatException catch (e) {
      throw ApiException.badFormat(e.message);
    }
  }

  /// Fase 1: dikembalikan sebagai Map mentah, model menyusul di fase berikut.
  Future<Map<String, dynamic>> fetchPrakiraanCuaca(String adm4) {
    return _getJson(
      ApiConstants.prakiraanCuacaUrl,
      queryParameters: {'adm4': adm4},
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _fromDio(e);
    } catch (_) {
      throw ApiException.unknown();
    }
    return _asJsonMap(response.data);
  }

  Map<String, dynamic> _asJsonMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    // Bila server tidak mengirim Content-Type JSON, dio memberi String.
    if (data is String) {
      try {
        return _asJsonMap(jsonDecode(data));
      } on FormatException {
        throw ApiException.badFormat('respons bukan JSON');
      }
    }
    throw ApiException.badFormat('respons bukan objek JSON');
  }

  ApiException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException.timeout();
      case DioExceptionType.connectionError:
        return ApiException.noInternet();
      case DioExceptionType.badResponse:
        return ApiException.badStatus(e.response?.statusCode);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return ApiException.unknown();
    }
  }
}
