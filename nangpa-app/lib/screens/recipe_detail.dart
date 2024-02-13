import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nangpa/models/ingredient_model.dart';
import 'package:nangpa/models/menu_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetail extends StatefulWidget {
  int id;

  RecipeDetail({super.key, required this.id});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late SharedPreferences sharedPrefs;
  late Future<MenuModel?> menuDetail;
  late Future<IngredientListModel?> ingredientList;
  bool isLiked = false;
  bool isIngredientSelected = true;

  initSharedPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
    final likedRecipeListJson = sharedPrefs.getStringList('likedRecipeList');

    List<SimplifiedMenu> likedRecipeList = likedRecipeListJson != null
        ? likedRecipeListJson
            .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
            .toList()
        : [];

    if (likedRecipeList.where((menu) => menu.id == widget.id).isNotEmpty) {
      isLiked = true;
    } else {
      isLiked = false;
    }

    setState(() {});
  }

  // 찜 좋아요 버튼
  onToggleLikedButton() async {
    sharedPrefs = await SharedPreferences.getInstance();
    final likedRecipeListJson = sharedPrefs.getStringList('likedRecipeList');

    List<SimplifiedMenu> likedRecipeList = likedRecipeListJson != null
        ? likedRecipeListJson
            .map((json) => SimplifiedMenu.fromJson(jsonDecode(json)))
            .toList()
        : [];

    MenuModel? menu = await menuDetail;

    if (menu == null) return;

    SimplifiedMenu selectedMenu = SimplifiedMenu(
        id: menu.id, name: menu.name, url: menu.url, isLiked: false);

    if (isLiked) {
      likedRecipeList.removeWhere((item) => item.id == selectedMenu.id);
    } else {
      likedRecipeList.add(selectedMenu);
    }

    final jsonStringList =
        likedRecipeList.map((recipe) => jsonEncode(recipe.toJson())).toList();

    sharedPrefs.setStringList('likedRecipeList', jsonStringList);

    setState(() {
      initSharedPrefs();
    });
  }

  // 레시피 버튼 클릭
  void onToggleIngredientButton() {
    setState(() {
      isIngredientSelected = true;
    });
  }

  // 재료 버튼 클릭
  void onToggleRecipeButton() {
    setState(() {
      isIngredientSelected = false;
    });
  }

  @override
  void initState() {
    super.initState();
    menuDetail = ApiService().getMenuDetail(widget.id);
    ingredientList = ApiService().getIngredients();
    initSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MenuModel?>(
          future: menuDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final menu = snapshot.data!;
              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          menu.url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 30),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      menu.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'EF_watermelonSalad',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    OutlinedButton(
                                      onPressed: onToggleIngredientButton,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isIngredientSelected
                                            ? Colors.white
                                            : const Color(0xFFC2C2C2),
                                        backgroundColor: isIngredientSelected
                                            ? const Color(0xFF1CB079)
                                            : null,
                                        side: BorderSide(
                                          color: isIngredientSelected
                                              ? Colors.transparent
                                              : const Color(0xFFC2C2C2),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        '재료',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isIngredientSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: onToggleRecipeButton,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: !isIngredientSelected
                                            ? Colors.white
                                            : const Color(0xFFC2C2C2),
                                        backgroundColor: !isIngredientSelected
                                            ? const Color(0xFF1CB079)
                                            : null,
                                        side: BorderSide(
                                          color: !isIngredientSelected
                                              ? Colors.transparent
                                              : const Color(0xFFC2C2C2),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        '레시피',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isIngredientSelected
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isIngredientSelected == true)
                                  Row(children: [
                                    buildIngredientInfo(menu, snapshot)
                                  ]),
                                if (isIngredientSelected == true &&
                                    (snapshot.data!.ingredientRequiredList
                                                ?.length ??
                                            0) >
                                        0)
                                  buildRequiredIngredientList(snapshot),
                                if (isIngredientSelected == true &&
                                    (snapshot.data!.ingredientOptionalList
                                                ?.length ??
                                            0) >
                                        0)
                                  buildOptionalIngredientList(snapshot),
                                if (menu.recipe.isNotEmpty &&
                                    isIngredientSelected == false)
                                  renderRecipe(menu),
                              ],
                            )),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(isLiked
                                ? Icons.favorite
                                : Icons.favorite_border),
                            onPressed: onToggleLikedButton,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text('레시피를 찾지 못했습니다. 다시 시도해주세요.'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  FutureBuilder<IngredientListModel?> buildOptionalIngredientList(
      AsyncSnapshot<MenuModel?> snapshot) {
    return FutureBuilder<IngredientListModel?>(
      future: ingredientList,
      builder: (context,
          AsyncSnapshot<IngredientListModel?> ingredientListSnapshot) {
        if (ingredientListSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!ingredientListSnapshot.hasData) {
          return const Text("No data found.");
        }

        return ListView.separated(
          padding: const EdgeInsets.all(0),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.ingredientOptionalList?.length ?? 0,
          itemBuilder: (context, index) {
            // Find the matching ingredient in the ingredientList
            IngredientModel? matchedIngredient = ingredientListSnapshot
                .data!.ingredientList
                .firstWhere((ingredient) =>
                    ingredient.name ==
                    snapshot.data!.ingredientOptionalList![index].name);

            // Get the iconName for the matched ingredient, or use a default one if not found
            String iconName =
                matchedIngredient != null ? matchedIngredient.iconName : '';

            return Row(
              children: [
                // Use the iconName to display the corresponding icon
                iconName != ''
                    ? SizedBox(
                        width: 52,
                        height: 52,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ingredients/$iconName.svg',
                            height: 40,
                            width: 40,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          border: Border.all(
                            color: const Color(0xFFF0F0F0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 52,
                          minHeight: 52,
                          maxWidth: 52,
                          maxHeight: 52,
                        ),
                        child: const SizedBox
                            .expand(), // Optional: You can replace this with any child widget you want to include within the container.
                      ),
                const SizedBox(width: 22),
                Text(
                  snapshot.data!.ingredientOptionalList![index].name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  FutureBuilder<IngredientListModel?> buildRequiredIngredientList(
      AsyncSnapshot<MenuModel?> snapshot) {
    return FutureBuilder<IngredientListModel?>(
      future: ingredientList,
      builder: (context,
          AsyncSnapshot<IngredientListModel?> ingredientListSnapshot) {
        if (ingredientListSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!ingredientListSnapshot.hasData) {
          return const Text("No data found.");
        }

        return ListView.separated(
          padding: const EdgeInsets.all(0),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.ingredientRequiredList?.length ?? 0,
          itemBuilder: (context, index) {
            // Find the matching ingredient in the ingredientList
            IngredientModel? matchedIngredient = ingredientListSnapshot
                .data!.ingredientList
                .firstWhere((ingredient) =>
                    ingredient.name ==
                    snapshot.data!.ingredientRequiredList![index].name);

            // Get the iconName for the matched ingredient, or use a default one if not found
            String iconName =
                matchedIngredient != null ? matchedIngredient.iconName : '';

            return Row(
              children: [
                // Use the iconName to display the corresponding icon
                iconName != ''
                    ? SizedBox(
                        width: 52,
                        height: 52,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ingredients/$iconName.svg',
                            height: 40,
                            width: 40,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          border: Border.all(
                            color: const Color(0xFFF0F0F0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 52,
                          minHeight: 52,
                          maxWidth: 52,
                          maxHeight: 52,
                        ),
                        child: const SizedBox
                            .expand(), // Optional: You can replace this with any child widget you want to include within the container.
                      ),
                const SizedBox(width: 22),
                Text(
                  snapshot.data!.ingredientRequiredList![index].name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'EF_watermelonSalad',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Expanded buildIngredientInfo(
      MenuModel menu, AsyncSnapshot<MenuModel?> snapshot) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                menu.ingredientDescriptionText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "총 ${(snapshot.data!.ingredientRequiredList?.length ?? 0) + (snapshot.data!.ingredientOptionalList?.length ?? 0)}개의 재료",
            style: const TextStyle(
              color: Color(0xff7E7E7E),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Column renderRecipe(MenuModel menu) {
    return Column(
      children: [
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "조리방법 - ${menu.way}",
              style: const TextStyle(
                color: Color(0xff7E7E7E),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menu.recipe.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Image.network(
                  menu.recipe[index].url,
                  fit: BoxFit.scaleDown, // 이미지 크기를 화면보다 작은 경우에만 늘림
                  width: MediaQuery.of(context).size.width,
                  height: 94, // 화면 너비에 맞춰 이미지 크기 조절
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 94,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Flexible(
                          child: Text(
                        "${index + 1}. ${menu.recipe[index].text}",
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.44,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
