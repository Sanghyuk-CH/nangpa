import 'package:flutter/material.dart';
import 'package:nangpa/services/authentication.dart';
import 'package:nangpa/widgets/editor.dart';

class CommunityPostScreen extends StatefulWidget {
  const CommunityPostScreen({super.key});

  @override
  State<CommunityPostScreen> createState() => _CommunityPostScreenState();
}

class _CommunityPostScreenState extends State<CommunityPostScreen> {
  @override
  void initState() {
    super.initState();
    // 로그인 체크 로직
    checkLoginStatus(context, () {
      // 로그인 후 다시 돌아왔을 때 리렌더링.
      checkLoginStatus(context, () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: MyEditor(),
      ),
    );
  }
}
