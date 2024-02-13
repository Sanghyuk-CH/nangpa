import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nangpa/screens/community-post_screen.dart';
import 'package:nangpa/screens/community_screen.dart';
import 'package:nangpa/screens/favorite_screen.dart';
import 'package:nangpa/screens/home_screen.dart';
import 'package:nangpa/screens/login_screen.dart';
import 'package:nangpa/screens/phone-verify_screen.dart';
import 'package:nangpa/screens/profile_screen.dart';
import 'package:nangpa/screens/recipe_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/recipes', page: () => const RecipeScreen()),
        GetPage(name: '/favorites', page: () => const FavoriteScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
            name: '/signup',
            page: () => const PhoneNumberVerificationScreen(
                secondPage: SecondPage.signup)),
        GetPage(
            name: '/forgot_password',
            page: () => const PhoneNumberVerificationScreen(
                secondPage: SecondPage.findPassword)),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/community', page: () => const CommunityScreen()),
        GetPage(
            name: '/community/post', page: () => const CommunityPostScreen()),
      ],
    );
  }
}
