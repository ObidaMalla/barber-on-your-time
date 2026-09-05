import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/login/loginScreen.dart';
import '../main.dart';
import '../token/token_storage.dart';

Dio createAndSetupDio() {
  Dio dio = Dio();

  dio.options = BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }

        final prefs = await SharedPreferences.getInstance();
        final languageCode = prefs.getString('language_code') ?? 'en';
        options.headers["lang"] = languageCode;

        print("------ API REQUEST ------");
        print("URL: ${options.uri}");
        print("Method: ${options.method}");
        print("Headers: ${options.headers}");
        if (options.data != null) print("Body: ${options.data}");
        print("-------------------------");

        return handler.next(options);
      },

      onError: (e, handler) async {
        // مسارات ما لازم تعمل auto-logout عند 401 - لأنه الـ 401 هون
        // معناه "بيانات غلط" مش "جلسة منتهية"
        final path = e.requestOptions.path;
        final isSessionUnrelated401 =
            path.contains("/auth/login") ||
            path.contains("/auth/register") ||
            path.contains("/users/me/password");

        if (e.response?.statusCode == 401 && !isSessionUnrelated401) {
          await TokenStorage.removeToken();

          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }

        return handler.next(e);
      },

      onResponse: (response, handler) {
        print("------ API RESPONSE ------");
        print("URL: ${response.requestOptions.uri}");
        print("Status Code: ${response.statusCode}");
        print("Data: ${response.data}");
        print("--------------------------");
        return handler.next(response);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      requestBody: true,
    ),
  );

  return dio;
}
