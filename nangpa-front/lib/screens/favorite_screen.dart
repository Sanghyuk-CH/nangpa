import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nangpa/models/menu_model.dart';
import 'package:nangpa/screens/recipe_detail.dart';
import 'package:nangpa/widgets/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<SimplifiedMenu>> _likedRecipeListFuture;

  onToggleLikedButton(SimplifiedMenu menu) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final likedRecipeListJson = sharedPrefs.getStringList('likedRecipeList');

    List<SimplifiedMenu> likedRecipeList = likedRecipeListJson != null
        ? likedRecipeListJson
            .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
            .toList()
        : [];

    SimplifiedMenu selectedMenu = SimplifiedMenu(
        id: menu.id, name: menu.name, url: menu.url, isLiked: false);

    bool isLiked = likedRecipeList.any((item) => item.id == menu.id);

    if (isLiked) {
      likedRecipeList.removeWhere((item) => item.id == selectedMenu.id);
    } else {
      likedRecipeList.add(selectedMenu);
    }

    final jsonStringList =
        likedRecipeList.map((recipe) => jsonEncode(recipe.toJson())).toList();

    sharedPrefs.setStringList('likedRecipeList', jsonStringList);
    _likedRecipeListFuture = _initSharedPrefs();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _likedRecipeListFuture = _initSharedPrefs();
  }

  Future<List<SimplifiedMenu>> _initSharedPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final likedRecipeListJson =
        sharedPrefs.getStringList('likedRecipeList') ?? [];

    final likedRecipeList = likedRecipeListJson
        .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
        .toList();

    return likedRecipeList;
  }

  Future<void> _deleteFromSharedPrefs(int id) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final likedRecipeListJson =
        sharedPrefs.getStringList('likedRecipeList') ?? [];

    final updatedLikedRecipeList = likedRecipeListJson
        .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
        .toList()
      ..removeWhere((menu) => menu.id == id);

    final updatedLikedRecipeListJson = updatedLikedRecipeList
        .map((menu) => jsonEncode(menu.toJson()))
        .toList();

    sharedPrefs.setStringList('likedRecipeList', updatedLikedRecipeListJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          "찜목록",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'EF_watermelonSalad',
          ),
        ),
      ),
      body: FutureBuilder(
        future: getMenuListWithLiked(_likedRecipeListFuture),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final menus = snapshot.data!;
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('찜한 레시피가 존재하지 않습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'EF_watermelonSalad',
                    )),
              );
            } else {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 30,
                      right: 30,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '총 ${menus.length}개의 레시피',
                          style: const TextStyle(
                            color: Color(0xFF7E7E7E),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'EF_watermelonSalad',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: ListView.separated(
                        itemCount: menus.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 24);
                        },
                        itemBuilder: (context, index) {
                          final menu = menus[index];
                          return SizedBox(
                            height: 190,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        child: Container(
                                          height: 150,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Image.network(
                                            menu.url,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipeDetail(id: menu.id),
                                            ),
                                          ).then((value) {
                                            // 페이지 돌아오고 나서 상태 렌더링
                                            setState(() {});
                                          });
                                          // Navigate to menu detail screen
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        menu.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontFamily: 'EF_watermelonSalad',
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RecipeDetail(id: menu.id),
                                          ),
                                        ).then((value) {
                                          // 페이지 돌아오고 나서 상태 렌더링
                                          setState(() {});
                                        });
                                        // Navigate to menu detail screen
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        onToggleLikedButton(menu);
                                      },
                                      child: Icon(
                                        Icons.favorite,
                                        color: menu.isLiked
                                            ? const Color(0xFF1CB079)
                                            : const Color(0xFFD3D3D3),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading menus'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// 메뉴 받아온 것에서 찜 목록과 연동해서 메뉴 리스트 반환
Future<List<SimplifiedMenu>> getMenuListWithLiked(
    Future<List<SimplifiedMenu>> menuList) async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  final likedRecipeListJson = sharedPrefs.getStringList('likedRecipeList');

  List<SimplifiedMenu> likedRecipeList = likedRecipeListJson != null
      ? likedRecipeListJson
          .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
          .toList()
      : [];

  final menu = await menuList;

  return menu.map((menu) {
    final bool isLiked =
        likedRecipeList.any((likedMenu) => likedMenu.id == menu.id);
    return menu.copyWith(isLiked: isLiked);
  }).toList();
}
