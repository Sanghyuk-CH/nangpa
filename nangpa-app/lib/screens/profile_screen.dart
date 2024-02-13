import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nangpa/models/auth_model.dart';
import 'package:nangpa/models/user_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/services/authentication.dart';
import 'package:nangpa/services/user_api_service.dart';
import 'package:nangpa/token_key.dart';
import 'package:nangpa/utils/custom_error.dart';
import 'package:nangpa/utils/debounce.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  final TextEditingController _nicknameController = TextEditingController();
  String? _imageUrl;

  final _debouncer = Debouncer(milliseconds: 300);

  // 비밀번호 변경 모달 관련 state
  bool _currentPasswordVisible1 = false; // 현재 비밀번호 필드의 표시 상태
  bool _newPasswordVisible2 = false; // 새로운 비밀번호 필드의 표시 상태
  bool _newPasswordConfirmVisible3 = false; // 새로운 비밀번호 확인 필드의 표시 상태
  // 비밀번호 변경 모달 관련 state

  @override
  void initState() {
    super.initState();
    checkLoginStatus(context, () {
      _fetchUserProfile();
    });
  }

  _logout() async {
    try {
      await UserApiService().logout();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그아웃 완료'),
            content: const Text('로그아웃 되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      Navigator.pushNamed(context, '/');
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그아웃 실패'),
            content: const Text('다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      UserModel userProfile = await UserApiService().getUserProfileByPref();
      setState(() {
        user = userProfile;
        _nicknameController.text = userProfile.nickname;
        _imageUrl = userProfile.profileImgUrl;
      });
    } catch (e) {
      _showErrorDialog(context, '회원정보를 불러오는데 실패했습니다. 잠시 후에 시도해주세요.',
          pushNameRouter: '/');
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String text,
      {String? pushNameRouter}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류 발생'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (pushNameRouter != null) {
                  Navigator.pushNamed(context, pushNameRouter);
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    try {
      await UserApiService().modifyUserProfile(
        _nicknameController.text,
        _imageUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원정보가 변경되었습니다.')),
      );
      UserModel updatedUser = await UserApiService().getUserProfile();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(TokenKey.USER_KEY, jsonEncode(updatedUser));
      setState(() {
        user = updatedUser;
      });
    } catch (e) {
      if (e is CustomException) {
        if (e.message == '중복되는 닉네임입니다.') {
          _showErrorDialog(context, '중복되는 닉네임입니다.');
        } else {
          _showErrorDialog(context, '회원정보를 수정하는데에 실패했습니다. 잠시 후에 시도해주세요.');
        }
      }
    }
  }

  Future<void> _changePassword(ChangePasswordModel changePasswordData) async {
    try {
      await UserApiService().changePassword(changePasswordData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 변경되었습니다, 다시 로그인해주세요.')),
      );

      await UserApiService().logout();
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      if (e is CustomException) {
        await _showErrorDialog(context, e.message);
      }
    }
  }

  void _showProfileEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // 바깥쪽 클릭시 모달이 닫히지 않도록 설정
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.9, // 화면의 90%를 차지하도록 설정
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: '닉네임'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '현재프로필',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      backgroundImage: _imageUrl != null
                          ? NetworkImage(
                              _imageUrl!,
                            ) as ImageProvider<Object>
                          : const AssetImage(
                              'assets/images/default-user-image.png'),
                      radius: 40,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _insertImage();
                        setState(() {}); // 이 부분이 이미지를 변경한 후 UI를 업데이트합니다.
                      },
                      child: const Text('프로필 사진 변경'),
                    ),
                    const Spacer(), // 이 부분을 추가해서 버튼들을 아래쪽에 배치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (user != null) {
                              _imageUrl = user!.profileImgUrl;
                              _nicknameController.text = user!.nickname;
                            }
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // 버튼 색상 설정
                          ),
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _updateProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // 버튼 색상 설정
                          ),
                          child: const Text('확인'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPasswordChangeDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController newPasswordConfirmController =
        TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      decoration: InputDecoration(
                        labelText: '현재 비밀번호',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _currentPasswordVisible1
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentPasswordVisible1 =
                                  !_currentPasswordVisible1;
                            });
                          },
                        ),
                      ),
                      obscureText: !_currentPasswordVisible1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '현재 비밀번호를 입력해주세요';
                        } else if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        labelText: '새로운 비밀번호',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newPasswordVisible2
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _newPasswordVisible2 = !_newPasswordVisible2;
                            });
                          },
                        ),
                      ),
                      obscureText: !_newPasswordVisible2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '새로운 비밀번호를 입력해주세요';
                        } else if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordConfirmController,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newPasswordConfirmVisible3
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _newPasswordConfirmVisible3 =
                                  !_newPasswordConfirmVisible3;
                            });
                          },
                        ),
                      ),
                      obscureText: !_newPasswordConfirmVisible3,
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return '새로운 비밀번호와 비밀번호 확인이 일치하지 않습니다.';
                        } else if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate() &&
                                user != null) {
                              _debouncer.run(() {
                                ChangePasswordModel changePasswordData =
                                    ChangePasswordModel(
                                        phoneNumber: user!.phoneNumber,
                                        originPassword:
                                            currentPasswordController.text,
                                        newPassword:
                                            newPasswordController.text);
                                _changePassword(changePasswordData);
                              });
                            }
                          },
                          child: const Text('변경'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    _currentPasswordVisible1 = false;
    _newPasswordVisible2 = false;
    _newPasswordConfirmVisible3 = false;
  }

  Future<void> _requestPermissions() async {
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _insertImage() async {
    await _requestPermissions();

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        // 이미지 압축
        final compressedBytes = await _compressImage(pickedFile.path);

        // 서버에 이미지 업로드
        final apiService = ApiService();
        final filename = path.basename(pickedFile.path);
        final presignedUrl = await apiService.getPresignedUrl(filename);
        await apiService.uploadImage(
            compressedBytes, presignedUrl, pickedFile.path);

        setState(() {
          _imageUrl = apiService.getPublicUrl(filename);
        });
      }
    } catch (e) {
      // 이미지 로드 에러
      print('Image Load Error');
      print(e);
    }
  }

  Future<Uint8List> _compressImage(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800,
      minHeight: 600,
      quality: 85,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'EF_watermelonSalad',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user!.profileImgUrl != null
                            ? NetworkImage(user!.profileImgUrl!)
                                as ImageProvider<Object>
                            : const AssetImage(
                                'assets/images/default-user-image.png'),
                        radius: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              '안녕하세요 ',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'EF_watermelonSalad',
                              ),
                            ),
                            Text(
                              user!.nickname,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'EF_watermelonSalad',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              '님',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'EF_watermelonSalad',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 50,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showProfileEditDialog(context);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('프로필 수정'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 32,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showPasswordChangeDialog(context);
                                },
                                icon: const Icon(Icons.vpn_key),
                                label: const Text('비밀번호 변경'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _logout();
                            },
                            child: const Text('로그아웃'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
