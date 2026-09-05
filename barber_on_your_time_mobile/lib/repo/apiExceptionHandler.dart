// lib/core/network/api_exception_handler.dart
import 'package:dio/dio.dart';

class ApiExceptionHandler {
  /// يلف أي Future جاي من retrofit/dio ويطلع نفس رسائل الخطأ الموحدة
  static Future<T> handle<T>(
    Future<T> Function() request, {
    required String fallbackErrorMessage,
    bool Function(T response)? isSuccess,
    String? Function(T response)? extractMessage,
  }) async {
    try {
      final response = await request();

      if (isSuccess == null || isSuccess(response)) {
        return response;
      }

      final errorMessage =
          extractMessage?.call(response) ?? fallbackErrorMessage;
      throw errorMessage;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        final serverMessage = responseData['message'].toString().trim();
        if (serverMessage.isNotEmpty) throw serverMessage;
      }

      switch (e.type) {
        case DioExceptionType.connectionError:
          throw 'تحقق من اتصال الإنترنت 🧨';
        case DioExceptionType.connectionTimeout:
          throw 'تعذر الاتصال بالسيرفر 🧨';
        case DioExceptionType.sendTimeout:
          throw 'انتهى وقت إرسال الطلب 🧨';
        case DioExceptionType.receiveTimeout:
          throw 'انتهى الوقت، يرجى المحاولة مرة أخرى 🧨';
        default:
          throw 'حدث خطأ تقني، حاول لاحقاً 🧨';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ تقني، حاول لاحقاً 🧨';
    }
  }
}
