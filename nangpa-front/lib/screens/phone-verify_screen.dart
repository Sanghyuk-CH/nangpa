import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nangpa/screens/forgot-password_screen.dart';
import 'package:nangpa/screens/signup_screen.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/utils/debounce.dart';

enum SecondPage {
  signup,
  findPassword,
}

class PhoneNumberVerificationScreen extends StatefulWidget {
  final SecondPage secondPage;
  const PhoneNumberVerificationScreen({Key? key, required this.secondPage})
      : super(key: key);

  @override
  State<PhoneNumberVerificationScreen> createState() =>
      _PhoneNumberVerificationScreenState();
}

class _PhoneNumberVerificationScreenState
    extends State<PhoneNumberVerificationScreen> {
  Timer? _verificationTimer;
  int _verificationTimeLeft = 0;
  bool _hasRequestedVerification = false; // 전송 성공 여부.

  final _debouncer = Debouncer(milliseconds: 300);

  // controller
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  // controller

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _codeErrorMessage;

  // 여기에 전화번호 인증 관련 기능을 추가하세요.

  // 인증 번호 받기
  void _handlePhoneVerification() async {
    setState(() {
      _codeErrorMessage = null; // 에러 메시지 초기화
    });
    final errorResult = await UserApiService().sendVerifyCode(
        _phoneNumberController.text,
        isResetVerify: widget.secondPage == SecondPage.findPassword);
    if (errorResult != null) {
      // 인증번호 발송 실패
      final statusCode = errorResult['statusCode'];
      final errorMessage = errorResult['message'];

      if (statusCode == HttpStatus.badRequest) {
        // 전화번호가 이미 사용 중인 경우
        setState(() {
          _errorMessage = '전화번호가 이미 사용 중입니다. 로그인을 시도하세요.';
        });
      } else {
        // 인증번호 발송에 실패한 경우
        setState(() {
          _errorMessage = '인증번호 발송에 실패했습니다. 다시 시도해주세요.';
        });
      }
    } else {
      // 인증번호 발송 성공
      startVerificationTimer();
      setState(() {
        _errorMessage = null;
        _hasRequestedVerification = true;
      });
    }
  }

  startVerificationTimer() {
    if (_verificationTimer != null) {
      _verificationTimer!.cancel();
      _verificationTimer = null;
    }

    setState(() {
      _hasRequestedVerification = true;
      _verificationTimeLeft = 5 * 60; // 5분
    });

    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_verificationTimeLeft <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _verificationTimeLeft--;
        });
      }
    });
  }

  // 인증번호 검증 로직
  void _handleVerificationCodeSubmit() async {
    setState(() {
      _codeErrorMessage = null; // 에러 메시지 초기화
    });
    if (_formKey.currentState!.validate()) {
      try {
        bool isVerify = await UserApiService().verifySmsCode(
            phoneNumber: _phoneNumberController.text,
            code: _codeController.text);

        if (isVerify) {
          // 인증 성공
          if (_verificationTimer != null) {
            _verificationTimer!.cancel();
            _verificationTimer = null;
          }
          setState(() {
            _codeErrorMessage = null;
          });

          if (widget.secondPage == SecondPage.signup) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignupScreen(
                  phoneNumber: _phoneNumberController.text,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(
                  phoneNumber: _phoneNumberController.text,
                ),
              ),
            );
          }
        } else {
          // 인증 실패
          setState(() {
            _codeErrorMessage = '인증번호가 올바르지 않습니다. 다시 입력해주세요.';
          });
        }
      } catch (e) {
        setState(() {
          _codeErrorMessage = '인증 과정에서 오류가 발생했습니다. 다시 시도해주세요.';
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _codeController.dispose();
    if (_verificationTimer != null) {
      _verificationTimer!.cancel();
      _verificationTimer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
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
                      '휴대폰 인증',
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
                (Column(
                  children: [
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: '휴대폰 번호를 입력하세요(Ex. 01012341234)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (_hasRequestedVerification) {
                          setState(() {
                            _hasRequestedVerification = false;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '휴대폰 번호를 입력하세요.';
                        }

                        final RegExp phoneNumberRegExp =
                            RegExp(r'^01[016789]\d{7,8}$');
                        if (!phoneNumberRegExp.hasMatch(value)) {
                          return '올바른 휴대폰 번호를 입력해주세요.';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '$_errorMessage',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (!_hasRequestedVerification)
                      ElevatedButton(
                        onPressed: () {
                          _debouncer.run(_handlePhoneVerification);
                        },
                        child: const Text('인증번호 받기'),
                      )
                    else
                      Column(
                        children: [
                          TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: '받은 인증번호를 입력하세요',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '인증번호를 입력하세요.';
                              }
                              if (_codeErrorMessage != null) {
                                return '인증번호가 올바르지 않습니다.';
                              }
                              // 추가적인 유효성 검사가 필요한 경우 여기에 작성하세요.
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          Text(
                            '남은 시간: ${_verificationTimeLeft ~/ 60}:${_verificationTimeLeft % 60}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _debouncer.run(_handlePhoneVerification);
                                },
                                child: const Text('재전송'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _debouncer.run(_handleVerificationCodeSubmit);
                                },
                                child: const Text('인증 확인'),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
