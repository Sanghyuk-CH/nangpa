// authentication.dart
import 'package:flutter/material.dart';
import 'package:nangpa/token_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getLoginInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(TokenKey.AUTH_TOKEN_KEY);
}

Future<void> checkLoginStatus(BuildContext context, Function combackFn) async {
  String? token = await getLoginInfo();
  if (token == null) {
    // 로그인이 되어 있지 않음.
    showLoginRequiredDialog(context, combackFn);
  } else {
    combackFn();
  }
}

Future<void> showLoginRequiredDialog(
    BuildContext context, Function combackFn) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true, // 외부를 탭하면 다이얼로그가 닫힙니다.
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          '로그인 필요',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: const Text('이 작업을 수행하려면 로그인이 필요합니다.'),
        actions: <Widget>[
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              Navigator.pushNamed(context, '/login').then((value) {
                // 페이지 돌아오고 나서 상태 렌더링
                combackFn();
              });
            },
          ),
        ],
      );
    },
  );
  Navigator.pushNamed(context, '/login').then((value) {
    // 페이지 돌아오고 나서 상태 렌더링
    combackFn();
  });
}
