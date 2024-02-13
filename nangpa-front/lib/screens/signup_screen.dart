import 'package:flutter/material.dart';
import 'package:nangpa/models/auth_model.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/utils/custom_error.dart';
import 'package:nangpa/utils/debounce.dart';

class SignupScreen extends StatefulWidget {
  final String phoneNumber;
  const SignupScreen({super.key, required this.phoneNumber});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // controller
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // controller

  // visible
  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;

  // visible

  final _debouncer = Debouncer(milliseconds: 300);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _handleSignup() async {
    // 로그인
    if (_formKey.currentState!.validate()) {
      try {
        await UserApiService().signUp(SignUpModel(
          name: _nameController.text,
          phoneNumber: widget.phoneNumber,
          password: _passwordController.text,
          marketing: false, // 현재는 마케팅 false 고정.
        ));

        final bool? result = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('회원가입 성공'),
              content: const Text('축하합니다!! 회원가입에 성공했습니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );

        if (result != null && result) {
          Navigator.pushNamed(context, '/login');
        }
        Navigator.pushNamed(context, '/login');
      } catch (e) {
        if (e is CustomException) {
          if (e.message == '중복되는 닉네임입니다.') {
            setState(() {
              _errorMessage = '중복되는 닉네임입니다.';
            });
          }
        } else {
          setState(() {
            _errorMessage = '회원가입에 실패했습니다. 다시 시도해주세요.';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '회원가입',
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '닉네임',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '닉네임을 입력해주세요.';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return '비밀번호 6자리 이상 입력해주세요.';
                          }
                          return null;
                        },
                        obscureText: !_passwordVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordConfirmController,
                        decoration: InputDecoration(
                          labelText: '비밀번호확인',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordConfirmVisible =
                                    !_passwordConfirmVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                        obscureText: !_passwordConfirmVisible,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _debouncer.run(_handleSignup);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  const Color.fromRGBO(28, 176, 121, 1),
                                ),
                              ),
                              child: const Text(
                                '회원가입',
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
      ),
    );
  }
}
