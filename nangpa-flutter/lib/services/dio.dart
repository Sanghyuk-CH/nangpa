import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nangpa/token_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import 'package:get/get.dart';

Future<String?> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(TokenKey.AUTH_TOKEN_KEY);
}

// 로그인이 필요한 작업할 때 DIO 이것으로 만들어서 사용하기
Dio createDio() {
  final dio = Dio();
  const String baseUrl = kReleaseMode ? releaseBaseUrl : debugBaseUrl;

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(TokenKey.USER_KEY);
    await prefs.remove(TokenKey.AUTH_TOKEN_KEY);
    Get.toNamed('/login');
  }

  dio.interceptors.add(
    InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await getAuthToken();
      if (token != null) {
        options.headers['Authorization'] = token;
      }
      return handler.next(options);
    }, onError: (DioError error, handler) async {
      if (error.response?.data != null &&
          error.response?.data['statusCode'] == 403 &&
          error.response?.data['message'] == "계정이 정지되었습니다.") {
        // 계정이 정지되었다는 모달 띄우기
        await Get.defaultDialog(
          title: "알림",
          middleText: "계정이 정지되었습니다.",
          confirm: ElevatedButton(
            child: const Text("확인"),
            onPressed: () async {
              logout();
            },
          ),
        );

        logout();
      }
      return handler.next(error);
    }),
  );
  return dio;
}
