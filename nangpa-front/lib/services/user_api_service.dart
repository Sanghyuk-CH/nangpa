import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nangpa/config.dart';
import 'package:nangpa/models/auth_model.dart';
import 'package:nangpa/models/user_model.dart';
import 'package:nangpa/services/dio.dart';
import 'package:nangpa/token_key.dart';
import 'package:nangpa/utils/custom_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  final String baseUrl = kReleaseMode ? releaseBaseUrl : debugBaseUrl;
  final Dio _dio = Dio();

  // 핸드폰 인증 문자 발송
  Future<Map<String, dynamic>?> sendVerifyCode(String phoneNumber,
      {bool isResetVerify = false}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/sms/send',
        data: {'phone': phoneNumber, 'is_reset_verify': isResetVerify},
      );
      return null;
    } catch (error) {
      if (error is DioError && error.response != null) {
        // 에러 응답에서 메시지와 상태 코드를 추출합니다.
        final errorMessage = error.response!.data['message'];
        final statusCode = error.response!.statusCode;
        return {'message': errorMessage, 'statusCode': statusCode};
      }
      return {'message': 'Failed to connect to the API', 'statusCode': null};
    }
  }

  // 비밀번호 재설정 문자 보내기
  Future<void> sendResetUserPassword(String phone) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/reset-password',
        data: {
          'phone_number': phone,
        },
      );
    } catch (error) {
      throw Exception('Failed to connect to the API');
    }
  }

  // 비밀번호 변경

  Future<void> changePassword(ChangePasswordModel changePasswordData) async {
    try {
      Dio customDio = createDio();
      final response = await customDio.post(
        '$baseUrl/auth/change-password',
        data: {
          'phone_number': changePasswordData.phoneNumber,
          'password': changePasswordData.originPassword,
          'new_password': changePasswordData.newPassword,
        },
      );
    } catch (error) {
      String sendingMessage = '비밀번호 변경에 실패했습니다.';
      if (error is DioError && error.response != null) {
        // 에러 응답에서 메시지와 상태 코드를 추출합니다.
        String message = error.response!.data['message'];

        if (message == '현재 비밀번호와 일치합니다.') {
          sendingMessage = '현재 비밀번호와 변경할 비밀번호가 일치합니다.';
        }

        if (message == '현재 비밀번호가 올바르지 않습니다.') {
          sendingMessage = '현재 비밀번호가 올바르지 않습니다.';
        }
      }
      throw CustomException(400, sendingMessage);
    }
  }

  // 핸드폰 인증
  Future<bool> verifySmsCode(
      {required String phoneNumber, required String code}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/sms/verify',
        data: {'phone': phoneNumber, 'code': code},
      );
      return jsonDecode(response.data);
    } catch (error) {
      throw Exception('Failed to connect to the API');
    }
  }

  // 로그인
  Future<void> login(LoginModel loginData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'phone_number': loginData.phoneNumber,
          'password': loginData.password
        },
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (response.data != null && response.data['user'] != null) {
        UserModel user = UserModel.fromJson(response.data['user']);
        prefs.setString(TokenKey.USER_KEY, jsonEncode(user));
      }

      await prefs.setString(
          TokenKey.AUTH_TOKEN_KEY, response.headers['authorization']![0]);
    } catch (error) {
      throw Exception('Failed to connect to the API');
    }
  }

  // 회원가입
  Future<void> signUp(SignUpModel signUpData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/signup',
        data: {
          'phone_number': signUpData.phoneNumber,
          'password': signUpData.password,
          'name': signUpData.name,
          'marketing': signUpData.marketing,
        },
      );
    } catch (error) {
      if (error is DioError) {
        String message = error.response?.data?['message'] ?? '';
        int errorCode = error.response?.statusCode ?? 500;
        if (message == '중복되는 닉네임입니다.') {
          throw CustomException(errorCode, message);
        }
      }
      throw CustomException(400, 'Failed to connect to the API');
    }
  }

  // 유저 로그아웃
  Future<void> logout() async {
    try {
      Dio customDio = createDio();
      final response = await customDio.post('$baseUrl/auth/logout');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(TokenKey.USER_KEY);
      await prefs.remove(TokenKey.AUTH_TOKEN_KEY);
    } catch (error) {
      throw Exception('Failed to Logout');
    }
  }

  // 유저 정보 추출
  Future<UserModel> getUserProfile() async {
    try {
      Dio customDio = createDio();
      final response = await customDio.get(
        '$baseUrl/user/profile',
      );
      return UserModel.fromJson(response.data);
    } catch (error) {
      throw CustomException(500, "프로필을 불러오는데 실패했습니다.");
    }
  }

  // 유저 정보 추출
  Future<UserModel> getUserProfileByPref() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? userString = pref.getString(TokenKey.USER_KEY);
      if (userString != null) {
        Map<String, dynamic> userMap = jsonDecode(userString);
        UserModel user = UserModel.fromJson(userMap);
        return user;
      } else {
        throw CustomException(500, "프로필을 불러오는데 실패했습니다.");
      }
    } catch (error) {
      throw CustomException(500, "프로필을 불러오는데 실패했습니다.");
    }
  }

  // 유저 정보 변경
  Future<void> modifyUserProfile(String nickname, String? imgUrl) async {
    try {
      Dio customDio = createDio();
      final response = await customDio.put('$baseUrl/user/profile', data: {
        'nickname': nickname,
        'profile_img_url': imgUrl,
      });
    } catch (error) {
      if (error is DioError) {
        String message = error.response?.data?['message'] ?? '';
        int errorCode = error.response?.statusCode ?? 500;
        if (message == '중복되는 닉네임입니다.') {
          throw CustomException(errorCode, message);
        }
      }
      throw CustomException(400, "프로필을 수정하는데에 실패했습니다.");
    }
  }
}
