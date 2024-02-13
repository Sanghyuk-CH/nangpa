import 'package:flutter/material.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/token_key.dart';
import 'package:nangpa/utils/debounce.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  const ForgotPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _debouncer = Debouncer(milliseconds: 300);

  void _resetPasswrod() async {
    // 로그인
    try {
      await UserApiService().sendResetUserPassword(widget.phoneNumber);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(TokenKey.IS_RESET_PASSWORD_KEY, true);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('성공'),
          content:
              const Text('문자로 새로운 비밀번호를 전송하였습니다. 로그인 후 비밀번호를 변경해주시길 바랍니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('실패'),
          content: const Text('비밀번호 재설정에 실패했습니다. 잠시 뒤에 다시 시도해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'EF_watermelonSalad',
                        color: Color.fromRGBO(28, 176, 121, 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '아이디(핸드폰 번호)',
                        border: OutlineInputBorder(),
                        fillColor: Colors.grey,
                      ),
                      initialValue: widget.phoneNumber,
                      readOnly: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _debouncer.run(_resetPasswrod);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromRGBO(28, 176, 121, 1),
                              ),
                            ),
                            child: const Text(
                              '재설정 비밀번호 받기',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text('로그인 하러가기'),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
